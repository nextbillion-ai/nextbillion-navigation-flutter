package ai.nextbillion.navigation.nb_navigation_flutter

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * @author qiuyu
 * @Date 2023/3/8
 **/
abstract class MethodChannelHandler {

    var activity: Activity? = null
    var methodChannel: MethodChannel? =null

    open fun handleMethodCallResult(
        activity: Activity?,
        call: MethodCall?,
        result: MethodChannel.Result?,
    ) {
        this.activity = activity
    }

    open fun deInit() {}
}