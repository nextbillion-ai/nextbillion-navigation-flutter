package ai.nextbillion.navigation.nb_navigation_flutter

import ai.nextbillion.kits.directions.models.RouteRequestParams
import ai.nextbillion.kits.geojson.Point
import ai.nextbillion.kits.turf.TurfConstants
import ai.nextbillion.kits.turf.TurfMeasurement
import ai.nextbillion.kits.turf.TurfMisc
import ai.nextbillion.navigation.ui.NBNavigation
import ai.nextbillion.navigation.core.offline.RouteSource
import ai.nextbillion.kits.directions.models.DirectionsRoute
import android.os.Handler
import android.os.Looper
import java.util.concurrent.atomic.AtomicBoolean
import ai.nextbillion.navigation.core.utils.time.TimeFormatter
import ai.nextbillion.navigation.ui.event.NextBillionNavigation
import ai.nextbillion.navigation.ui.route.DefaultWayPointStyle
import ai.nextbillion.navigation.ui.view.DurationSymbol
import android.app.Activity
import android.graphics.Bitmap
import android.text.TextUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.ByteArrayOutputStream


/**
 * @author qiuyu
 * @Date 2023/3/7
 **/
class RouteFetcherHandler(methodChannel: MethodChannel?) : MethodChannelHandler() {
    init {
        this.methodChannel = methodChannel
    }
    override fun handleMethodCallResult(
        activity: Activity?,
        call: MethodCall?,
        result: MethodChannel.Result?,
    ) {
        super.handleMethodCallResult(activity, call, result)
        if (call == null || result == null) return
        if (call.method == MethodID.NAVIGATION_FETCH_ROUTE) {
            fetchRoute(call, result)
            return
        }
        if (activity == null) {
            result.error("NO_ACTIVITY", "A foreground Activity is required", null)
            return
        }

        when (call.method) {
            MethodID.NAVIGATION_FETCH_ROUTE -> {
                fetchRoute(call, result)
            }
            MethodID.NAVIGATION_FIND_SELECTED_ROUTE -> {
                findSelectedRouteIndex(call, result)
            }
            MethodID.NAVIGATION_GET_FORMATTED_ROUTE_DURATION -> {
                val arguments = call.arguments as? Map<*, *>
                val duration = arguments?.get("duration") as? Double
                var formatDuration = ""
                if (duration != null) {
                    formatDuration = TimeFormatter.formatTimeRemaining(activity, duration).toString()
                }
                result.success(formatDuration)
            }
            MethodID.NAVIGATION_CAPTURE_ROUTE_DURATION_SYMBOL -> {
                val arguments = call.arguments as? Map<*, *>
                val duration = arguments?.get("duration") as? Double
                val isPrimaryRoute = arguments?.get("isPrimaryRoute") as Boolean
                val durationSymbol = DurationSymbol(activity)
                durationSymbol.setDurationText(duration, false)
                durationSymbol.setPrimaryStatus(isPrimaryRoute)
                val bitmapSymbol = durationSymbol.shareContentShootByViewCache
                val stream = ByteArrayOutputStream()
                bitmapSymbol.compress(Bitmap.CompressFormat.PNG, 100, stream)
                val imageBytes = stream.toByteArray()
                result.success(imageBytes)
            }
            MethodID.NAVIGATION_CAPTURE_ROUTE_WAY_POINTS -> {
                val arguments = call.arguments as? Map<*, *>
                val waypointIndex = arguments?.get("waypointIndex") as Int
                var wayPointStyle = NextBillionNavigation.getInstance().wayPointStyle
                if (wayPointStyle == null) {
                    wayPointStyle = DefaultWayPointStyle()
                }
                val waypointBitmap = wayPointStyle.createWayPointBitmap(waypointIndex)

                val stream = ByteArrayOutputStream()
                waypointBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                val imageBytes = stream.toByteArray()
                result.success(imageBytes)
            }
        }
    }

