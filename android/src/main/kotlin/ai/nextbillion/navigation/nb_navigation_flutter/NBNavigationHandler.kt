package ai.nextbillion.navigation.nb_navigation_flutter

import ai.nextbillion.maps.Nextbillion
import ai.nextbillion.navigation.core.routefetcher.RoutingAPIUtils
import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * @author qiuyu
 * @Date 2023/3/7
 **/
class NBNavigationHandler(methodChannel: MethodChannel?) : MethodChannelHandler() {

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
            MethodID.NAVIGATION_INIT_NAVIGATION -> {
                activity.let {
                    val args = call.arguments as? Map<*, *>
                    Nextbillion.getInstance(it.applicationContext, args?.get("accessKey")?.toString())
                }
                result.success(true)
            }
            MethodID.NAVIGATION_GET_ACCESS_KEY -> {
                val accessKey = Nextbillion.getAccessKey()
                result.success(accessKey)
            }

            MethodID.NAVIGATION_GET_BASE_URL -> {
                val navigationBaseUri = RoutingAPIUtils.getBaseUri()
                result.success(navigationBaseUri)
            }

            MethodID.NAVIGATION_SET_BASE_URL -> {
                val args = call.arguments as? Map<*, *>
                RoutingAPIUtils.setBaseUri(args?.get("navigationBaseUri")?.toString())
                result.success(true)
            }
        }
    }

}