package io.livevoice.example

import android.app.Application
import android.content.Context
import io.livevoice.example.demo.DemoSession
import io.livevoice.sdk.android.publicApi.core.LiveVoice
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceAudioFocus
import io.livevoice.sdk.android.publicApi.core.model.LiveVoiceForegroundServiceConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope

class SampleApplication : Application() {
    /** The demo's event picker; see [DemoSession]. */
    lateinit var demoSession: DemoSession
        private set

    override fun onCreate() {
        super.onCreate()
        // Once per process, before anything else calls LiveVoice. The SDK belongs to the process,
        // not to an Activity: a recreated Activity keeps the joined event and the playing channel.
        LiveVoiceSetup.initialize(this)
        demoSession = DemoSession(this)
    }
}

/**
 * The configuration LiveVoice is initialized with, kept in one place. The SDK takes it only in
 * `initializeLiveVoice` and has no getter for it. Calling `initializeLiveVoice` again with the same
 * configuration does nothing; a different one applies only while no event is joined (the
 * connection is idle or failed) and throws otherwise. So every call passes the values in use, and
 * a change goes through [initialize] here (see the Lock screen and audio sharing screen).
 */
object LiveVoiceSetup {
    /** What happens to other audio while a channel plays. */
    var audioFocus: LiveVoiceAudioFocus = LiveVoiceAudioFocus.EXCLUSIVE
        private set

    /**
     * Whether a foreground service keeps playback going in the background and with the screen
     * off. It also shows the system's media controls: on the lock screen, in the notification
     * shade and in quick settings.
     */
    var foregroundService: LiveVoiceForegroundServiceConfig = LiveVoiceForegroundServiceConfig.Enabled
        private set

    /** Throws a `LiveVoiceException` with `INVALID_ARGUMENT` for a change while an event is joined. */
    fun initialize(
        context: Context,
        audioFocus: LiveVoiceAudioFocus = this.audioFocus,
        foregroundService: LiveVoiceForegroundServiceConfig = this.foregroundService,
    ) {
        LiveVoice.initializeLiveVoice(
            applicationContext = context,
            foregroundServiceConfig = foregroundService,
            audioFocus = audioFocus,
        )
        this.audioFocus = audioFocus
        this.foregroundService = foregroundService
    }
}

/**
 * For calls that must outlive the screen that makes them. Cancelling the coroutine of a pending
 * `joinEvent` or `switchToLinkedEvent` cancels that join, and a screen's own scope ends when the
 * screen goes away.
 */
val applicationScope: CoroutineScope = MainScope()
