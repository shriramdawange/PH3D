pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Pinned below AGP 9: flutter_inappwebview_android:1.1.3 (transitive via
    // flutter_3d_controller 2.3.0) calls
    // getDefaultProguardFile('proguard-android.txt'), which AGP 9 turns into
    // a hard evaluation error. Upstream master already switched to
    // proguard-android-optimize.txt, but no stable pub release contains the
    // fix yet. Revisit on the next stable flutter_inappwebview release.
    // Regression guard: CI job build-android (it failed on AGP 9.1.0).
    id("com.android.application") version "8.13.1" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
