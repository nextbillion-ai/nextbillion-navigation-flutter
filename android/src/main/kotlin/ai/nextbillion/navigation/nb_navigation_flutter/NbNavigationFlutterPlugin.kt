package ai.nextbillion.navigation.nb_navigation_flutter

import ai.nextbillion.navigation.factory.EmbeddedNavigationViewFactory
import android.app.Activity
import androidx.annotation.NonNull
import androidx.lifecycle.Lifecycle
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.platform.PlatformViewRegistry

/** NbNavigationFlutterPlugin */
class NbNavigationFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private var activity: Activity? = null
  private lateinit var navigationChannel: MethodChannel
  private var methodHandleFactory: MethodHandleFactory?  = null
  private var platformViewRegistry: PlatformViewRegistry? = null
  private var binaryMessenger: BinaryMessenger? = null
  private var viewId = "FlutterNBNavigationView"
  private var activityLifecycle: Lifecycle? = null
  private var offlineHandler: OfflineNavigationHandler? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
    offlineHandler = OfflineNavigationHandler(flutterPluginBinding.binaryMessenger, flutterPluginBinding.applicationContext)
    navigationChannel = MethodChannel(flutterPluginBinding.binaryMessenger, Constants.NAVIGATION_CHANNEL)
    methodHandleFactory = MethodHandleFactory(navigationChannel)
    navigationChannel.setMethodCallHandler(this)
    flutterPluginBinding.platformViewRegistry.registerViewFactory(
      viewId,
      EmbeddedNavigationViewFactory(flutterPluginBinding.binaryMessenger, { activity }, object : LifecycleProvider {
        override val lifecycle: Lifecycle? get() = activityLifecycle
      })
    )
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    methodHandleFactory?.dispatchMethodHandler(activity, call, result)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    offlineHandler?.dispose()
    offlineHandler = null
    navigationChannel.setMethodCallHandler(null)
    methodHandleFactory?.deInit()
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityLifecycle = FlutterLifecycleAdapter.getActivityLifecycle(binding)
    offlineHandler?.onHostLifecycleChanged(activityLifecycle)

    activity = binding.activity

  }

  override fun onDetachedFromActivityForConfigChanges() {
    this.onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    this.onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    offlineHandler?.onHostLifecycleChanged(null)
    activity = null
    activityLifecycle = null
  }

  interface LifecycleProvider {
    val lifecycle: Lifecycle?
  }

  /** Provides a static method for extracting lifecycle objects from Flutter plugin bindings.  */
  object FlutterLifecycleAdapter {
    /**
     * Returns the lifecycle object for the activity a plugin is bound to.
     *
     *
     * Returns null if the Flutter engine version does not include the lifecycle extraction code.
     * (this probably means the Flutter engine version is too old).
     */
    fun getActivityLifecycle(
      activityPluginBinding: ActivityPluginBinding
    ): Lifecycle {
      val reference = activityPluginBinding.lifecycle as HiddenLifecycleReference
      return reference.lifecycle
    }
  }
}
