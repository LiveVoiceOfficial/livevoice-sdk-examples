plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.compose.compiler)
}

android {
    namespace = "io.livevoice.example"
    compileSdk = 36

    defaultConfig {
        applicationId = "io.livevoice.example"
        minSdk = 26
        targetSdk = 36
        versionCode = 1
        versionName = "2.0.0"

        vectorDrawables {
            useSupportLibrary = true
        }
    }

    signingConfigs {
        getByName("debug") {
            // Shared keystore in signing/ (all examples-private Android samples sign with it) so
            // local builds get a stable signature and stay updatable across machines. It is the
            // well-known Android debug key — not secret, sample only; sign your own app with your
            // own release key.
            storeFile = rootProject.file("../signing/sample-debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        debug {
            // Keep debug builds fast while iterating on the sample app.
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = true
        }
        release {
            // Standalone install build, signed with the shared debug keystore above (these samples
            // are not published to Play). Not minified — avoids needing ProGuard/R8 rules.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    buildFeatures {
        compose = true
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    implementation("io.livevoice.sdk:android:2.0.2")

    implementation(platform(libs.androidx.compose.bom))

    implementation(libs.material.icons.core)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.material3)
}
