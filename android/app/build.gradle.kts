plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.wedgit_quran"
    // استخدم compileSdk 34، فهو الأكثر استقراراً مع الأدوات الحديثة
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        // ✅ تحديد التوافق مع Java 17
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // ✅ تحديد التوافق مع Java 17
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.wedgit_quran"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ استخدام الإصدار الذي طلبه الخطأ السابق
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}