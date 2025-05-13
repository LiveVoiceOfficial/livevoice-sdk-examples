plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.jetbrains.kotlin.android)
    id("org.jetbrains.kotlin.plugin.serialization") version "2.1.20"
    id("kotlin-parcelize") //needed or app won't compile due to SDK issue
    alias(libs.plugins.compose.compiler)
    idea
}

idea {
    module {
        isDownloadSources = true
        isDownloadJavadoc = true
    }
}

android {
    namespace = "io.livevoice.sdk_testapp"
    compileSdk = 35

    defaultConfig {
        applicationId = "io.livevoice.sample"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"

        vectorDrawables {
            useSupportLibrary = true
        }
    }

    buildTypes {
        debug {
            //there is no signing-config, so we use a minified/non-debuggable debug build
            // to emulate a release build
            isMinifyEnabled = true
            isDebuggable = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
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
    //noinspection UseTomlInstead
    implementation("io.livevoice.sdk:android:1.0.1")

    //for animation in custom sample button
    implementation(libs.lottie.compose)

    //version definitions for all compose libraries
    implementation(platform(libs.androidx.compose.bom))

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)
    debugImplementation(libs.androidx.ui.tooling)
}


// You can rename the file to `build.gradle`, and use the commented-out code below
// to see how to use groovy-based build files!
//
//plugins {
//    id 'com.android.application'
//    id 'org.jetbrains.kotlin.android'
//    id 'org.jetbrains.kotlin.plugin.serialization' version '2.1.20'
//    id 'kotlin-parcelize' // Needed or app won't compile due to SDK issue
//    id 'org.jetbrains.kotlin.plugin.compose' version '2.1.0'
//    id 'idea'
//}
//
//idea {
//    module {
//        downloadSources = true
//        downloadJavadoc = true
//    }
//}
//
//android {
//    namespace 'io.livevoice.sdk_testapp'
//    compileSdk 35
//
//    defaultConfig {
//        applicationId 'io.livevoice.sample.rn'
//        minSdk 26
//        targetSdk 35
//        versionCode 1
//        versionName '1.0.0'
//
//        vectorDrawables {
//            useSupportLibrary true
//        }
//    }
//
//    buildTypes {
//        debug {
//            // There is no signing-config, so we use a minified/non-debuggable debug build
//            // to emulate a release build
//            minifyEnabled true
//            debuggable false
//        }
//    }
//
//    compileOptions {
//        sourceCompatibility JavaVersion.VERSION_1_8
//        targetCompatibility JavaVersion.VERSION_1_8
//    }
//
//    kotlinOptions {
//        jvmTarget = '1.8'
//    }
//
//    buildFeatures {
//        compose true
//    }
//
//    packagingOptions {
//        resources {
//            excludes += '/META-INF/{AL2.0,LGPL2.1}'
//        }
//    }
//}
//
//dependencies {
//    // For animation in custom sample button
//    implementation libs.lottie.compose
//
//    implementation 'io.livevoice.sdk:android:1.0.1'
//
//    // Version definitions for all Compose libraries
//    implementation platform(libs.androidx.compose.bom)
//
//    implementation libs.androidx.core.ktx
//    implementation libs.androidx.lifecycle.runtime.ktx
//    implementation libs.androidx.activity.compose
//    implementation libs.androidx.ui
//    implementation libs.androidx.ui.graphics
//    implementation libs.androidx.ui.tooling.preview
//    implementation libs.androidx.material3
//    debugImplementation libs.androidx.ui.tooling
//}
