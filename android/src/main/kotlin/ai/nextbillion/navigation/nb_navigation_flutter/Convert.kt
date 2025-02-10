
package ai.nextbillion.navigation.nb_navigation_flutter

import ai.nextbillion.kits.directions.models.DirectionsRoute
import ai.nextbillion.maps.location.modes.RenderMode
import ai.nextbillion.navigation.ui.NavLauncherConfig
import android.text.TextUtils

/**
 * @author qiuyu
 * @Date 2023/2/23
 **/
object Convert {
    fun convertLauncherConfig(arguments: Map<*, *>): NavLauncherConfig.Builder? {
        val routesJson = arguments["routes"] as? List<*>
        val singleRouteJson = arguments["route"] as? String
        if (!TextUtils.isEmpty(singleRouteJson)) {
            var route = DirectionsRoute.fromJson(singleRouteJson)
            val routes: MutableList<DirectionsRoute> = routesJson?.map { json -> DirectionsRoute.fromJson(json as String) }
                ?.toMutableList() ?: mutableListOf()
            if (route == null && routes.isNotEmpty()) {
                route = routes.first()
            }else if (route != null && routes.isEmpty()) {
                routes.add(route)
            }
            val configBuilder = NavLauncherConfig.builder(route)
            configBuilder.routes(routes)

            val themeMode = arguments["themeMode"] as? String
            if (!TextUtils.isEmpty(themeMode)) {
                configBuilder.themeMode(themeMode)
            }

            val locationLayerRenderMode = arguments["locationLayerRenderMode"] as? Int
            if (locationLayerRenderMode != null) {
                val nbMapRenderModes = intArrayOf(RenderMode.NORMAL, RenderMode.COMPASS, RenderMode.GPS)
                configBuilder.locationLayerRenderMode(nbMapRenderModes[locationLayerRenderMode])
            }

            val shouldSimulateRoute = arguments["shouldSimulateRoute"] as? Boolean
            if (shouldSimulateRoute != null) {
                configBuilder.shouldSimulateRoute(shouldSimulateRoute)
            }

            val wayNameChipEnabled = arguments["wayNameChipEnabled"] as? Boolean
            if (wayNameChipEnabled != null) {
                configBuilder.waynameChipEnabled(wayNameChipEnabled)
            }

            val navigationMapStyle = arguments["navigationMapStyleUrl"] as? String
            if (navigationMapStyle != null) {
                configBuilder.navigationMapStyle(navigationMapStyle)
            }

            val showSpeedometer = arguments["showSpeedometer"] as? Boolean
            configBuilder.showSpeedometer(showSpeedometer ?: true)

            val dissolvedRouteLineStyle = arguments["enableDissolvedRouteLine"] as? Boolean
            if (dissolvedRouteLineStyle != null) {
                configBuilder.dissolvedRouteEnabled(dissolvedRouteLineStyle)
            }

            val showArriveDialog = arguments["showArriveDialog"] as? Boolean
            if (showArriveDialog != null) {
                configBuilder.shouldShowArriveDialog(showArriveDialog)
            }

//            val maxNavCameraTilt = arguments["maxNavCameraTilt"] as? Float
//            if (maxNavCameraTilt != null) {
//                configBuilder.maxNavCameraTilt(maxNavCameraTilt)
//            }
//
//            val minNavCameraTilt = arguments["minNavCameraTilt"] as? Float
//            if (minNavCameraTilt != null) {
//                configBuilder.minNavCameraTilt(minNavCameraTilt)
//            }
//
//            val maxNavCameraZoom = arguments["maxNavCameraZoom"] as? Float
//            if (maxNavCameraZoom != null) {
//                configBuilder.maxNavCameraZoom(maxNavCameraZoom)
//            }
//
//            val minNavCameraZoom = arguments["minNavCameraZoom"] as? Float
//            if (minNavCameraZoom != null) {
//                configBuilder.minNavCameraZoom(minNavCameraZoom)
//            }
            return configBuilder
        }
        return null
    }
}