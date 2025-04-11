package io.livevoice.sdk_testapp.sampleViews

import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.views.LoadingDisplay

val LoadingDisplaySample: LoadingDisplay = {
    val color = Color(0xFF084EFF)
    Column(
        modifier = Modifier
            .fillMaxSize() //size is limited by parent composable
            .padding(16.dp)
            .clip(RoundedCornerShape(24.dp))
            .border(1.5.dp, color, RoundedCornerShape(24.dp)),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        CircularProgressIndicator(color = color, strokeWidth = 1.5.dp)
    }
}
