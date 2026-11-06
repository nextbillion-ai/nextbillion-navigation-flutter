#if DEBUG || OFFLINE_ACCEPTANCE_UI_TEST
import CryptoKit
import Flutter
import Foundation
import NbmapCoreNavigation
import NbmapNavigation
import Network
import Nbmap
import UIKit

/// Example-only test instrumentation. It reads real SDK state; it never supplies
/// routes or invokes reroute callbacks. Enabled only by the UI test environment.
final class OfflineAcceptanceTestHost {
    private let channel: FlutterMethodChannel
    private var observers: [NSObjectProtocol] = []
    private var willReroute = 0
    private var didReroute = 0
    private var failedReroute = 0

    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(name: "example/offline_acceptance", binaryMessenger: messenger)
        for (name, kind) in [(Notification.Name.routeControllerWillReroute, 0),
                             (.routeControllerDidReroute, 1), (.routeControllerDidFailToReroute, 2)] {
            observers.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                guard let self else { return }
                if kind == 0 { self.willReroute += 1 }
                if kind == 1 { self.didReroute += 1 }
                if kind == 2 { self.failedReroute += 1 }
            })
        }
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { return }
            switch call.method {
            case "documents": result(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path)
            case "phase": result(ProcessInfo.processInfo.environment["OFFLINE_ACCEPTANCE_PHASE"] ?? "")
            case "network": self.network(result)
            case "mapSnapshot": result(self.mapSnapshot())
            case "beginTracking":
                self.willReroute = 0; self.didReroute = 0; self.failedReroute = 0; result(nil)
            case "navigationSnapshot": result(self.snapshot())
            case "finishNavigation":
                if let nav = self.findNavigationController() {
                    nav.delegate?.navigationViewControllerDidDismiss(nav, byCanceling: true)
                }
                result(nil)
            default: result(FlutterMethodNotImplemented)
            }
        }
    }

    private func snapshot() -> [String: Any] {
        var value: [String: Any] = ["pid": ProcessInfo.processInfo.processIdentifier,
            "willReroute": willReroute, "didReroute": didReroute, "failedReroute": failedReroute]
        guard let nav = findNavigationController() else { value["active"] = false; return value }
        guard let service = nav.navigationService else { value["active"] = false; return value }
        let progress = service.routeProgress
        let geometry = (progress.route.coordinates ?? []).map {
            String(format: "%.6f,%.6f", $0.latitude, $0.longitude)
        }.joined(separator: ";")
        value["active"] = true
        value["geometryHash"] = SHA256.hash(data: Data(geometry.utf8)).map { String(format: "%02x", $0) }.joined()
        value["distanceRemaining"] = progress.distanceRemaining
        value["distanceTraveled"] = progress.distanceTraveled
        value["legIndex"] = progress.legIndex
        value["stepIndex"] = progress.currentLegProgress.stepIndex
        value["routeSource"] = NBNavigation.lastRouteSource() == .offline ? "offline" : "online"
        if let location = service.router.rawLocation {
            value["rawLocation"] = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
        }
        return value
    }

    private func mapSnapshot() -> [String: Any] {
        func find(_ view: UIView) -> NGLMapView? {
            if let map = view as? NGLMapView { return map }
            for child in view.subviews { if let map = find(child) { return map } }
            return nil
        }
        for window in UIApplication.shared.windows {
            if let map = find(window) {
                return ["featureCount": map.visibleFeatures(in: map.bounds,
                    styleLayerIdentifiers: nil, predicate: nil).count,
                    "layerCount": map.style?.layers.count ?? 0,
                    "styleURL": map.styleURL?.absoluteString ?? "",
                    "latitude": map.centerCoordinate.latitude, "longitude": map.centerCoordinate.longitude]
            }
        }
        return ["featureCount": 0, "layerCount": 0]
    }

    private func findNavigationController() -> NavigationViewController? {
        func controller(_ current: UIViewController) -> NavigationViewController? {
            if let nav = current as? NavigationViewController { return nav }
            if let presented = current.presentedViewController, let found = controller(presented) { return found }
            for child in current.children { if let found = controller(child) { return found } }
            if current.isViewLoaded { return view(current.view) }
            return nil
        }
        func view(_ current: UIView) -> NavigationViewController? {
            if let nav = current.next as? NavigationViewController { return nav }
            for child in current.subviews { if let found = view(child) { return found } }
            return nil
        }
        for window in UIApplication.shared.windows {
            if let root = window.rootViewController, let found = controller(root) { return found }
        }
        return nil
    }

    private func network(_ result: @escaping FlutterResult) {
        let monitor = NWPathMonitor()
        let lock = NSLock()
        var done = false
        monitor.pathUpdateHandler = { path in
            lock.lock(); let first = !done; done = true; lock.unlock()
            guard first else { return }
            monitor.cancel()
            monitor.pathUpdateHandler = nil
            DispatchQueue.main.async {
                result(["status": path.status == .satisfied ? "satisfied" : "unsatisfied",
                        "wifi": path.usesInterfaceType(.wifi), "cellular": path.usesInterfaceType(.cellular)])
            }
        }
        monitor.start(queue: DispatchQueue(label: "example.offline.network"))
    }

    deinit {
        channel.setMethodCallHandler(nil)
        observers.forEach(NotificationCenter.default.removeObserver)
    }
}
#endif
