# fah-dev-macos
 
Scripts for FAH development on macOS.

If you will be using private repos, you should move this repo to a directory on an encrypted volume.

Xcode 12.2+ and macOS 10.15.4+ are required.

Run ``./bin/setup.sh`` to clone public repos, build static libraries, install python 2.7.18, scons, buildbot, dockbot.

Private repos are not cloned. They are required to build the client and fah installer package.

Signing and notarization have additional requirements not detailed here.

Building fah-control requires python2 gtk2, which was previously built via MacPorts. This is also not detailed here.
