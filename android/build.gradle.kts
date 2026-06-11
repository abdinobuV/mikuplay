allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt != null) {
                try {
                    val namespaceProp = androidExt.javaClass.getMethod("getNamespace").invoke(androidExt)
                    if (namespaceProp == null) {
                        androidExt.javaClass.getMethod("setNamespace", String::class.java).invoke(androidExt, project.group.toString())
                    }
                } catch (e: Exception) {}

                try {
                    val compileOptions = androidExt.javaClass.getMethod("getCompileOptions").invoke(androidExt)
                    compileOptions.javaClass.getMethod("setSourceCompatibility", org.gradle.api.JavaVersion::class.java)
                        .invoke(compileOptions, org.gradle.api.JavaVersion.VERSION_17)
                    compileOptions.javaClass.getMethod("setTargetCompatibility", org.gradle.api.JavaVersion::class.java)
                        .invoke(compileOptions, org.gradle.api.JavaVersion.VERSION_17)
                } catch (e: Exception) {}
            }
        }
    }
    project.evaluationDependsOn(":app")
    
    // Force Kotlin compilation to match Java target
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

plugins {
    // ... mungkin ada plugin lain di sini
    // Tambahkan baris di bawah ini:
}