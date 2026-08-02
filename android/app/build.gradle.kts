import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Upload-key credentials, kept out of version control. Create android/key.properties
// from android/key.properties.example — see RELEASE.md. When it is absent (CI
// without secrets, or a fresh clone) release falls back to the debug key so
// `flutter build` still works locally.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.apsarawallet.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Permanent Play Store identity — cannot be changed after publishing.
        applicationId = "com.apsarawallet.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Google ML Kit text recognition + camera require API 21+; use 24 to
        // stay comfortably above the plugins' floor.
        minSdk = maxOf(24, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // No upload key present: sign with debug so local release
                // builds still run. Such an APK CANNOT be uploaded to Play.
                logger.warn(
                    "WARNING: android/key.properties not found — signing the " +
                        "release build with the DEBUG key. This artifact is not " +
                        "uploadable to Play. See RELEASE.md."
                )
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // On-device Latin text recognition for the receipt scanner (Android side
    // of the `apsara/ocr` channel; iOS uses Apple Vision).
    implementation("com.google.mlkit:text-recognition:16.0.1")
}
