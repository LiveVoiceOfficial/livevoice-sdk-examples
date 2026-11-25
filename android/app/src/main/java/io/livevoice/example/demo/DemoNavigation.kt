// Demo scaffolding — not needed for an integration.
// The demo's destinations, and the way demo views open one.

package io.livevoice.example.demo

import androidx.compose.runtime.staticCompositionLocalOf
import androidx.navigation.NavHostController

/** Every screen of the demo, in the order of the home list. */
enum class DemoRoute {
    Home,
    DefaultInterface,
    JoiningEvent,
    FilteringChannels,
    CustomChannelCell,
    CustomViewStates,
    Subtitles,
    AudioOutput,
    LockScreen,
    Passwords,
    LanguageRequests,
    LinkedEvents,
    Branding,
    Localization,
    Diagnostics,
}

class DemoNavigator(private val navController: NavHostController) {
    fun open(route: DemoRoute) = navController.navigate(route.name)

    fun back() {
        navController.popBackStack()
    }
}

val LocalDemoNavigator = staticCompositionLocalOf<DemoNavigator> { error("No DemoNavigator provided") }
