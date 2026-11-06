import Flutter
import Foundation
import Nbmap
import NbmapCoreNavigation
import UIKit

/// Page/subscription ownership belongs to Flutter; downloads belong to Navigation.
final class OfflineNavigationHandler: NSObject, FlutterPlugin, FlutterStreamHandler {
    private let registrar: FlutterPluginRegistrar
    private let methods: FlutterMethodChannel
    private let events: FlutterEventChannel
    private var sink: FlutterEventSink?
    private var subscription: NBNavigation.OfflineProgressSubscription?
    private var pending: [UUID: FlutterResult] = [:]
    private var tasks: [UUID: Task<Void, Never>] = [:]
    private var pageId: String?
    private var closed = false
    private static weak var pageOwner: OfflineNavigationHandler?

    static func register(with registrar: FlutterPluginRegistrar) {
        let handler = OfflineNavigationHandler(registrar: registrar)
        registrar.addMethodCallDelegate(handler, channel: handler.methods)
        registrar.publish(handler)
    }

    private init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        methods = FlutterMethodChannel(name: "nb_navigation_flutter/offline", binaryMessenger: registrar.messenger())
        events = FlutterEventChannel(name: "nb_navigation_flutter/offline/events", binaryMessenger: registrar.messenger())
        super.init()
        events.setStreamHandler(self)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard !closed else { result(FlutterError(code: "DETACHED", message: "Flutter engine detached", details: nil)); return }
        let requestId = UUID()
        pending[requestId] = result
        tasks[requestId] = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                let value = try await self.perform(call)
                self.finish(requestId, value)
            } catch {
                self.finish(requestId, NavigationBridgeError.flutterError(error))
            }
        }
    }

    private func finish(_ id: UUID, _ value: Any?) {
        tasks.removeValue(forKey: id)
        pending.removeValue(forKey: id)?(value)
    }

    @MainActor
    private func perform(_ call: FlutterMethodCall) async throws -> Any? {
        let args = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "configure":
            let mode: RouteMode
            switch args["routeMode"] as? String {
            case "onlineOnly": mode = .onlineOnly
            case "offlineOnly": mode = .offlineOnly
            case "onlinePreferred": mode = .onlinePreferred
            case "offlinePreferred": mode = .offlinePreferred
            case "smart": mode = .smart
            default: throw BridgeFailure("INVALID_ARGUMENT", "Unknown routeMode")
            }
            if args["networkPolicy"] as? String == "unmetered" {
                throw BridgeFailure("UNSUPPORTED_NETWORK_POLICY", "unmetered downloads are supported on Android only")
            }
            guard let policyName = args["networkPolicy"] as? String,
                  let policy = NBNavigation.OfflineDownloadNetworkPolicy(rawValue: policyName) else {
                throw BridgeFailure("INVALID_ARGUMENT", "Unknown networkPolicy")
            }
            // Preserve the SDK's map runtime configuration, including its CDN.
            NBNavigation.setRoutingConfig(RoutingConfig(mode: mode))
            NBNavigation.setDownloadNetworkPolicy(policy)
            return nil
        case "getConfiguration":
            let mode: String
            switch NBNavigation.getRoutingConfig().mode {
            case .onlineOnly: mode = "onlineOnly"
            case .offlineOnly: mode = "offlineOnly"
            case .onlinePreferred: mode = "onlinePreferred"
            case .offlinePreferred: mode = "offlinePreferred"
            case .smart: mode = "smart"
            }
            return ["routeMode": mode, "networkPolicy": NBNavigation.getDownloadNetworkPolicy().rawValue]
        case "isMapDownloadSupported":
            return !(NGLAccountManager.accessToken ?? "").isEmpty && NBNavigation.isOfflineMapDownloadSupported
        case "endDownloadPage":
            if pageId == args["pageId"] as? String { closePage() }
            return nil
        case "initialize":
            try requireAccount()
            try await NBNavigation.initializeOffline()
            attachProgress()
            return nil
        case "shutdown":
            closePage()
            subscription?.cancel(); subscription = nil
            await NBNavigation.shutdownOffline()
            return nil
        default: break
        }
        let initializedMethods: Set<String> = ["syncRegions", "fetchRegions", "listInstalledMapRegions", "downloadRegion",
            "pauseRegion", "resumeRegion", "cancelRegion", "deleteRegion", "getPreviewStatus", "healthCheck",
            "getRegionBoundary", "beginDownloadPage", "refreshMapResources"]
        guard initializedMethods.contains(call.method) else { return FlutterMethodNotImplemented }
        try requireAccount()
        guard NBNavigation.isOfflineInitialized else {
            throw BridgeFailure("ENGINE_NOT_INITIALIZED", "Call NBNavigation.offline.initialize first")
        }
        switch call.method {
        case "syncRegions":
            _ = try await NBNavigation.syncOfflineRegionList(syncMode: args["force"] as? Bool == true ? .force : .auto)
            _ = try await NBNavigation.listOfflineMapCatalog()
            return nil
        case "fetchRegions":
            guard let country = args["country"] as? String,
                  !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw BridgeFailure("INVALID_ARGUMENT", "country must not be blank")
            }
            let result = await NBNavigation.fetchRegionLists(countries: [country])
            return [
                "regions": result.regionRows.map(Self.regionMap),
                "routingError": result.routeError as Any,
                "mapError": result.mapError as Any,
                "installedMapError": result.mapInstalledError as Any,
                "updatedAtMs": Self.milliseconds(result.updatedAt),
            ] as [String: Any]
        case "listInstalledMapRegions":
            return try await NBNavigation.listInstalledMapTileRegions().map { region in
                ["regionId": region.regionId, "name": region.displayName,
                 "totalBytes": region.totalBytes, "packageCount": region.packageCount,
                 "version": region.regionVersion as Any, "packagesComplete": region.allPackagesOk] as [String: Any]
            }
        case "downloadRegion", "pauseRegion", "resumeRegion", "cancelRegion", "deleteRegion":
            let id = try Self.regionId(args)
            let action: NBNavigation.OfflineRegionManageAction
            switch call.method {
            case "downloadRegion": action = .download
            case "pauseRegion": action = .pause
            case "resumeRegion": action = .resume
            case "cancelRegion": action = .cancel
            default: action = .delete
            }
            // Run both Navigation APIs independently so partial success is never
            // hidden by the first failing subsystem. The SDK owns both tasks.
            async let routing = Self.manage(kind: .routing, action: action, regionId: id)
            async let map = Self.manage(kind: .map, action: action, regionId: id)
            return await ["regionId": id, "routing": routing, "mapTiles": map] as [String: Any]
        case "getPreviewStatus":
            let status = try await NBNavigation.offlineMapPreviewStatus()
            return ["stylesReady": status.styleJsonCached, "previewBundleReady": status.previewBundleReady,
                    "spritesReady": status.spritesReady, "tileJsonReady": status.tileJsonReady]
        case "healthCheck":
            let health = try await NBNavigation.checkOfflineHealth()
            return ["state": health.state, "sdkVersion": health.sdkVersion,
                    "engineVersion": health.engineVersion, "datasetVersion": health.datasetVersion,
                    "schemaVersion": health.schemaVersion, "loadedTileCount": health.loadedTileCount,
                    "dataRoot": health.dataRoot] as [String: Any]
        case "getRegionBoundary":
            let id = try Self.regionId(args)
            do {
                return try await NBNavigation.getOfflineRegionBoundary(regionId: id,
                    fetchDetailIfMissing: false).geoJson
            } catch {
                // In 4.1.4 the native missing-detail error is thrown before the
                // facade's empty-string fallback can fetch anything. Keep local
                // reads offline and explicitly warm detail only when requested.
                guard args["fetchIfMissing"] as? Bool != false,
                      NavigationBridgeError.flutterError(error).code == "OFFLINE_DATA_NOT_READY" else { throw error }
                _ = try await NBNavigation.fetchOfflineRegionDetailSummary(regionId: id)
                return try await NBNavigation.getOfflineRegionBoundary(regionId: id,
                    fetchDetailIfMissing: false).geoJson
            }
        case "beginDownloadPage":
            guard let id = args["pageId"] as? String, !id.isEmpty else {
                throw BridgeFailure("INVALID_ARGUMENT", "pageId is required")
            }
            guard let owner = registrar.viewController else {
                throw BridgeFailure("NO_ACTIVITY", "A view controller is required")
            }
            Self.pageOwner?.closePage()
            pageId = id
            Self.pageOwner = self
            NBNavigation.beginDownloadPageWithOwner(owner)
            return nil
        case "refreshMapResources":
            await withCheckedContinuation { continuation in
                NBNavigation.refreshOfflineMapEngineOnMapResume { continuation.resume() }
            }
            return nil
        default: return FlutterMethodNotImplemented
        }
    }

    private func requireAccount() throws {
        guard !(NGLAccountManager.accessToken ?? "").isEmpty else {
            throw BridgeFailure("NOT_INITIALIZED", "Initialize the NextBillion account first")
        }
    }

    private static func regionId(_ args: [String: Any]) throws -> Int64 {
        guard let value = args["regionId"] as? NSNumber,
              CFGetTypeID(value) != CFBooleanGetTypeID(),
              value.doubleValue.isFinite,
              value.doubleValue == Double(value.int64Value),
              value.int64Value > 0, value.int64Value <= Int64(Int32.max) else {
            throw BridgeFailure("INVALID_ARGUMENT", "regionId must be a positive 32-bit integer")
        }
        return value.int64Value
    }

    @MainActor
    private static func manage(kind: NBNavigation.OfflineRegionKind,
                               action: NBNavigation.OfflineRegionManageAction,
                               regionId: Int64) async -> [String: Any] {
        do {
            let result = try await NBNavigation.manageOfflineRegion(kind: kind, action: action, regionId: regionId)
            return ["state": result.state, "errorCode": result.errorCode,
                    "message": result.message as Any, "updatedAtMs": milliseconds(result.updatedAt)]
        } catch {
            let failure = NavigationBridgeError.flutterError(error)
            let nativeCode = (error as? NavigationError).map { Int($0.numericCode) } ?? (error as NSError).code
            return ["state": "FAILED", "errorCode": nativeCode == 0 ? -1 : nativeCode,
                    "message": failure.message as Any, "code": failure.code,
                    "details": failure.details as Any]
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        attachProgress()
        return nil
    }
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        subscription?.cancel(); subscription = nil
        return nil
    }
    private func attachProgress() {
        guard !closed, sink != nil, subscription == nil, NBNavigation.isOfflineInitialized else { return }
        subscription = NBNavigation.observeOfflineRegionProgress { [weak self] rows in
            guard let self, !self.closed else { return }
            self.sink?(rows.map(Self.progressMap))
        }
    }
    @MainActor
    private func closePage() {
        if Self.pageOwner === self {
            NBNavigation.endDownloadPage()
            Self.pageOwner = nil
        }
        pageId = nil
    }
    func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        MainActor.assumeIsolated { closePage() }
        subscription?.cancel(); subscription = nil
        sink = nil
        closed = true
        let replies = Array(pending.values)
        pending.removeAll()
        // Detaching a Flutter engine must not cancel SDK-owned downloads.
        // In-flight native completions find no pending Flutter result below.
        tasks.removeAll()
        replies.forEach { $0(FlutterError(code: "DETACHED", message: "Flutter engine detached", details: nil)) }
        events.setStreamHandler(nil)
    }

    private static func milliseconds(_ date: Date) -> Int64 { Int64(date.timeIntervalSince1970 * 1_000) }
    private static func regionMap(_ row: NBNavigation.OfflineRegionListRow) -> [String: Any] {
        ["regionId": row.regionId, "name": row.displayName, "country": row.country as Any,
         "adminL1": row.adminL1 as Any, "adminL2": row.adminL2 as Any, "adminL3": row.adminL3 as Any,
         "hasRouting": row.routeRegion != nil, "hasMapTiles": row.mapRegion != nil,
         "routingSizeBytes": row.routeSizeBytes as Any, "mapSizeBytes": row.mapSizeBytes as Any,
         "routingVersion": row.routeRegion?.version as Any, "mapVersion": row.mapRegion?.version as Any,
         "routingInstalled": row.routeRegion?.isDownloaded ?? false,
         "routingPartial": row.routeRegion?.isPartial ?? false,
         "routingUpdateAvailable": row.routeRegion?.updateAvailable ?? false,
         "mapUpdateAvailable": row.mapRegion?.updateAvailable ?? false,
         "routingTilesDone": row.routeRegion?.tilesDone as Any,
         "routingTilesTotal": row.routeRegion?.tilesTotal as Any]
    }
    private static func progressMap(_ value: NBNavigation.OfflineRegionProgress) -> [String: Any] {
        ["regionId": value.regionId, "routing": value.routeNetwork.map(subtaskMap) as Any,
         "mapTiles": value.mapTile.map(subtaskMap) as Any, "overallState": value.overallState.rawValue,
         "overallPercent": value.overallPercent, "updatedAtMs": milliseconds(value.updatedAt)]
    }
    private static func subtaskMap(_ value: NBNavigation.OfflineSubtaskProgress) -> [String: Any] {
        ["state": value.state.rawValue, "percent": value.percent,
         "downloaded": value.downloaded as Any, "total": value.total as Any,
         "message": value.message as Any, "error": value.error as Any]
    }
}

