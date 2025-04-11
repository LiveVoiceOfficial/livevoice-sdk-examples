package io.livevoice.sdk_testapp.sampleViews

import android.content.res.Configuration
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.produceState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import io.livevoice.sdk.android.publicApi.core.model.SdkRetryState
import io.livevoice.sdk.android.publicApi.core.model.SdkUiState.Error
import io.livevoice.sdk.android.publicApi.core.model.SdkUiState.Reconnecting
import io.livevoice.sdk.android.publicApi.core.model.SdkUiState.SdkUiErrorState
import io.livevoice.sdk.android.publicApi.views.ErrorDisplay
import kotlinx.coroutines.delay
import kotlin.time.Duration.Companion.seconds
import io.livevoice.sdk.android.R.string as ModelStrings

val ErrorDisplaySample: ErrorDisplay = { error: SdkUiErrorState ->
    val borderTextColor = Color(0xFF084EFF)
    Column(
        modifier = Modifier
            .fillMaxSize() //size is limited by parent composable
            .padding(16.dp)
            .clip(RoundedCornerShape(24.dp))
            .border(1.5.dp, borderTextColor, RoundedCornerShape(24.dp)),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        val textColor = Color(0xFF084EFF)

        val message = when (error) {
            is Error -> error.message
            is Reconnecting -> when (val state = error.retryState) {
                is SdkRetryState.AwaitingNextReconnectAttempt -> {
                    val secondsLeft by produceState(state.getSecondsUntilRetry()) {
                        while (true) {
                            delay(1.seconds)
                            value = state.getSecondsUntilRetry()
                        }
                    }
                    stringResource(ModelStrings.error_screen_retrying_in, secondsLeft)
                }

                SdkRetryState.RetryInProgress -> stringResource(ModelStrings.error_screen_retrying)
            }
        }

        Text(
            modifier = Modifier.padding(start = 16.dp, end = 16.dp, bottom = 8.dp),
            text = message,
            color = textColor,
            style = MaterialTheme.typography.titleMedium,
            fontSize = 22.sp,
            textAlign = TextAlign.Center
        )

        val onClickCallback: (() -> Unit)? = when (error) {
            is Reconnecting -> error.onRetry
            is Error -> error.onRetry
        }

        if (onClickCallback != null) OutlinedButton(
            onClick = onClickCallback,
            border = BorderStroke(1.5.dp, SolidColor(Color.White)),
            colors = ButtonDefaults.outlinedButtonColors(contentColor = Color.White)
        ) {
            Text("Retry")
        }
    }
}

@Preview
@Preview(uiMode = Configuration.UI_MODE_NIGHT_YES)
@Composable
private fun SampleChannelDisplayPreview_Reconnecting() {
    Box(
        modifier = Modifier
            .heightIn(max = 200.dp)
            .background(Color(0xFF283593))
    ) {
        val channel = Reconnecting(
            retryState = SdkRetryState.RetryInProgress,
            onRetry = { /* Retry logic */ })
        ErrorDisplaySample(channel)
    }
}

@Preview
@Preview(uiMode = Configuration.UI_MODE_NIGHT_YES)
@Composable
private fun SampleChannelDisplayPreview_Error() {
    Box(
        modifier = Modifier
            .heightIn(max = 200.dp)
            .background(Color(0xFF283593))
    ) {
        val channel = Error(message = "An error occurred", onRetry = { /* Retry logic */ })
        ErrorDisplaySample(channel)
    }
}

@Preview
@Preview(uiMode = Configuration.UI_MODE_NIGHT_YES)
@Composable
private fun SampleChannelDisplayPreview_Error_NoRetry() {
    Box(
        modifier = Modifier
            .heightIn(max = 200.dp)
            .background(Color(0xFF283593))
    ) {
        val channel = Error(
            message = "A fatal error occurred", onRetry = null
        )
        ErrorDisplaySample(channel)
    }
}
