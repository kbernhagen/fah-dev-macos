# Scripts for FAH development on macOS

If you will be using private repos, you should move this repo to a directory
 on an encrypted volume before running setup.sh.

Xcode 12.2+ and macOS 10.15.4+ are required.

Run ``./bin/setup.sh`` to clone repos, build static libraries, install 
scons, six.
If cmake exists, OpenMP is built.
This can take 30 minutes.

Some private repos may be required to build the v7 client packages.

To build fah 8 (bastet), run
 
    ./bin/clean-fah.sh && ./bin/make-fah-bastet.sh debug=1

To build uninstaller package, run

    ./bin/make-fah-uninstaller.sh

Signing and notarization have additional requirements not detailed here.

Building fah-control requires python2 gtk2, which was previously built via MacPorts.
This is also not detailed here.
