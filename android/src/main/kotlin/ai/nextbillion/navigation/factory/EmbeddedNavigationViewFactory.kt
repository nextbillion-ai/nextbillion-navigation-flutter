package ai.nextbillion.navigation.factory

import ai.nextbillion.navigation.core.navigation.NavigationConstants
import ai.nextbillion.navigation.nb_navigation_flutter.NBNavigationView
import ai.nextbillion.navigation.nb_navigation_flutter.NbNavigationFlutterPlugin
import ai.nextbillion.navigation.nb_navigation_flutter.R
import ai.nextbillion.navigation.nb_navigation_flutter.databinding.NavigationActivityBinding
import android.app.Activity
import android.content.Context
import android.preference.PreferenceManager
import android.text.TextUtils
import android.view.LayoutInflater
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class EmbeddedNavigationViewFactory(
    private val messenger: BinaryMessenger,
    private val activity: Activity,
    private val lifecycleProvider: NbNavigationFlutterPlugin.LifecycleProvider
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        storeNavThemeConfig(context, args)

        val inflater = LayoutInflater.from(context)
        val binding = NavigationActivityBinding.inflate(inflater)
        val view = NBNavigationView(
            activity,
            binding,
            messenger,
            viewId,
            args as Map<*, *>?
        )

        view.initialize(lifecycleProvider)

        return view
    }

    private fun storeNavThemeConfig(context: Context, args: Any?) {
        val editor = PreferenceManager.getDefaultSharedPreferences(context).edit()
        val config = (args as Map<*, *>?)?.get("launcherConfig") as? Map<*, *>

        config?.let {
            val navigationMapStyle = config["navigationMapStyleUrl"] as? String
            editor.putString(NavigationConstants.NAVIGATION_MAP_STYLE_KEY, navigationMapStyle).apply()

            val enableCustomStyle = it["useCustomNavigationStyle"] as? Boolean ?: true
            if (enableCustomStyle) {
                editor.putBoolean(NavigationConstants.NAVIGATION_VIEW_PREFERENCE_SET_THEME, true).apply()
                editor.putInt(NavigationConstants.NAVIGATION_VIEW_LIGHT_THEME, R.style.CustomNavigationViewLight).apply()
                editor.putInt(NavigationConstants.NAVIGATION_VIEW_DARK_THEME, R.style.CustomNavigationViewDark).apply()
            } else {
                editor.putBoolean(NavigationConstants.NAVIGATION_VIEW_PREFERENCE_SET_THEME, false).apply()
            }

            val themeMode = config["themeMode"] as? String
            if (!TextUtils.isEmpty(themeMode)) {
                editor.putString(NavigationConstants.NAVIGATION_VIEW_THEME_MODE, themeMode).apply()
            }
        }
    }
}

