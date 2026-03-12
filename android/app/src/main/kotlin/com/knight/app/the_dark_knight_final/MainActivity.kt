package com.knight.app.the_dark_knight_final

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine) // السطر ده حياتنا متوقفة عليه!
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}