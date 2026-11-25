package io.livevoice.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.remember
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import io.livevoice.example.demo.DemoEventPickerHost
import io.livevoice.example.demo.DemoNavigator
import io.livevoice.example.demo.DemoRoute
import io.livevoice.example.demo.DemoSession
import io.livevoice.example.demo.LocalDemoNavigator
import io.livevoice.example.demo.LocalDemoSession
import io.livevoice.example.screens.audioandsystem.AudioOutputScreen
import io.livevoice.example.screens.audioandsystem.LockScreenScreen
import io.livevoice.example.screens.channels.CustomChannelCellScreen
import io.livevoice.example.screens.channels.CustomViewStatesScreen
import io.livevoice.example.screens.channels.FilteringChannelsScreen
import io.livevoice.example.screens.customization.BrandingScreen
import io.livevoice.example.screens.customization.DiagnosticsScreen
import io.livevoice.example.screens.customization.LocalizationScreen
import io.livevoice.example.screens.eventfeatures.LanguageRequestsScreen
import io.livevoice.example.screens.eventfeatures.LinkedEventsScreen
import io.livevoice.example.screens.eventfeatures.PasswordsScreen
import io.livevoice.example.screens.gettingstarted.DefaultInterfaceScreen
import io.livevoice.example.screens.gettingstarted.JoiningEventScreen
import io.livevoice.example.screens.subtitles.SubtitlesScreen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        // The demo joins the event picked in the toolbar once the app shows. LiveVoice itself is
        // initialized in SampleApplication, once per process.
        val demoSession = (application as SampleApplication).demoSession
        demoSession.start()

        setContent {
            SampleApp(demoSession)
        }
    }
}

@Composable
private fun SampleApp(demoSession: DemoSession) {
    val navController = rememberNavController()
    val navigator = remember(navController) { DemoNavigator(navController) }

    MaterialTheme(colorScheme = if (isSystemInDarkTheme()) darkColorScheme() else lightColorScheme()) {
        CompositionLocalProvider(
            LocalDemoSession provides demoSession,
            LocalDemoNavigator provides navigator,
        ) {
            NavHost(navController = navController, startDestination = DemoRoute.Home.name) {
                composable(DemoRoute.Home.name) { HomeScreen() }
                composable(DemoRoute.DefaultInterface.name) { DefaultInterfaceScreen() }
                composable(DemoRoute.JoiningEvent.name) { JoiningEventScreen() }
                composable(DemoRoute.FilteringChannels.name) { FilteringChannelsScreen() }
                composable(DemoRoute.CustomChannelCell.name) { CustomChannelCellScreen() }
                composable(DemoRoute.CustomViewStates.name) { CustomViewStatesScreen() }
                composable(DemoRoute.Subtitles.name) { SubtitlesScreen() }
                composable(DemoRoute.AudioOutput.name) { AudioOutputScreen() }
                composable(DemoRoute.LockScreen.name) { LockScreenScreen() }
                composable(DemoRoute.Passwords.name) { PasswordsScreen() }
                composable(DemoRoute.LanguageRequests.name) { LanguageRequestsScreen() }
                composable(DemoRoute.LinkedEvents.name) { LinkedEventsScreen() }
                composable(DemoRoute.Branding.name) { BrandingScreen() }
                composable(DemoRoute.Localization.name) { LocalizationScreen() }
                composable(DemoRoute.Diagnostics.name) { DiagnosticsScreen() }
            }
            DemoEventPickerHost()
        }
    }
}
