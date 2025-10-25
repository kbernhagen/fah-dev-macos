# Scripts for FAH development on macOS

Requires

- Xcode 12.2+ and macOS 10.15.4+
- [homebrew](https://brew.sh)
- `brew install fileicon`

Building web control archive also requires

- `brew install node vite`

Building cores also requires

- access to private fah repos
- macOS 12 and Xcode 14
- `brew install lit`
- cmake 3 <https://cmake.org/download/>

    Prepend `PATH` in ``~/.zprofile``

    ``export PATH="/Applications/CMake.app/Contents/bin:$PATH"``

Clone this repo to your home directory:

```
cd ~
git clone https://github.com/kbernhagen/fah-dev-macos.git
```

If you will be using private repos, you should move this repo to a
directory on an encrypted volume before running setup.sh.

Run setup.sh to clone public repos into `workarea` directory
and build static libraries.
Setup can take 30 minutes.

    cd ~/fah-dev-macos
    ./bin/setup.sh

If you intend to build cores, run

    ./bin/make-openmp.sh
 
To build fah 8 (bastet), run
 
    ./bin/clean-fah.sh && ./bin/make-fah-bastet.sh debug=1

A clean before build is needed to prevent problems when switching
between debug and release builds.

Note that you are responible for repos cloned into `workarea`.
They will never be auto updated, as `workarea` is for development.

To build the uninstaller package, run

    ./bin/make-fah-uninstaller.sh

Signing and notarization have additional requirements not detailed here.

More private repos are required to build the v7 client packages.

Building v7 fah-control requires python2 gtk2, which was previously
built via MacPorts.
This is also not detailed here.
