package ai.nextbillion.navigation.nb_navigation_flutter

import ai.nextbillion.kits.directions.models.DirectionsResponse
import ai.nextbillion.kits.directions.models.RouteRequestParams
import ai.nextbillion.kits.geojson.Point
import ai.nextbillion.kits.turf.TurfConstants
import ai.nextbillion.kits.turf.TurfMeasurement
import ai.nextbillion.kits.turf.TurfMisc
import ai.nextbillion.navigation.core.routefetcher.RouteFetcher
import ai.nextbillion.navigation.core.utils.time.TimeFormatter
import ai.nextbillion.navigation.ui.event.NextBillionNavigation
import ai.nextbillion.navigation.ui.route.DefaultWayPointStyle
import ai.nextbillion.navigation.ui.view.DurationSymbol
import android.app.Activity
import android.graphics.Bitmap
import android.text.TextUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONException
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
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
        if (activity == null || call == null || result == null) {
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
        val data = call.arguments as Map<*, *>
        val clicked: List<Double> = data["clickPoint"] as List<Double>
        val clickedPoint = Point.fromLngLat(clicked[1], clicked[0])
        val coordinates: List<List<List<Double>>> = data["coordinates"] as List<List<List<Double>>>
        val routeDistancesAwayFromClick = HashMap<Double, Int>()

        for (index in coordinates.indices) {
            val coords = coordinates[index]
            val points = arrayListOf<Point>()
            for (coord in coords) {
                val point = Point.fromLngLat(coord[1], coord[0])
                points.add(point)
            }
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
        }
    }

    private fun findPointOnLine(clickPoint: Point, points: List<Point>): Point? {
        val feature = TurfMisc.nearestPointOnLine(clickPoint, points)
        return feature.geometry() as Point?
    }

    private fun fetchRoute(call: MethodCall, result: MethodChannel.Result) {
        val data = call.arguments as? String
        if (data == null || data.isEmpty()) {
            return
        }
        val params = RouteRequestParams.fromJson(data.toString())
        val paramsBuilder = params.toBuilder()
        if (TextUtils.equals(params.option(), "fast")) {
            paramsBuilder.option(null)
        }
        RouteFetcher.getRoute(paramsBuilder.build(), object : Callback<DirectionsResponse> {
            override fun onResponse(call: Call<DirectionsResponse>, response: Response<DirectionsResponse>) {
                val args = mutableMapOf<String, Any>()
                if (response.code() >= 200 && response.code() < 300) {
                    val routes = response.body()?.routes()
                    if (!routes.isNullOrEmpty()) {
                        val routeArray = mutableListOf<String>()
                        for (route in routes) {
                            routeArray.add(route.toJson())
                        }
                        args["routeResult"] = routeArray
                    }
                } else {
                    val errorMessage = response.errorBody()!!.charStream().readText()
                    val httpErrorCode = response.code()
                    var jsonObj: JSONObject? = null
                     try {
                         jsonObj = JSONObject(errorMessage)
                         val errorMsg = jsonObj.getString("msg")
                         val errorCode = jsonObj.getInt("status")
                         args["message"] = errorMsg
                         args["errorCode"] = errorCode
                    } catch (e: JSONException) {
                         args["message"] = errorMessage.ifEmpty { "Request failed" }
                         args["errorCode"] = httpErrorCode
                     }
                }
                result.success(args)

            }

            override fun onFailure(call: Call<DirectionsResponse>, t: Throwable) {
                val args = mutableMapOf<String,Any>()
                args["message"] = t?.message ?: "Request failed"
                args["errorCode"] = -1
                result.success(args)
            }

        })


    }

}