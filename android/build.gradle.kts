plugins {
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("com.google.gms.google-services") apply false
}


tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
