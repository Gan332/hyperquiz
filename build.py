#!/usr/bin/env python3
"""
Build script for QuizMaster (Rust + Flutter).
Usage:
  python build.py rust        # Build Rust library for host
  python build.py android     # Build Rust for Android
  python build.py flutter     # Run flutter build
  python build.py all         # Build everything
"""

import shutil
import subprocess
import sys
import os

RUST_DIR = os.path.join(os.path.dirname(__file__), "rust")
ANDROID_JNI = os.path.join(os.path.dirname(__file__), "android", "app", "src", "main", "jniLibs")

ANDROID_TARGETS = {
    "aarch64-linux-android": "arm64-v8a",
    "armv7-linux-androideabi": "armeabi-v7a",
    "x86_64-linux-android": "x86_64",
    "i686-linux-android": "x86",
}


def build_rust(mode="release"):
    print("=== Building Rust library ===")
    cmd = ["cargo", "build"]
    if mode == "release":
        cmd.append("--release")
    subprocess.run(cmd, cwd=RUST_DIR, check=True)
    print("Rust build complete!")


def build_android(mode="release"):
    ndk = os.environ.get("ANDROID_NDK_HOME")
    if not ndk:
        print("ERROR: ANDROID_NDK_HOME not set")
        sys.exit(1)

    host_tag = "windows-x86_64" if sys.platform == "win32" else "linux-x86_64" if sys.platform == "linux" else "darwin-x86_64"

    for target, abi in ANDROID_TARGETS.items():
        prefix = target.replace("eabi", "")
        clang = os.path.join(ndk, "toolchains", "llvm", "prebuilt", host_tag, "bin", f"{prefix}21-clang")
        if sys.platform == "win32":
            clang += ".cmd"

        os.environ[f"CC_{target}"] = clang
        os.environ[f"AR_{target}"] = os.path.join(ndk, "toolchains", "llvm", "prebuilt", host_tag, "bin", "llvm-ar")
        os.environ[f"CARGO_TARGET_{target.upper().replace('-', '_')}_LINKER"] = clang

        print(f"Building for {target}...")
        cmd = ["cargo", "build", "--target", target]
        if mode == "release":
            cmd.append("--release")
        subprocess.run(cmd, cwd=RUST_DIR, check=True)

        # Copy .so to jniLibs
        build_type = "release" if mode == "release" else "debug"
        so_src = os.path.join(RUST_DIR, "target", target, build_type, "libquiz_core.so")
        so_dst = os.path.join(ANDROID_JNI, abi, "libquiz_core.so")
        os.makedirs(os.path.dirname(so_dst), exist_ok=True)
        shutil.copy2(so_src, so_dst)
        print(f"  -> Copied to {so_dst}")


def build_flutter(mode="release"):
    print("=== Building Flutter app ===")
    cmd = ["flutter", "build", "apk"]
    if mode == "release":
        cmd.append("--release")
    subprocess.run(cmd, check=True)
    print("Flutter build complete!")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1]
    mode = sys.argv[2] if len(sys.argv) > 2 else "release"

    if command == "rust":
        build_rust(mode)
    elif command == "android":
        build_android(mode)
    elif command == "flutter":
        build_flutter(mode)
    elif command == "all":
        build_rust(mode)
        build_android(mode)
        build_flutter(mode)
    else:
        print(f"Unknown command: {command}")
        print(__doc__)
