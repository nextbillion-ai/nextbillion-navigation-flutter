package ai.nextbillion.navigation.nb_navigation_flutter

import ai.nextbillion.kits.directions.models.DirectionsRoute
import ai.nextbillion.navigation.core.navigation.NavigationResultEventDispatcher
import ai.nextbillion.navigation.core.navigation.NavigationResultListener
import ai.nextbillion.navigation.nb_navigation_flutter.MethodID.NAVIGATION_ON_NAVIGATION_EXIT
import ai.nextbillion.navigation.ui.NavigationLauncher
import ai.nextbillion.navigation.ui.NextBillionPreviewActivity
import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * @author qiuyu
 * @Date 2023/3/7
 **/
class NavigationLauncherHandler(methodChannel: MethodChannel?) : MethodChannelHandler() {
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
            MethodID.NAVIGATION_LAUNCH_NAVIGATION -> {
                startNavigation(call)
                result.success(true)
            }
            MethodID.NAVIGATION_PREVIEW_NAVIGATION -> {
                val arguments = call.arguments as? Map<*, *>
                val routeJson = arguments?.get("route") as? String
                routeJson?.let {
                    val directionsRoute = DirectionsRoute.fromJson(routeJson)
                    val intent = Intent(activity, NextBillionPreviewActivity::class.java)
                    intent.putExtra(
                        "directions_route_key",
                        directionsRoute
                    )
                    activity.startActivity(intent)
                }
                result.success(true)
            }
        }
    }

    private fun startNavigation(call: MethodCall) {
        val arguments = call.arguments as? Map<*, *>
        val config = arguments?.get("launcherConfig") as? Map<*, *>
        config?.let {
            val configBuilder = Convert.convertLauncherConfig(it)
            val enableCustomStyle = it["useCustomNavigationStyle"] as? Boolean ?: true
            if (enableCustomStyle) {
                configBuilder?.lightThemeResId(R.style.CustomNavigationViewLight)
                configBuilder?.darkThemeResId(R.style.CustomNavigationViewDark)
            }
            val navLauncherConfig = configBuilder?.build()
            if (navLauncherConfig != null && activity != null) {
                NavigationLauncher.startNavigation(activity, navLauncherConfig)
            }
        }
        NavigationResultEventDispatcher.getInstance().setNavigationResultListeners(mResultListener)
    }

    private var mResultListener =
        NavigationResultListener { shouldRefreshRoute, restWayPointsCount ->
            val arguments: MutableMap<String, Any> = HashMap(2)
            arguments["shouldRefreshRoute"] = shouldRefreshRoute
            arguments["remainingWaypoints"] = restWayPointsCount
            this.methodChannel?.invokeMethod(NAVIGATION_ON_NAVIGATION_EXIT, arguments)
        }

    override fun deInit() {
        super.deInit()
        NavigationResultEventDispatcher.getInstance().removeNavigationResultListeners(mResultListener)
    }
}