# Scripts for FAH development on macOS

## Requirements

- Xcode 12.2+ and macOS 10.15.4+
- [Homebrew](https://brew.sh)
- `brew install fileicon`

Building web control archive also requires

- `brew install node vite`

Building cores also requires

- access to private fah repos
- macOS 12 and Xcode 14
- cmake 3 <https://cmake.org/download/>

    Prepend `PATH` in ``~/.zprofile``

    ``export PATH="/Applications/CMake.app/Contents/bin:$PATH"``

## Installation

Clone this repo to your home directory:

```
cd ~
git clone https://github.com/kbernhagen/fah-dev-macos.git
```

If you will be using private repos, you should move this repo to a
directory on an encrypted volume before running setup.sh.

Run setup.sh to clone public repos into `workarea` directory and build
static openssl3. If not found, uv and just will be installed via pipx.

Setup can take 30 minutes.

    cd ~/fah-dev-macos
    ./bin/setup.sh

If you intend to build cores (via private buildbot system), run

    just build-libraries

Building and testing libraries fftw3 and openmp can take 20 minutes.

To build fah 8 (bastet), run
 
    just clean-fah build-fah debug=1

A clean before build is useful to prevent problems when switching
between debug and release builds. You need not clean if you are
not changing build arguments or repo branches.

Note that you are responible for repos cloned into `workarea`.
They will never be auto updated, as `workarea` is for development.

To build the uninstaller package, run

    just build-fah-uninstaller

Signing and notarization have additional requirements not detailed here.

To enable just auto complete, append to `~/.zshrc`
```
source <(just --completions zsh)
```
