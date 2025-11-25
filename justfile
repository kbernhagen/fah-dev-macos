set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

export FAH_DEV_ROOT := justfile_dir()
export BUILD_ROOT := justfile_dir() / "workarea"
export SDKROOT := `xcrun --sdk macosx --show-sdk-path`
export CBANG_HOME := BUILD_ROOT / "cbang"
export OPENSSL_HOME := home_dir() / "fah-local-10.13"
export FFTW3_HOME := home_dir() / "fah-local-10.13"
export LIBOMP_HOME := home_dir() / "fah-local-openmp"
export SCONS_JOBS := num_cpus()

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
build-fah: unlock-keychain
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

[positional-arguments]
build-fah-uninstaller: unlock-keychain
    uv run scons -C "{{BUILD_ROOT}}"/fah-client-osx-uninstaller package "$@"

build-openssl:
    @./bin/make-openssl3.sh

build-fftw:
    @./bin/make-fftw.sh

build-openmp:
    @./bin/make-openmp.sh

getclones:
    @./bin/getclones.sh

getclones-private:
    @./bin/getclones-private.sh

debug:
    @echo CBANG_HOME: {{CBANG_HOME}}
    @echo OPENSSL_HOME: {{OPENSSL_HOME}}
    @echo FFTW3_HOME: {{FFTW3_HOME}}
    @echo LIBOMP_HOME: {{LIBOMP_HOME}}
    @echo SIGN_KEYCHAIN: {{SIGN_KEYCHAIN}}
    @echo BUILD_ROOT: {{BUILD_ROOT}}
    @echo SCONS_JOBS: {{SCONS_JOBS}}
    @echo SCONS_OPTIONS: {{SCONS_OPTIONS}}


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
