import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

fun signingValue(environmentName: String, propertyName: String): String? {
    return System.getenv(environmentName) ?: keystoreProperties.getProperty(propertyName)
}

fun signingStoreFile(path: String) = listOf(
    file(path),
    rootProject.file(path),
    rootProject.file("../$path")
).firstOrNull { it.exists() } ?: file(path)

val releaseStoreFile = signingValue("ANDROID_KEYSTORE_PATH", "storeFile")
val releaseStorePassword = signingValue("ANDROID_KEYSTORE_PASSWORD", "storePassword")
val releaseKeyAlias = signingValue("ANDROID_KEY_ALIAS", "keyAlias")
val releaseKeyPassword = signingValue("ANDROID_KEY_PASSWORD", "keyPassword")
val hasReleaseSigning = listOf(
    releaseStoreFile,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword
).all { !it.isNullOrBlank() }
val allowDebugReleaseSigning = (
    providers.gradleProperty("allowDebugReleaseSigning").orNull?.toBooleanStrictOrNull()
        ?: System.getenv("ALLOW_DEBUG_RELEASE_SIGNING")?.toBooleanStrictOrNull()
        ?: false
)

android {
    namespace = "dev.pulse.app"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "dev.pulse.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                val releaseStoreFilePath = releaseStoreFile!!
                storeFile = signingStoreFile(releaseStoreFilePath)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
                val releaseStoreFileName = releaseStoreFilePath.lowercase()
                if (releaseStoreFileName.endsWith(".p12") || releaseStoreFileName.endsWith(".pfx")) {
                    storeType = "pkcs12"
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else if (allowDebugReleaseSigning) {
                signingConfigs.getByName("debug")
            } else {
                throw GradleException(
                    "Release signing is required for release builds. " +
                        "Set ANDROID_KEYSTORE_PATH, ANDROID_KEYSTORE_PASSWORD, " +
                        "ANDROID_KEY_ALIAS, and ANDROID_KEY_PASSWORD, or pass " +
                        "-PallowDebugReleaseSigning=true only for local disposable builds."
                )
            }

            // Enable code shrinking and resource optimization
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // Additional optimization flags
            ndk {
                debugSymbolLevel = "full"
            }
        }
    }

    // Bundle configuration for better compression
    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}

dependencies {
    // Google Play Core library for split install support
    implementation("com.google.android.play:core:1.10.3")
}

flutter {
    source = "../.."
}
