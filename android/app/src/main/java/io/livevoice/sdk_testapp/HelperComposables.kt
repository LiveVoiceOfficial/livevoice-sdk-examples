package io.livevoice.sdk_testapp

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.LocalTextStyle
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.isUnspecified
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import io.livevoice.sdk.android.publicApi.core.model.subtitle.AvailableSubtitle

@Composable
fun SampleSpacer() {
    Spacer(modifier = Modifier.padding(24.dp))
}

@Composable
fun SampleText(
    text: String,
    modifier: Modifier = Modifier,
    color: Color = Color.Unspecified,
    style: TextStyle = LocalTextStyle.current,
    textAlign: TextAlign = TextAlign.Start,
) {
    Text(
        modifier = modifier,
        style = style,
        text = text,
        textAlign = textAlign,
        color = if (color.isUnspecified) MaterialTheme.colorScheme.onBackground else color
    )
}

@Composable
fun SampleDropdownMenu(
    elements: Collection<AvailableSubtitle?>,
    selected: AvailableSubtitle?,
    onSelect: (AvailableSubtitle?) -> Unit,
) {
    var expanded by remember { mutableStateOf(false) }

    val automaticString = "Automatic"

    Box {
        Button(
            border = BorderStroke(1.dp, MaterialTheme.colorScheme.onBackground),
            shape = RoundedCornerShape(12.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.background,
            ),
            onClick = { expanded = true }
        ) {
            SampleText(
                text = "Chosen subtitle:  ${selected?.name ?: automaticString}",
                color = MaterialTheme.colorScheme.onBackground
            )
        }

        // Dropdown menu
        DropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            for (element in elements) {
                DropdownMenuItem(
                    text = { SampleText(element?.name ?: automaticString) },
                    onClick = {
                        onSelect(element)
                        expanded = false
                    }
                )
            }
        }
    }
}