    private fun findSelectedRouteIndex(call: MethodCall, result: MethodChannel.Result) {
        fun point(value: Any?): Point? {
            val pair = value as? List<*> ?: return null
            if (pair.size < 2) return null
            val latitude = (pair[0] as? Number)?.toDouble() ?: return null
            val longitude = (pair[1] as? Number)?.toDouble() ?: return null
            if (!latitude.isFinite() || !longitude.isFinite() || latitude !in -90.0..90.0 || longitude !in -180.0..180.0) return null
            return Point.fromLngLat(longitude, latitude)
        }
        val data = call.arguments as? Map<*, *>
        val clickedPoint = point(data?.get("clickPoint"))
        val coordinates = data?.get("coordinates") as? List<*>
        if (clickedPoint == null || coordinates == null) {
            result.error("INVALID_ARGUMENT", "Invalid route selection coordinates", null)
            return
        }
        val routeDistancesAwayFromClick = HashMap<Double, Int>()

        for (index in coordinates.indices) {
            val coords = coordinates[index] as? List<*>
            if (coords == null) {
                result.error("INVALID_ARGUMENT", "Invalid route selection coordinates", null)
                return
            }
            val points = arrayListOf<Point>()
            for (coord in coords) {
                val value = point(coord)
                if (value == null) {
                    result.error("INVALID_ARGUMENT", "Invalid route selection coordinates", null)
                    return
                }
                points.add(value)
            }
            if (points.size < 2) continue
            val pointOnLine = findPointOnLine(clickedPoint, points)
            pointOnLine?.let {
                val distance = TurfMeasurement.distance(clickedPoint, pointOnLine, TurfConstants.UNIT_METERS)
                routeDistancesAwayFromClick.put(distance, index)
            }
        }

        val distancesAwayFromClick: List<Double> = routeDistancesAwayFromClick.keys.sorted()
        if (distancesAwayFromClick.isNotEmpty()) {
            val routeIndex = routeDistancesAwayFromClick[distancesAwayFromClick[0]]
            result.success(routeIndex)
        } else { result.success(null) }
    }

    private fun findPointOnLine(clickPoint: Point, points: List<Point>): Point? {
        val feature = TurfMisc.nearestPointOnLine(clickPoint, points)
        return feature.geometry() as Point?
    }

    private fun fetchRoute(call: MethodCall, result: MethodChannel.Result) {
        val replied = AtomicBoolean(false)
        val main = Handler(Looper.getMainLooper())
        fun complete(value: Any) {
            main.post { if (replied.compareAndSet(false, true)) result.success(value) }
        }
        try {
            val data = call.arguments as? String
            require(!data.isNullOrEmpty()) { "Route parameters must be JSON" }
            val params = RouteRequestParams.fromJson(data)
            val builder = params.toBuilder()
            if (TextUtils.equals(params.option(), "fast")) builder.option(null)
            val json = JSONObject(data)
            if (json.has("roadInfo")) {
                val roads = json.getJSONArray("roadInfo")
                builder.roadInfo((0 until roads.length()).map { roads.getString(it) })
            }
            NBNavigation.fetchRoute(builder.build(), object : NBNavigation.SourceAwareRoutingCallback {
                override fun onRoutingReady(routes: MutableList<DirectionsRoute>, source: RouteSource) {
                    complete(mapOf("routeResult" to routes.map { it.toJson() },
                        "routeSource" to if (source == RouteSource.Offline) "offline" else "online"))
                }
                override fun onRoutingError(error: Throwable) {
                    val native = NBNavigation.toNavigationError(error)
                    complete(mapOf("message" to native.message, "errorCode" to -1,
                        "errorDetails" to mapOf("code" to native.code.name,
                            "recoverable" to native.recoverable, "causeCode" to native.causeCode)))
                }
            })
        } catch (error: Exception) {
            val native = NBNavigation.toNavigationError(error)
            complete(mapOf("message" to native.message, "errorCode" to -1,
                "errorDetails" to mapOf("code" to native.code.name,
                    "recoverable" to native.recoverable, "causeCode" to native.causeCode)))
        }
    }
}
