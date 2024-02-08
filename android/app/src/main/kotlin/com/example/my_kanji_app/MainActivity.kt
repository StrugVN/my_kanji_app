package com.example.my_kanji_app

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app.channel.home"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "putAppInBackground") {
                    moveTaskToBack(true)
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
    }
}
