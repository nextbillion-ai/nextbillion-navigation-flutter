package ai.nextbillion.navigation.nb_navigation_flutter

import ai.nextbillion.maps.Nextbillion
import ai.nextbillion.maps.regionaloffline.release.client.OfflineInstalledRegion
import ai.nextbillion.maps.regionaloffline.release.client.RegionalOffline
import ai.nextbillion.navigation.core.offline.*
import ai.nextbillion.navigation.core.offline.region.*
import ai.nextbillion.navigation.ui.NBNavigation
import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicBoolean

/** Flutter owns subscriptions/page sessions. Navigation SDK owns data and downloads. */
internal class OfflineNavigationHandler(messenger: BinaryMessenger, context: Context) :
    MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private val application = context.applicationContext
    private val methods = MethodChannel(messenger, "nb_navigation_flutter/offline")
    private val events = EventChannel(messenger, "nb_navigation_flutter/offline/events")
    private val main = Handler(Looper.getMainLooper())
    private val pending = mutableSetOf<Reply>()
    private var closed = false
    private var initialized = false
    private var sink: EventChannel.EventSink? = null
    private var subscription: NBNavigation.OfflineProgressSubscription? = null
    private var hostLifecycle: Lifecycle? = null
    private var pageOwner: PageOwner? = null
    private var pageId: String? = null
    private val failureChecks = mutableSetOf<FailureCheck>()
    private val progressListener = OfflineProgressListener { rows ->
        main.post { if (!closed) sink?.success(rows.map(::progressMap)) }
    }

    init {
        methods.setMethodCallHandler(this)
        events.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val reply = Reply(result)
        pending.add(reply)
        try {
            when (call.method) {
                "endDownloadPage" -> {
                    if (pageId == call.argument<String>("pageId")) {
                        closePage(); pageId = null
                    }
                    reply.success(null)
                }
                "configure" -> {
                    val mode = when (call.argument<String>("routeMode")) {
                        "onlineOnly" -> RouteMode.ONLINE_ONLY
                        "offlineOnly" -> RouteMode.OFFLINE_ONLY
                        "onlinePreferred" -> RouteMode.ONLINE_PREFERRED
                        "offlinePreferred" -> RouteMode.OFFLINE_PREFERRED
                        "smart" -> RouteMode.SMART
                        else -> throw IllegalArgumentException("Unknown routeMode")
                    }
                    val policy = when (call.argument<String>("networkPolicy")) {
                        "wifiOnly" -> OfflineDownloadNetworkPolicy.WIFI_ONLY
                        "anyNetwork" -> OfflineDownloadNetworkPolicy.ANY
                        "unmetered" -> OfflineDownloadNetworkPolicy.UNMETERED
                        else -> throw IllegalArgumentException("Unknown networkPolicy")
                    }
                    NBNavigation.setRuntimeConfig(mode, policy)
                    reply.success(null)
                }
                "getConfiguration" -> reply.success(mapOf(
                    "routeMode" to when (NBNavigation.getRouteMode()) {
                        RouteMode.ONLINE_ONLY -> "onlineOnly"
                        RouteMode.OFFLINE_ONLY -> "offlineOnly"
                        RouteMode.ONLINE_PREFERRED -> "onlinePreferred"
                        RouteMode.OFFLINE_PREFERRED -> "offlinePreferred"
                        RouteMode.SMART -> "smart"
                    },
                    "networkPolicy" to when (NBNavigation.getDownloadNetworkPolicy()) {
                        OfflineDownloadNetworkPolicy.WIFI_ONLY -> "wifiOnly"
                        OfflineDownloadNetworkPolicy.UNMETERED -> "unmetered"
                        OfflineDownloadNetworkPolicy.ANY -> "anyNetwork"
                    }))
                "isMapDownloadSupported" -> reply.success(
                    Nextbillion.hasInstance() && RegionalOffline.isSupported())
                "initialize" -> {
                    requireAccount()
                    invoke<Void>(reply, { NBNavigation.initialize(it) }) {
                        initialized = true
                        attachProgress()
                        null
                    }
                }
                "syncRegions" -> {
                    requireInitialized()
                    val mode = if (call.argument<Boolean>("force") == true)
                        RegionListSyncMode.FORCE else RegionListSyncMode.AUTO
                    invoke<OfflineRegionCatalogSyncResult>(reply,
                        { NBNavigation.syncRegions(mode, it) }) { null }
                }
                "fetchRegions" -> {
                    requireInitialized()
                    val country = call.argument<String>("country")?.trim()
                    require(!country.isNullOrEmpty()) { "country must not be blank" }
                    NBNavigation.fetchRegionLists(country, object : NBNavigationTaskCallback<OfflineRegionListResult> {
                        override fun onError(error: Throwable) = reply.error(error)
                        override fun onSuccess(value: OfflineRegionListResult?) {
                            if (value == null) { reply.failure("INVALID_RESPONSE", "Missing region list"); return }
                            NBNavigation.listInstalledMapTileRegions(object : NBNavigationTaskCallback<List<OfflineInstalledRegion>> {
                                override fun onSuccess(installed: List<OfflineInstalledRegion>?) {
                                    reply.success(regionsMap(value, installed.orEmpty(), null))
                                }
                                override fun onError(error: Throwable) {
                                    reply.success(regionsMap(value, emptyList(), error.message))
                                }
                            })
                        }
                    })
                }
                "listInstalledMapRegions" -> {
                    requireInitialized()
                    invoke<List<OfflineInstalledRegion>>(reply,
                        { NBNavigation.listInstalledMapTileRegions(it) }) { rows -> rows.orEmpty().map(::installedMap) }
                }
                "downloadRegion" -> {
                    requireInitialized()
                    val id = regionId(call)
                    invokeManagement<OfflineRegionDownloadData>(reply, id, call.method, { NBNavigation.downloadRegion(id, it) }) { value ->
                        requireNotNull(value)
                        operation(id, downloadMap(value.routeRegion),
                            child(value.mapTileRegion.action.name, message = value.mapTileRegion.message))
                    }
                }
                "pauseRegion" -> {
                    requireInitialized()
                    val id = regionId(call)
                    invokeManagement<OfflineRegionPauseData>(reply, id, call.method, { NBNavigation.pauseRegion(id, it) }) { value ->
                        requireNotNull(value)
                        operation(id, child("PAUSE_REQUESTED", value.routeRegion.errorCode),
                            child(value.mapTileRegion.action.name, message = value.mapTileRegion.message))
                    }
                }
                "resumeRegion" -> {
                    requireInitialized()
                    val id = regionId(call)
                    invokeManagement<OfflineRegionResumeData>(reply, id, call.method, { NBNavigation.resumeRegion(id, it) }) { value ->
                        requireNotNull(value)
                        operation(id, downloadMap(value.routeRegion),
                            child(value.mapTileRegion.action.name, message = value.mapTileRegion.message))
                    }
                }
                "cancelRegion" -> {
                    requireInitialized()
                    val id = regionId(call)
                    invokeManagement<OfflineRegionCancelData>(reply, id, call.method, { NBNavigation.cancelRegion(id, it) }) { value ->
                        requireNotNull(value)
                        operation(id, child("CANCEL_REQUESTED", value.routeRegion.errorCode),
                            child(value.mapTileRegion.action.name, message = value.mapTileRegion.message))
                    }
                }
                "deleteRegion" -> {
                    requireInitialized()
                    val id = regionId(call)
                    invokeManagement<OfflineRegionDeleteData>(reply, id, call.method, { NBNavigation.deleteRegionAllData(id, it) }) { value ->
                        requireNotNull(value)
                        operation(id, child("DELETE_REQUESTED", value.routeRegion.errorCode),
                            child(value.mapTileRegion.action.name, message = value.mapTileRegion.message))
                    }
                }
                "getPreviewStatus" -> {
                    requireInitialized()
                    reply.success(mapOf("stylesReady" to NBNavigation.isMapTilePreviewStylesCached()))
                }
                "healthCheck" -> {
                    requireInitialized()
                    invoke<HealthStatus>(reply, { NBNavigation.healthCheck(it) }) { health ->
                        requireNotNull(health)
                        mapOf("state" to health.state, "sdkVersion" to health.sdkVersion,
                            "engineVersion" to health.engineVersion, "datasetVersion" to health.datasetVersion,
                            "schemaVersion" to health.schemaVersion, "loadedTileCount" to health.loadedTileCount,
                            "dataRoot" to health.dataRoot)
                    }
                }
                "getRegionBoundary" -> {
                    requireInitialized()
                    invoke<OfflineRegionBoundary>(reply,
                        { NBNavigation.getOfflineRegionBoundary(regionId(call), call.argument<Boolean>("fetchIfMissing") != false, it) }) {
                        requireNotNull(it).geoJson
                    }
                }
                "beginDownloadPage" -> {
                    requireInitialized()
                    val token = call.argument<String>("pageId")
                    require(!token.isNullOrBlank()) { "pageId is required" }
                    val lifecycle = hostLifecycle
                    if (lifecycle == null || lifecycle.currentState == Lifecycle.State.DESTROYED) {
                        reply.failure("NO_ACTIVITY", "A foreground Activity is required"); return
                    }
                    closePage()
                    pageId = token
                    openPage(lifecycle)
                    reply.success(null)
                }
                "refreshMapResources" -> {
                    requireInitialized()
                    // Display refresh is a Maps operation; all downloads above use Navigation.
                    RegionalOffline.refreshEngineOnMapResume(application)
                    reply.success(null)
                }
                "shutdown" -> {
                    closePage(); pageId = null
                    detachProgress()
                    NBNavigation.shutdown(object : NBNavigationTaskCallback<Void> {
                        override fun onSuccess(value: Void?) {
                            main.post { initialized = false; reply.success(null) }
                        }
                        override fun onError(error: Throwable) {
                            // No registered engine already satisfies shutdown.
                            if (NBNavigation.toNavigationError(error).code.name == "OFFLINE_SDK_NOT_REGISTERED") {
                                onSuccess(null)
                            } else { reply.error(error) }
                        }
                    })
                }
                else -> reply.notImplemented()
            }
        } catch (error: Exception) {
            reply.error(error)
        }
    }

    private fun <T> invoke(reply: Reply, start: (NBNavigationTaskCallback<T>) -> Unit, encode: (T?) -> Any?) {
        start(object : NBNavigationTaskCallback<T> {
            override fun onSuccess(value: T?) {
                main.post {
                    if (!closed) try { reply.success(encode(value)) } catch (error: Exception) { reply.error(error) }
                }
            }
            override fun onError(error: Throwable) = reply.error(error)
        })
    }

    private fun <T> invokeManagement(reply: Reply, id: Long, method: String,
                                    start: (NBNavigationTaskCallback<T>) -> Unit, encode: (T?) -> Any?) {
        val callback = object : NBNavigationTaskCallback<T> {
            override fun onSuccess(value: T?) {
                main.post {
                    if (!closed) try { reply.success(encode(value)) } catch (error: Exception) { onError(error) }
                }
            }
            override fun onError(error: Throwable) {
                main.post {
                    if (!closed) FailureCheck(reply, id, method, error).start()
                }
            }
        }
        try { start(callback) } catch (error: Exception) { callback.onError(error) }
    }

    /** Combined SDK operations can fail after one subsystem has already changed.
     * Reconcile using local records and an owned observer; never retry a mutation
     * or infer that an error rolled both subsystems back. Bound the diagnostics
     * wait so an unavailable probe cannot leave the Flutter result pending. */
    private inner class FailureCheck(val reply: Reply, val id: Long, val method: String, val error: Throwable) {
        private var observer: NBNavigation.OfflineProgressSubscription? = null
        private var row: OfflineRegionProgress? = null
        private var installed: OfflineInstalledRegion? = null
        private var installedRead = false
        private var installedError: String? = null
        private var progressError: String? = null
        private var finished = false
        private val listener = OfflineProgressListener { rows ->
            main.post { if (!finished) row = rows.firstOrNull { it.regionId == id } }
        }
        private val deadline = Runnable { finish() }

        fun start() {
            failureChecks.add(this)
            main.postDelayed(deadline, 1_500)
            try {
                observer = NBNavigation.observeOfflineProgress(listener)
            } catch (failure: Exception) {
                progressError = failure.message
            }
            try {
                NBNavigation.listInstalledMapTileRegions(object : NBNavigationTaskCallback<List<OfflineInstalledRegion>> {
                    override fun onSuccess(value: List<OfflineInstalledRegion>?) {
                        main.post {
                            if (!finished) {
                                installedRead = true
                                installed = value?.firstOrNull { it.regionId.toLong() == id }
                            }
                        }
                    }
                    override fun onError(error: Throwable) {
                        main.post { if (!finished) installedError = error.message }
                    }
                })
            } catch (failure: Exception) {
                installedError = failure.message
            }
        }

        private fun finish() {
            if (finished) return
            close()
            if (closed) return
            val native = NBNavigation.toNavigationError(error)
            reply.failure(native.code.name, native.message, mapOf(
                "recoverable" to native.recoverable, "causeCode" to native.causeCode,
                "nativeType" to error.javaClass.simpleName,
                "partialOperation" to mapOf(
                    "regionId" to id, "operation" to method, "mayHaveSideEffects" to true,
                    "progress" to row?.let(::progressMap),
                    "progressError" to progressError,
                    "installedMapRead" to installedRead,
                    "installedMap" to installed?.let(::installedMap),
                    "installedMapError" to installedError,
                    "checkedAtMs" to System.currentTimeMillis())))
        }

        fun close() {
            finished = true
            main.removeCallbacks(deadline)
            observer?.cancel(); observer = null
            failureChecks.remove(this)
        }
    }

    private fun requireAccount() {
        if (!Nextbillion.hasInstance()) throw BridgeFailure("NOT_INITIALIZED", "Initialize the NextBillion account first")
    }

    private fun requireInitialized() {
        requireAccount()
        if (!initialized) throw BridgeFailure("ENGINE_NOT_INITIALIZED", "Call NBNavigation.offline.initialize first")
    }

    private fun regionId(call: MethodCall): Long {
        val value = call.argument<Any>("regionId") as? Number
            ?: throw IllegalArgumentException("regionId is required")
        val id = value.toLong()
        require(id in 1..Int.MAX_VALUE.toLong() && value.toDouble() == id.toDouble()) {
            "regionId must be a positive 32-bit integer"
        }
        return id
    }

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
        sink = eventSink
        attachProgress()
    }
    override fun onCancel(arguments: Any?) { sink = null; detachProgress() }
    private fun attachProgress() {
        if (!closed && initialized && sink != null && subscription == null) {
            subscription = NBNavigation.observeOfflineProgress(progressListener)
        }
    }
    private fun detachProgress() { subscription?.cancel(); subscription = null }

    fun onHostLifecycleChanged(lifecycle: Lifecycle?) {
        closePage()
        hostLifecycle = lifecycle
        if (pageId != null && lifecycle != null && lifecycle.currentState != Lifecycle.State.DESTROYED) openPage(lifecycle)
    }
    private fun openPage(lifecycle: Lifecycle) {
        pageOwner = PageOwner(lifecycle).also { NBNavigation.beginDownloadPage(it) }
    }
    private fun closePage() {
        pageOwner?.let { NBNavigation.endDownloadPage(it); it.close() }
        pageOwner = null
    }
    fun dispose() {
        closePage(); pageId = null
        hostLifecycle = null
        failureChecks.toList().forEach { it.close() }
        detachProgress(); sink = null
        pending.toList().forEach { it.failure("DETACHED", "Flutter engine detached") }
        closed = true
        methods.setMethodCallHandler(null)
        events.setStreamHandler(null)
    }

    private inner class Reply(private val result: MethodChannel.Result) {
        private val done = AtomicBoolean(false)
        private fun finish(block: () -> Unit) {
            main.post {
                if (done.compareAndSet(false, true)) { pending.remove(this); block() }
            }
        }
        fun success(value: Any?) = finish { result.success(value) }
        fun failure(code: String, message: String?, details: Any? = null) = finish { result.error(code, message, details) }
        fun notImplemented() = finish { result.notImplemented() }
        fun error(error: Throwable) {
            if (error is BridgeFailure) { failure(error.code, error.message); return }
            val native = NBNavigation.toNavigationError(error)
            failure(native.code.name, native.message,
                mapOf("recoverable" to native.recoverable, "causeCode" to native.causeCode,
                    "nativeType" to error.javaClass.simpleName))
        }
    }

    private class BridgeFailure(val code: String, message: String) : Exception(message)

    private class PageOwner(private val host: Lifecycle) : LifecycleOwner {
        private val registry = LifecycleRegistry(this)
        private val observer = LifecycleEventObserver { _, _ ->
            registry.currentState = host.currentState
        }
        override val lifecycle: Lifecycle get() = registry
        init { registry.currentState = host.currentState; host.addObserver(observer) }
        fun close() { host.removeObserver(observer); registry.currentState = Lifecycle.State.DESTROYED }
    }

    private fun child(state: String, errorCode: Int = 0, message: String? = null) =
        mapOf("state" to state, "errorCode" to errorCode, "message" to message)
    private fun operation(id: Long, routing: Any, map: Any) =
        mapOf("regionId" to id, "routing" to routing, "mapTiles" to map)
    private fun downloadMap(value: OfflineRegionDownloadResult) = mapOf(
        "state" to value.downloadStatus.name, "errorCode" to value.errorCode,
        "tilesDone" to value.tilesDone, "tilesTotal" to value.tilesTotal,
        "interrupted" to value.interrupted, "message" to value.interruptReason,
        "autoRetryAttempts" to value.autoRetryAttempts)
    private fun installedMap(value: OfflineInstalledRegion) = mapOf(
        "regionId" to value.regionId.toLong(), "name" to value.displayName,
        "totalBytes" to value.totalBytes, "packageCount" to value.packageCount,
        "version" to value.regionVersion, "packagesComplete" to value.allTarsOk)
    private fun regionsMap(value: OfflineRegionListResult, installed: List<OfflineInstalledRegion>, installedError: String?): Any = mapOf(
        "regions" to value.regionRows.map { row ->
            val route = row.routeRegion
            val map = row.mapRegion
            val local = installed.firstOrNull { it.regionId.toLong() == row.regionId }
            mapOf("regionId" to row.regionId, "name" to row.displayName, "country" to row.country,
                "adminL1" to row.adminL1, "adminL2" to row.adminL2, "adminL3" to row.adminL3,
                "hasRouting" to row.hasRoute, "hasMapTiles" to row.hasMap,
                "routingSizeBytes" to row.routeSizeBytes, "mapSizeBytes" to row.mapSizeBytes,
                "routingVersion" to route?.version, "mapVersion" to map?.version,
                "routingInstalled" to (route?.isDownloaded ?: false), "routingPartial" to (route?.isPartial ?: false),
                "routingUpdateAvailable" to (route?.updateAvailable ?: false),
                "mapUpdateAvailable" to (local?.regionVersion != null && map?.version != null && local.regionVersion != map.version),
                "routingTilesDone" to route?.tilesDone, "routingTilesTotal" to route?.tilesTotal)
        },
        "routingError" to value.routeError, "mapError" to value.mapError,
        "installedMapError" to installedError, "updatedAtMs" to value.updatedAtMs)
    private fun progressMap(value: OfflineRegionProgress) = mapOf(
        "regionId" to value.regionId,
        "routing" to value.routeNetwork?.let(::subtaskMap),
        "mapTiles" to value.mapTile?.let(::subtaskMap),
        "overallState" to value.overallState.name, "overallPercent" to value.overallPercent,
        "updatedAtMs" to value.updatedAtMs)
    private fun subtaskMap(value: OfflineSubtaskProgress) = mapOf(
        "state" to value.state.name, "percent" to value.safePercent,
        "downloaded" to value.downloaded, "total" to value.total,
        "message" to value.message, "error" to value.error)
}
