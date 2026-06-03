package io.livevoice.sdk_testapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.PagerState
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material.icons.outlined.Favorite
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.lifecycle.lifecycleScope
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.LiveVoice.initializeLiveVoice
import io.livevoice.sdk.android.publicApi.core.model.ForegroundServiceConfig
import kotlinx.coroutines.launch

/** See the README for explanations on how to use the SDK or simply explore the code. */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        /**
         * These api-keys only work for the demo event 123456, they have different claims
         * (=permissions) which configure which parts of the sdk can be customized.
         */

        val allClaims = "s09WEG5y3caQ6R2PDaG4i8R1aTooTd" //hides branding, allows customization
        val onlyHideBranding = "uFlkcGkUJEcb7jK6qFcdygreFRTXVh" //hides branding, no customization
        val noClaims = "HD4cQklUOQKOBWimG54j2kRnxFklDL" //branding shown, no customization allowed!

        initializeLiveVoice(foregroundServiceConfig = ForegroundServiceConfig.enabledWithDefaultMessage)

        lifecycleScope.launch {
            /** Await the completion of this function to know exactly when the sdk is available */
            LiveVoice.joinEvent(
                joinCode = "123456",
                password = null,
                apiKey = allClaims,
            )
        }

        setContent {
            /**
             * You can wrap the LiveVoiceView() in a MaterialTheme to change its look. Primary,
             * surface, and background colors are used to decide the colors of elements.
             */

            val pagerState = rememberPagerState(initialPage = 0, pageCount = { 2 })

            /**
             * You can warp the LiveVoiceView in a MaterialTheme to configure the background color
             */
            MaterialTheme(
                colorScheme = if (isSystemInDarkTheme())
                    darkColorScheme(background = Color.Black)
                else lightColorScheme(background = Color.White)
            ) {
                Scaffold(
                    bottomBar = { BottomBar(pagerState) }
                ) { paddingValues ->
                    HorizontalPager(
                        modifier = Modifier
                            .padding(paddingValues)
                            .fillMaxHeight(),
                        state = pagerState,
                        verticalAlignment = Alignment.Top
                    ) { page ->
                        when (page) {
                            0 -> DefaultDesignScreen()
                            1 -> CustomDesignSample()
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun BottomBar(pagerState: PagerState) {
    val scope = rememberCoroutineScope()

    NavigationBar {
        NavigationBarItem(selected = pagerState.currentPage == 0, onClick = {
            scope.launch {
                pagerState.animateScrollToPage(0)
            }
        }, icon = {
            Icon(
                if (pagerState.currentPage == 0) Icons.Filled.Favorite
                else Icons.Outlined.Favorite, null
            )
        }, label = { SampleText(text = "Default design") })

        NavigationBarItem(selected = pagerState.currentPage == 1, onClick = {
            scope.launch {
                pagerState.animateScrollToPage(1)
            }
        }, icon = {
            Icon(
                if (pagerState.currentPage == 1) Icons.Filled.Edit
                else Icons.Outlined.Edit, null
            )
        }, label = { SampleText(text = "Custom design") })
    }
}
