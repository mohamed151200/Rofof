# حفظ كل ما يتعلق بفلاتر والبلوجنز من الحذف
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class com.google.firebase.** { *; }
-keep class dev.flutter.pigeon.** { *; }
-keep class io.flutter.plugins.** { *; }

# مهم جداً للـ path_provider والـ google_fonts
-keep class com.baseflow.pathprovider.** { *; }
# الحفاظ على الـ Native methods (دي أهم حاجة للـ Channels)
-keepclasseswithmembernames class * {
    native <methods>;
}

# الحفاظ على الـ GeneratedPluginRegistrant (القلب النابض للربط)
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# لو بتستخدم Google Fonts أو Dio، السطرين دول أمان ليك
-keepattributes Signature,Annotation,EnclosingMethod
-keep class com.google.gson.** { *; }