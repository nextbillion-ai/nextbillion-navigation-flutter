package ai.nextbillion.navigation.nb_navigation_flutter

import android.app.Activity
import android.text.TextUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * @author qiuyu
 * @Date 2023/3/7
 **/
class MethodHandleFactory(methodChannel: MethodChannel) {
    private var routeFetchHandler: RouteFetcherHandler
    private var navigationLauncherHandler: NavigationLauncherHandler
    private var nbNavigationHandler: NBNavigationHandler

    init {
        routeFetchHandler = RouteFetcherHandler(methodChannel)
        navigationLauncherHandler = NavigationLauncherHandler(methodChannel)
        nbNavigationHandler = NBNavigationHandler(methodChannel)
    }

    fun dispatchMethodHandler(
        activity: Activity?,
        call: MethodCall?,
        result: MethodChannel.Result?,
    ) {
        if (null == call || null == result) {
            return
        }
        var methodChannelHandler: MethodChannelHandler? = null
        val method = call.method
        if (TextUtils.isEmpty(method)) {
            return
        }
        when (method) {
            MethodID.NAVIGATION_FETCH_ROUTE, MethodID.NAVIGATION_FIND_SELECTED_ROUTE,
            MethodID.NAVIGATION_GET_FORMATTED_ROUTE_DURATION, MethodID.NAVIGATION_CAPTURE_ROUTE_DURATION_SYMBOL,
            MethodID.NAVIGATION_CAPTURE_ROUTE_WAY_POINTS -> methodChannelHandler =
                routeFetchHandler

            MethodID.NAVIGATION_LAUNCH_NAVIGATION, MethodID.NAVIGATION_PREVIEW_NAVIGATION -> methodChannelHandler =
                navigationLauncherHandler

            MethodID.NAVIGATION_INIT_NAVIGATION,
            MethodID.NAVIGATION_GET_ACCESS_KEY,
            MethodID.NAVIGATION_GET_BASE_URL,
            MethodID.NAVIGATION_SET_BASE_URL -> methodChannelHandler =
                nbNavigationHandler

            else -> {}
        }
        methodChannelHandler?.handleMethodCallResult(activity, call, result)
    }

    fun deInit() {
        routeFetchHandler.deInit()
        navigationLauncherHandler.deInit()
        nbNavigationHandler.deInit()
    }

}