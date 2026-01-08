# scons options for fah v8
# pylint: disable=invalid-name,missing-module-docstring
debug=1

compiler = 'clang'
cxxstd = 'c++17'
dist_build = '-%(mode)s'
force_local = 'bzip2'
lto=0
mostly_static = 1
osx_archs = 'arm64 x86_64'
osx_min_ver = '10.13'
package_arch = 'universal'

sign_disable = 1
sign_keychain = ''
sign_id_installer = 'Developer ID Installer: Jane Doe (C123456789)'
sign_id_app = 'Developer ID Application: Jane Doe (C123456789)'
sign_prefix = 'org.foldingathome.'

notarize_disable = 1
notarize_profile = 'jane.doe@example.com C123456789'
