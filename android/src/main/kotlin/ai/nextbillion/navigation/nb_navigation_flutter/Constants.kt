package ai.nextbillion.navigation.nb_navigation_flutter

/**
 * @author qiuyu
 * @Date 2023/3/8
 **/
object Constants {

    const val NAVIGATION_CHANNEL = "nb_navigation_flutter"


}

object MethodID {
    const val NAVIGATION_FETCH_ROUTE = "route/fetchRoute"
    const val NAVIGATION_FIND_SELECTED_ROUTE = "route/findSelectedRouteIndex"
    const val NAVIGATION_GET_FORMATTED_ROUTE_DURATION = "format/routeDuration"
    const val NAVIGATION_CAPTURE_ROUTE_DURATION_SYMBOL = "capture/routeDurationSymbol"
    const val NAVIGATION_CAPTURE_ROUTE_WAY_POINTS = "capture/routeWayPoints"

    const val NAVIGATION_GET_BASE_URL = "navigation/getBaseUri"
    const val NAVIGATION_SET_BASE_URL = "navigation/setBaseUri"
    const val NAVIGATION_LAUNCH_NAVIGATION = "navigation/startNavigation"
    const val NAVIGATION_ON_NAVIGATION_EXIT = "navigation/onNavigationExit"
    const val NAVIGATION_PREVIEW_NAVIGATION = "navigation/previewNavigation";

    const val NAVIGATION_INIT_NAVIGATION = "config/initNBNavigation"
    const val NAVIGATION_GET_ACCESS_KEY = "config/getAccessKey"
}

object ResultID {
    const val NAVIGATION_ROUTE_RESULT = "route/routeResult"

}