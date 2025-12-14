set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

export FAH_DEV_ROOT := justfile_dir()
export BUILD_ROOT := justfile_dir() / "workarea"
export SDKROOT := `xcrun --sdk macosx --show-sdk-path`
export TARGET_ARCH :=  "universal"
export CBANG_HOME := BUILD_ROOT / "cbang"
export OPENSSL_HOME := home_dir() / "fah-local-10.13"
export FFTW3_HOME := home_dir() / "fah-local-10.13"
export LIBOMP_HOME := home_dir() / "fah-local-openmp"
export SCONS_JOBS := if env("SCONS_JOBS", "") == "" {
    `sysctl -n hw.perflevel0.logicalcpu 2>/dev/null \
    || sysctl -n hw.ncpu 2>/dev/null || echo 1`
} else {
    env("SCONS_JOBS")
}
export SCONS_OPTIONS := if env("SCONS_OPTIONS", "") == "" {
    justfile_dir() / "etc/scons_options.py"
} else {
    env("SCONS_OPTIONS")
}
# Default SIGN_KEYCHAIN to login.keychain if empty or unset
export SIGN_KEYCHAIN := if env("SIGN_KEYCHAIN", "") == "" {
    "login.keychain"
} else {
    env("SIGN_KEYCHAIN")
}

help:
    @just --list --unsorted

[positional-arguments]
build-fah *ARGS: unlock-keychain
    uv run scons -C "{{BUILD_ROOT}}"/cbang "$@"
    @echo
    uv run scons -C "{{BUILD_ROOT}}"/cbang test "$@"
    @echo
    uv run scons -C "{{BUILD_ROOT}}"/fah-client-bastet "$@"
    @echo
    uv run scons -C "{{BUILD_ROOT}}"/fah-client-bastet dist "$@"
    @echo
    uv run scons -C "{{BUILD_ROOT}}"/fah-client-bastet package "$@"
    @echo
    uv run scons -C "{{BUILD_ROOT}}"/fah-web-client-bastet dist "$@" || true

build-fah-uninstaller: unlock-keychain
    uv run scons -C "{{BUILD_ROOT}}"/fah-client-osx-uninstaller package

build-openssl:
    @./bin/make-openssl3.sh

[private]
build-openssl-split:
    @./bin/make-openssl3.sh split

build-fftw:
    @./bin/make-fftw.sh

build-openmp:
    @uv run ./bin/make-openmp.sh

build-libraries: build-openssl build-fftw build-openmp

# build fftw3 and openmp with LTO, openssl without
build-libraries-lto:
    @./bin/make-openssl3.sh
    @./bin/make-fftw.sh lto
    @uv run ./bin/make-openmp.sh lto

getclones:
    #!/usr/bin/env python3
    import os
    import subprocess
    build_root = os.environ.get("BUILD_ROOT")
    if not build_root:
      raise SystemExit("Error: BUILD_ROOT environment variable is not defined")
    os.makedirs(build_root, exist_ok=True)
    os.chdir(build_root)
    print(f"\nCloning public repos into {build_root}\n")
    repos = [
      "CauldronDevelopmentLLC/cbang",
      "FoldingAtHome/fah-client-bastet",
      "FoldingAtHome/fah-web-client-bastet",
      "FoldingAtHome/fah-client-osx-uninstaller",
    ]
    for repo in repos:
      name = os.path.basename(repo)
      if os.path.isdir(name):
        print(f"skipping existing {name}")
      else:
        print()
        cmd = ["git", "clone", f"https://github.com/{repo}.git"]
        print(' '.join(cmd))
        subprocess.run(cmd, check=True)

getclones-private:
    #!/usr/bin/env python3
    import os
    import subprocess
    build_root = os.environ.get("BUILD_ROOT")
    if not build_root:
      raise SystemExit("Error: BUILD_ROOT environment variable is not defined")
    os.makedirs(build_root, exist_ok=True)
    os.chdir(build_root)
    print(f"\nCloning private repos into {build_root}\n")
    for repo in ["libfah", "gromacs-core"]:
      if os.path.isdir(repo):
        print(f"skipping existing {repo}")
      else:
        print()
        cmd = ["git", "clone", f"git@github.com:FoldingAtHome/{repo}.git"]
        print(' '.join(cmd))
        subprocess.run(cmd, check=True)

debug:
    @echo CBANG_HOME: {{CBANG_HOME}}
    @echo OPENSSL_HOME: {{OPENSSL_HOME}}
    @echo FFTW3_HOME: {{FFTW3_HOME}}
    @echo LIBOMP_HOME: {{LIBOMP_HOME}}
    @echo SIGN_KEYCHAIN: {{SIGN_KEYCHAIN}}
    @echo BUILD_ROOT: {{BUILD_ROOT}}
    @echo SCONS_JOBS: {{SCONS_JOBS}}
    @echo SCONS_OPTIONS: {{SCONS_OPTIONS}}
    @echo SDKROOT: {{SDKROOT}}

clean:
    rm -rf .venv etc/__pycache__
    find . -type f -name '.DS_Store' -delete

clean-fah:
    uv run scons -C "{{BUILD_ROOT}}"/cbang -c
    uv run scons -C "{{BUILD_ROOT}}"/fah-client-bastet -c dist
    uv run scons -C "{{BUILD_ROOT}}"/fah-client-bastet -c package
    uv run scons -C "{{BUILD_ROOT}}"/fah-client-bastet -c
    uv run scons -C "{{BUILD_ROOT}}"/fah-web-client-bastet -c distclean
    uv run scons -C "{{BUILD_ROOT}}"/fah-client-osx-uninstaller -c package
    find . -type f -name .sconsign.dblite -print -delete

# Unlock macOS keychain
unlock-keychain:
    @if [ "{{os()}}" = "macos" ]; then \
        security unlock-keychain -p fake "{{SIGN_KEYCHAIN}}" >/dev/null 2>&1 \
        || security unlock-keychain "{{SIGN_KEYCHAIN}}"; \
    fi
