plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.compose.compiler)
}

android {
    namespace = "io.livevoice.example"
    compileSdk = 37

    defaultConfig {
        applicationId = "io.livevoice.example"
        minSdk = 23
        targetSdk = 37
        versionCode = 1
        versionName = "3.0.0"

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
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false

            // Standalone install build, signed with the shared debug keystore above (these samples
            // are not published to Play). Not minified — avoids needing ProGuard/R8 rules.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
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
    implementation("io.livevoice.sdk:android:3.0.0")

    implementation(platform(libs.androidx.compose.bom))

    implementation(libs.material.icons.core)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.material3)
}

kotlin {
    jvmToolchain(21)
    compilerOptions {
        // The screens end every `when` over an SDK enum or sealed type with `else`, for the cases a
        // later SDK version may add; without it, an added case throws at runtime. Kotlin reports
        // that `else` as redundant while the type has no other cases.
        freeCompilerArgs.add("-Xwarning-level=REDUNDANT_ELSE_IN_WHEN:disabled")
    }
}
