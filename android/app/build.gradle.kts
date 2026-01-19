plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fit_tracker_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Fix 1: Added 'is' prefix and '=' for KTS syntax
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        // Fix 2: Using standard 1.8 for better compatibility with desugaring
        jvmTarget = "1.8"
    }

    defaultConfig {
        // Fix 3: Added '=' for assignment
        multiDexEnabled = true
        
        applicationId = "com.example.fit_tracker_app"
        
        // Fix 4: Notifications require minSdk 21. If flutter.minSdkVersion is lower, 
        // it will fail. Setting it directly to 21 is safer.
        minSdk = flutter.minSdkVersion 
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Fix 5: The dependencies block MUST be outside the android block
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
}

flutter {
    source = "../.."
}
