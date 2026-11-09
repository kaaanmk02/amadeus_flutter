import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing inputs, in priority order:
//   1. Environment variables (CI): ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD,
//      ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD
//   2. android/key.properties (local maintainer builds; git-ignored)
// Neither is ever committed. See docs/RELEASE_SIGNING.md.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

fun signingValue(envName: String, propertyName: String): String? =
    System.getenv(envName)?.takeIf { it.isNotBlank() }
        ?: (keystoreProperties[propertyName] as String?)?.takeIf { it.isNotBlank() }

val releaseStoreFile = signingValue("ANDROID_KEYSTORE_PATH", "storeFile")
val releaseStorePassword = signingValue("ANDROID_KEYSTORE_PASSWORD", "storePassword")
val releaseKeyAlias = signingValue("ANDROID_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = signingValue("ANDROID_KEY_PASSWORD", "keyPassword")
val hasReleaseSigning = listOf(
    releaseStoreFile, releaseStorePassword, releaseKeyAlias, releaseKeyPassword
).all { it != null }

// Official release builds pass -Prelease.requireSigning=true. They must fail
// loudly instead of quietly producing a debug-signed APK.
val requireReleaseSigning =
    (project.findProperty("release.requireSigning") as String?) == "true"
if (requireReleaseSigning && !hasReleaseSigning) {
    throw GradleException(
        "Release signing is required but no keystore was provided. Set the " +
            "ANDROID_KEYSTORE_* environment variables or create android/key.properties. " +
            "Refusing to fall back to the debug key."
    )
}

android {
    namespace = "com.amadeus.cristina"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        applicationId = "com.amadeus.cristina"
        minSdk = 26
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
            }
        }
    }

    buildTypes {
        release {
            // Signing config - using release keystore if available, fallback to debug for development
            // Without a release keystore (and without -Prelease.requireSigning)
            // local builds use the debug key. Such APKs are engineering
            // builds only and cannot be upgraded to a properly signed build.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            
            // Disable minification to avoid R8 issues with ML Kit dependencies
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.mlkit:text-recognition:16.0.1")
}
