# scons options for fah v7
debug=1
strict=1

osx_min_ver = '10.7'
compiler = 'clang'
osx_archs = 'x86_64'
cxxstd = 'c++17'
cxxflags = '-stdlib=libc++'
linkflags = '-stdlib=libc++'

package_arch = 'x86_64'
disable_local = 'libevent re2'

sign_disable = 1
sign_keychain = ''
#sign_keychain = 'developer.jane.doe.keychain'
sign_id_installer = 'Developer ID Installer: Jane Doe (C123456789)'
sign_id_app = 'Developer ID Application: Jane Doe (C123456789)'
sign_prefix = 'org.foldingathome.'

notarize_disable = 1
notarize_profile = 'jane.doe@example.com C123456789'
