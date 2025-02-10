package ai.nextbillion.navigation.nb_navigation_flutter

import ai.nextbillion.kits.directions.models.DirectionsRoute
import ai.nextbillion.kits.geojson.Point
import ai.nextbillion.navigation.core.navigation.NavigationConstants
import ai.nextbillion.navigation.core.navigator.NavProgress
import ai.nextbillion.navigation.core.navigator.ProgressChangeListener
import ai.nextbillion.navigation.nb_navigation_flutter.databinding.NavigationActivityBinding
import ai.nextbillion.navigation.ui.NavLauncherConfig
import ai.nextbillion.navigation.ui.NavViewConfig
import ai.nextbillion.navigation.ui.NavigationView
import ai.nextbillion.navigation.ui.OnNavigationReadyCallback
import ai.nextbillion.navigation.ui.listeners.NavigationListener
import ai.nextbillion.navigation.ui.listeners.RouteListener
import android.app.Activity
import android.location.Location
import android.view.View
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import com.google.android.material.bottomsheet.BottomSheetDialog
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * @author qiuyu
 * @Date 2024/6/24
 **/

class NBNavigationView(
    private val activity: Activity,
    private val binding: NavigationActivityBinding,
    binaryMessenger: BinaryMessenger,
    vId: Int,
    private val args: Map<*, *>?
) : PlatformView, MethodChannel.MethodCallHandler, EventChannel.StreamHandler,
    OnNavigationReadyCallback,
    NavigationListener, RouteListener, DefaultLifecycleObserver,
    ProgressChangeListener {
    private var methodChannel: MethodChannel? = null
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    private val viewId: Int = vId
    private val messenger: BinaryMessenger = binaryMessenger
    private var navigationView: NavigationView? = null
    private var lifecycleProvider: NbNavigationFlutterPlugin.LifecycleProvider? = null

    private var viewConfigBuilder: NavViewConfig.Builder = NavViewConfig.builder()
    private var inTunnelMode = false

    fun initialize(lifecycleProvider: NbNavigationFlutterPlugin.LifecycleProvider) {
        initFlutterChannelHandlers()
        this.lifecycleProvider = lifecycleProvider
        lifecycleProvider.lifecycle?.addObserver(this)
    }
    private fun initFlutterChannelHandlers() {
        navigationView = binding.navigationView
        methodChannel = MethodChannel(messenger, "flutter_nb_navigation/${viewId}")
        eventChannel = EventChannel(messenger, "flutter_nb_navigation/${viewId}/events")
        methodChannel?.setMethodCallHandler(this)
        eventChannel?.setStreamHandler(this)
    }

    override fun onCreate(owner: LifecycleOwner) {
        super.onCreate(owner)
        navigationView?.onCreate(null)
        navigationView?.initialize(this)
    }

    override fun onNavigationReady(isRunning: Boolean) {
        viewConfigBuilder = NavViewConfig.builder()
        viewConfigBuilder.navigationListener(this)
        viewConfigBuilder.routeListener(this)
        viewConfigBuilder.progressChangeListener(this)

        val config = args?.get("launcherConfig") as? Map<*, *>
        config?.let {
            val configBuilder = Convert.convertLauncherConfig(it)
            if (configBuilder?.build()?.routes()?.isEmpty() == true) {
                return
            }
            configViewBuilder(configBuilder, config)
            extractRoute(configBuilder)
            navigationView?.startNavigation(viewConfigBuilder.build())

            methodChannel?.invokeMethod("onNavigationReady", isRunning)

        }

    }

    private fun extractRoute(configBuilder: NavLauncherConfig.Builder?) {
        configBuilder?.build()?.let {
            viewConfigBuilder.routes(it.routes())
            viewConfigBuilder.route(it.routes().first())
        }
    }

    private fun configViewBuilder(configBuilder: NavLauncherConfig.Builder?, config: Map<*, *>) {
        configBuilder?.build()?.let {
            viewConfigBuilder.locationLayerRenderMode(it.locationLayerRenderMode())
            viewConfigBuilder.darkModeInTunnel(it.darkModeInTunnel())
            viewConfigBuilder.shouldSimulateRoute(it.shouldSimulateRoute())
            viewConfigBuilder.showSpeedometer(it.showSpeedometer())
        }
    }

    override fun getView(): View {
        return binding.root
    }

    override fun dispose() {
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "stopNavigation" -> {
                navigationView?.onPause()
                navigationView?.onStop()
                navigationView?.onDestroy()
                navigationView = null
                result.success(null)
            }
        }

    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onProgressChange(location: Location?, navProgress: NavProgress?) {
        if (navProgress != null) {
            val resultMap = mutableMapOf<String, Any?>()
            resultMap["location"] = mutableMapOf(
                "latitude" to location?.latitude,
                "longitude" to location?.longitude
            )
            resultMap["distanceRemaining"] = navProgress.distanceRemaining
            resultMap["durationRemaining"] = navProgress.durationRemaining
            resultMap["currentLegIndex"] = navProgress.currentLegIndex
            resultMap["currentStepIndex"] = navProgress.currentStepIndex
            resultMap["distanceTraveled"] = navProgress.distanceTraveled
            resultMap["fractionTraveled"] = navProgress.fractionTraveled
            resultMap["remainingWaypoints"] = navProgress.remainingWaypoints
            resultMap["currentStepPointIndex"] = navProgress.currentStepPointIndex
            resultMap["isFinalLeg"] = navProgress.currentLegIndex == navProgress.route.legs()?.size?.minus(1)
            eventSink?.success(resultMap)
        } else {
            eventSink?.success(null)
        }

    }


    override fun onCancelNavigation() {
        methodChannel?.invokeMethod("onNavigationCancelling", null)
    }

    override fun onNavigationFinished() {
        methodChannel?.invokeMethod("onNavigationCancelling", null)
    }

    override fun onNavigationRunning() {
    }

    override fun allowRerouteFrom(p0: Location?): Boolean {
        return true
    }

    override fun onOffRoute(location: Point?) {
        val resultMap = mutableMapOf<String, Any?>()
        resultMap["location"] = mutableMapOf(
            "latitude" to location?.latitude(),
            "longitude" to location?.longitude()
        )
        methodChannel?.invokeMethod("willRerouteFromLocation", resultMap)
    }

    override fun onRerouteAlong(p0: DirectionsRoute?) {
        methodChannel?.invokeMethod("onRerouteAlong", p0?.toJson())
    }

    override fun onFailedReroute(p0: String?) {
        methodChannel?.invokeMethod("onFailedReroute", p0)
    }

    override fun onArrival(navProgress: NavProgress?, waypointIndex: Int) {
        if (navProgress != null) {
            val resultMap = mutableMapOf<String, Any?>()
            val last = navProgress.currentLegProgress.routeLeg.steps()?.last()

            resultMap["location"] = mutableMapOf(
                "latitude" to last?.maneuver()?.location()?.latitude(),
                "longitude" to last?.maneuver()?.location()?.longitude()
            )
            resultMap["arrivedWaypointIndex"] = waypointIndex
            methodChannel?.invokeMethod("onArriveAtWaypoint", resultMap)
        }

    }

    override fun onUserInTunnel(inTunnel: Boolean) {

    }

    override fun shouldShowArriveDialog(p0: NavProgress?, p1: Int): Boolean {
        return false
    }

    override fun customArriveDialog(p0: NavProgress?, p1: Int): BottomSheetDialog? {
        return null
    }


    override fun onStart(owner: LifecycleOwner) {
        super.onStart(owner)
        navigationView?.onStart()
    }

    override fun onResume(owner: LifecycleOwner) {
        super.onResume(owner)
        navigationView?.onResume()
    }

    override fun onPause(owner: LifecycleOwner) {
        super.onPause(owner)
        navigationView?.onPause()
    }

    override fun onStop(owner: LifecycleOwner) {
        super.onStop(owner)
        navigationView?.onStop()
    }

    override fun onDestroy(owner: LifecycleOwner) {
        super.onDestroy(owner)
        navigationView?.onDestroy()
    }

}