struct BridgeFailure: Error {
    let code: String
    let message: String
    init(_ code: String, _ message: String) { self.code = code; self.message = message }
}

enum NavigationBridgeError {
    static func flutterError(_ error: Error) -> FlutterError {
        if let failure = error as? BridgeFailure {
            return FlutterError(code: failure.code, message: failure.message, details: ["recoverable": false])
        }
        let native = error as NSError
        let code: String
        switch error {
        case NavigationError.engineNotInitialized: code = "ENGINE_NOT_INITIALIZED"
        case NavigationError.dataNotReady: code = "OFFLINE_DATA_NOT_READY"
        case NavigationError.dataVersionMismatch: code = "OFFLINE_DATA_VERSION_MISMATCH"
        case NavigationError.invalidConfig, NavigationError.invalidRequest: code = "INVALID_ARGUMENT"
        case NavigationError.timeout: code = "TIMEOUT"
        case NavigationError.interrupted, is CancellationError: code = "INTERRUPTED"
        case NavigationError.regionNotFound: code = "OFFLINE_REGION_NOT_FOUND"
        case NavigationError.regionAlreadyActive: code = "OFFLINE_REGION_ALREADY_ACTIVE"
        case NavigationError.regionNotDownloading: code = "OFFLINE_REGION_NOT_DOWNLOADING"
        case NavigationError.regionNotPaused: code = "OFFLINE_REGION_NOT_PAUSED"
        case NavigationError.regionDeleteFailed: code = "OFFLINE_REGION_DELETE_FAILED"
        case NavigationError.regionCancelFailed: code = "OFFLINE_REGION_CANCEL_FAILED"
        case NavigationError.regionInvalidState: code = "OFFLINE_REGION_INVALID_STATE"
        case NavigationError.internalError: code = "INTERNAL_ERROR"
        case NavigationError.insufficientMemory: code = "INSUFFICIENT_MEMORY"
        case NavigationError.unsupportedAction: code = "UNSUPPORTED_ACTION"
        case NavigationError.engineSuperseded: code = "ENGINE_NOT_INITIALIZED"
        default:
            if native.domain == NSURLErrorDomain {
                switch native.code {
                case NSURLErrorTimedOut: code = "TIMEOUT"
                case NSURLErrorCancelled: code = "INTERRUPTED"
                default: code = "NETWORK_UNAVAILABLE"
                }
            } else { code = "EXECUTION_FAILED" }
        }
        var details: [String: Any] = [
            "nativeCode": (error as? NavigationError).map { Int($0.numericCode) } ?? native.code,
            "nativeDomain": native.domain,
            "recoverable": ["NETWORK_UNAVAILABLE", "TIMEOUT", "INTERRUPTED", "OFFLINE_DATA_NOT_READY"].contains(code),
        ]
        if let navigation = error as? NavigationError {
            details["nativeErrorType"] = navigation.code
            switch navigation {
            case .invalidConfig(_, let value), .dataVersionMismatch(_, let value),
                 .executionFailed(_, let value), .insufficientMemory(_, let value),
                 .regionNotFound(_, let value), .regionAlreadyActive(_, let value),
                 .regionNotDownloading(_, let value), .regionNotPaused(_, let value),
                 .regionDeleteFailed(_, let value), .regionCancelFailed(_, let value),
                 .regionInvalidState(_, let value): details["nativeDetails"] = value
            default: break
            }
        }
        return FlutterError(code: code, message: (error as? NavigationError)?.message ?? native.localizedDescription,
                            details: details)
    }
}
