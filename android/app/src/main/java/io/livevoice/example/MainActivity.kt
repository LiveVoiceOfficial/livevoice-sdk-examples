package io.livevoice.example

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.collectAsState
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.lifecycle.lifecycleScope
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.LiveVoice.initializeLiveVoice
import io.livevoice.sdk.android.publicApi.core.model.ForegroundServiceConfig
import io.livevoice.example.customui.CustomChannelCellScreen
import io.livevoice.example.customui.LocalizationAndAccessibilityScreen
import io.livevoice.example.defaultui.AudioOutputPickerScreen
import io.livevoice.example.defaultui.BrandingAndEntitlementsScreen
import io.livevoice.example.defaultui.DefaultParticipantInterfaceScreen
import io.livevoice.example.defaultui.FilteredChannelListScreen
import io.livevoice.example.defaultui.SubtitleOnlyScreen
import io.livevoice.example.shared.DemoApiKeyPreset
import io.livevoice.example.shared.DemoFixture
import io.livevoice.example.shared.DemoScaffold
import io.livevoice.example.shared.DemoSession
import io.livevoice.example.shared.HomeScreen

class MainActivity : ComponentActivity() {
    private lateinit var demoSession: DemoSession

    // The SDK's background-audio foreground service posts a notification while a channel
    // plays; on Android 13+ that requires the POST_NOTIFICATIONS runtime permission.
    private val requestNotificationPermission =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { /* best-effort */ }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        requestNotificationPermissionIfNeeded()

        initializeLiveVoice(
            foregroundServiceConfig = ForegroundServiceConfig.enabledWithDefaultMessage
        )

        demoSession = DemoSession(lifecycleScope, applicationContext)
        demoSession.start()

        setContent {
            DemoApp(demoSession)
        }
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            requestNotificationPermission.launch(Manifest.permission.POST_NOTIFICATIONS)
        }
    }

    override fun onDestroy() {
        if (::demoSession.isInitialized) {
            demoSession.stop()
        }
        super.onDestroy()
    }
}

private object Routes {
    const val Home = "home"
    const val DefaultParticipant = "default-participant"
    const val FilteredChannels = "filtered-channels"
    const val AudioOutput = "audio-output"
    const val SubtitleOnly = "subtitle-only"
    const val Branding = "branding"
    const val CustomChannel = "custom-channel"
    const val Localization = "localization"
}

@Composable
private fun DemoApp(demoSession: DemoSession) {
    val navController = rememberNavController()
    val selectedPreset by demoSession.selectedPreset.collectAsState()
    val customCredentials by demoSession.customCredentials.collectAsState()

    MaterialTheme(
        colorScheme = if (isSystemInDarkTheme()) {
            darkColorScheme()
        } else {
            lightColorScheme()
        }
    ) {
        NavHost(navController = navController, startDestination = Routes.Home) {
            composable(Routes.Home) {
                DemoScaffold(
                    title = null,
                    selectedPreset = selectedPreset,
                    onPresetSelected = demoSession::select,
                    customCredentials = customCredentials,
                    onCustomCredentialsEntered = demoSession::applyCustomCredentials,
                    showTopBar = false
                ) { paddingValues ->
                    HomeScreen(
                        paddingValues = paddingValues,
                        selectedPreset = selectedPreset,
                        onPresetSelected = demoSession::select,
                        customCredentials = customCredentials,
                        onCustomCredentialsEntered = demoSession::applyCustomCredentials,
                        onDefaultParticipantClick = { navController.navigate(Routes.DefaultParticipant) },
                        onFilteredChannelsClick = { navController.navigate(Routes.FilteredChannels) },
                        onAudioOutputClick = { navController.navigate(Routes.AudioOutput) },
                        onSubtitleOnlyClick = { navController.navigate(Routes.SubtitleOnly) },
                        onBrandingClick = { navController.navigate(Routes.Branding) },
                        onCustomChannelClick = { navController.navigate(Routes.CustomChannel) },
                        onLocalizationClick = { navController.navigate(Routes.Localization) }
                    )
                }
            }

            composable(Routes.DefaultParticipant) {
                DemoScaffold(
                    title = "Default participant interface",
                    selectedPreset = selectedPreset,
                    onPresetSelected = demoSession::select,
                    customCredentials = customCredentials,
                    onCustomCredentialsEntered = demoSession::applyCustomCredentials,
                    onBack = { navController.popBackStack() }
                ) { paddingValues ->
                    DefaultParticipantInterfaceScreen(paddingValues)
                }
            }

            composable(Routes.FilteredChannels) {
                DemoScaffold(
                    title = "Filtered channel list",
                    selectedPreset = selectedPreset,
                    onPresetSelected = demoSession::select,
                    customCredentials = customCredentials,
                    onCustomCredentialsEntered = demoSession::applyCustomCredentials,
                    onBack = { navController.popBackStack() }
                ) { paddingValues ->
                    FilteredChannelListScreen(paddingValues)
                }
            }

            composable(Routes.AudioOutput) {
                DemoScaffold(
                    title = "Audio output picker",
                    selectedPreset = selectedPreset,
                    onPresetSelected = demoSession::select,
                    customCredentials = customCredentials,
                    onCustomCredentialsEntered = demoSession::applyCustomCredentials,
                    onBack = { navController.popBackStack() }
                ) { paddingValues ->
                    AudioOutputPickerScreen(paddingValues)
                }
            }

            composable(Routes.SubtitleOnly) {
                DemoScaffold(
                    title = "Subtitle only",
                    selectedPreset = selectedPreset,
                    onPresetSelected = demoSession::select,
                    customCredentials = customCredentials,
                    onCustomCredentialsEntered = demoSession::applyCustomCredentials,
                    onBack = { navController.popBackStack() }
                ) { paddingValues ->
                    SubtitleOnlyScreen(paddingValues)
                }
            }

            composable(Routes.Branding) {
                DemoScaffold(
                    title = "Branding and entitlements",
                    selectedPreset = selectedPreset,
                    onPresetSelected = demoSession::select,
                    customCredentials = customCredentials,
                    onCustomCredentialsEntered = demoSession::applyCustomCredentials,
                    onBack = { navController.popBackStack() }
                ) { paddingValues ->
                    BrandingAndEntitlementsScreen(
                        paddingValues = paddingValues,
                        selectedPreset = selectedPreset
                    )
                }
            }

            composable(Routes.CustomChannel) {
                DemoScaffold(
                    title = "Custom channel cell",
                    selectedPreset = selectedPreset,
                    onPresetSelected = demoSession::select,
                    customCredentials = customCredentials,
                    onCustomCredentialsEntered = demoSession::applyCustomCredentials,
                    onBack = { navController.popBackStack() }
                ) { paddingValues ->
                    CustomChannelCellScreen(
                        paddingValues = paddingValues
                    )
                }
            }

            composable(Routes.Localization) {
                DemoScaffold(
                    title = "Localization and accessibility",
                    selectedPreset = selectedPreset,
                    onPresetSelected = demoSession::select,
                    customCredentials = customCredentials,
                    onCustomCredentialsEntered = demoSession::applyCustomCredentials,
                    onBack = { navController.popBackStack() }
                ) { paddingValues ->
                    LocalizationAndAccessibilityScreen(paddingValues)
                }
            }
        }
    }
}
