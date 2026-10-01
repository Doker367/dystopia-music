package com.dystopia.dystopia

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "com.dystopia.dystopia/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateWidget") {
                val title = call.argument<String>("title") ?: "DYSTOPIA"
                val artist = call.argument<String>("artist") ?: "Reproductor Cyberpunk"
                val isPlaying = call.argument<Boolean>("isPlaying") ?: false

                DystopiaAppWidgetProvider.updateAllWidgets(applicationContext, title, artist, isPlaying)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}
