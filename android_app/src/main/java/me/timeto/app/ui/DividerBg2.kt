package me.timeto.app.ui

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import me.timeto.app.ZStack
import me.timeto.app.c
import me.timeto.app.onePx

@Composable
fun DividerBg2(
    modifier: Modifier = Modifier,
    isVisible: Boolean = true,
) {
    ZStack(
        modifier = modifier
            .alpha(animateFloatAsState(if (isVisible) 1f else 0f).value)
            .height(onePx)
            .fillMaxWidth()
            .background(c.dividerBg2),
    )
}
