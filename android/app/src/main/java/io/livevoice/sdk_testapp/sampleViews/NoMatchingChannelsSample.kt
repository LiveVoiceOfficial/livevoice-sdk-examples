package io.livevoice.sdk_testapp.sampleViews

import android.content.res.Configuration
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.views.NoMatchingChannelsDisplay

val NoMatchingChannelsSample: NoMatchingChannelsDisplay = {
    Column(
        modifier = Modifier
            .padding(16.dp)
            .heightIn(min = 74.dp)
            .fillMaxWidth()
            .background(Color.Transparent)
            .border(1.5.dp, Color(0xFF084EFF), RoundedCornerShape(50)),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "No Matching channels found!", style = MaterialTheme.typography.titleMedium,
            color = Color.White
        )
    }
}

@Preview
@Preview(uiMode = Configuration.UI_MODE_NIGHT_YES)
@Composable
private fun NoMatchingChannelsPreview() {
    NoMatchingChannelsSample()
}
