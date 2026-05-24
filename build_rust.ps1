# Build Rust native library for Android
# Prerequisites: Rust with Android targets installed
#   rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android
#   Install Android NDK and set ANDROID_NDK_HOME

param(
    [string]$Mode = "release"
)

$RustDir = Join-Path $PSScriptRoot "rust"
$TargetDir = Join-Path $RustDir "target"

function Build-Android {
    $ndk = $env:ANDROID_NDK_HOME
    if (-not $ndk) {
        Write-Warning "ANDROID_NDK_HOME not set. Skipping Android build."
        return
    }

    $host_tag = "windows-x86_64"
    $toolchains = @(
        @{ target="aarch64-linux-android"; abi="arm64-v8a" },
        @{ target="armv7-linux-androideabi"; abi="armeabi-v7a" },
        @{ target="x86_64-linux-android"; abi="x86_64" },
        @{ target="i686-linux-android"; abi="x86" }
    )

    foreach ($tc in $toolchains) {
        $target = $tc.target
        $abi = $tc.abi

        # Set environment variables dynamically
        $ccVar = "CC_$target"
        $arVar = "AR_$target"
        $linkerVar = "CARGO_TARGET_$($target.Replace('-', '_').ToUpper())_LINKER"
        $clangPath = "$ndk\toolchains\llvm\prebuilt\$host_tag\bin\${target}21-clang.cmd"
        $arPath = "$ndk\toolchains\llvm\prebuilt\$host_tag\bin\llvm-ar.exe"

        Set-Item -Path "env:$ccVar" -Value $clangPath
        Set-Item -Path "env:$arVar" -Value $arPath
        Set-Item -Path "env:$linkerVar" -Value $clangPath

        $modeFlag = if ($Mode -eq "release") { "--release" } else { "" }
        Push-Location $RustDir
        cargo build --target $target $modeFlag
        if (-not $?) {
            Pop-Location
            Write-Error "Failed to build for $target"
            return
        }
        Pop-Location

        $buildType = if ($Mode -eq "release") { "release" } else { "debug" }
        $soSrc = Join-Path $TargetDir "$target\$buildType\libquiz_core.so"
        $soDst = Join-Path $PSScriptRoot "android\app\src\main\jniLibs\$abi\libquiz_core.so"
        if (Test-Path $soSrc) {
            $parent = Split-Path $soDst -Parent
            if (-not (Test-Path $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }
            Copy-Item $soSrc $soDst -Force
            Write-Host "Copied $abi library"
        } else {
            Write-Warning "Built library not found at $soSrc"
        }
    }
}

function Build-Host {
    Push-Location $RustDir
    if ($Mode -eq "release") {
        cargo build --release
    } else {
        cargo build
    }
    if (-not $?) {
        Pop-Location
        Write-Error "Failed to build host library"
        return
    }
    Pop-Location

    $buildType = if ($Mode -eq "release") { "release" } else { "debug" }
    Write-Host "Host library built at: $TargetDir\$buildType\quiz_core.dll"
}

Write-Host "=== Building Rust quiz_core library ==="
Write-Host "Mode: $Mode"

Build-Android
Build-Host

Write-Host "Done!"
