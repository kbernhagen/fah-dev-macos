sse3=1
debug=0
strict=1

osx_min_ver = '10.7'
compiler = 'clang'
osx_archs = 'arm64 x86_64'
cxxstd = 'c++14'
ccflags = '-stdlib=libc++ -Wno-unused-local-typedefs'
linkflags = '-stdlib=libc++'

package_arch = 'universal'
#disable_local = 'libevent re2'

sign_disable = 1
sign_keychain = 'login.keychain'
#sign_keychain = 'developer.jane.doe.keychain'
# parts of the build system don't know about sign_disable
# so you MUST comment-out sign_id_installer if it is not valid
#sign_id_installer = 'Developer ID Installer: Jane Doe (C123456789)'
sign_id_app = 'Developer ID Application: Jane Doe (C123456789)'
sign_prefix = 'org.foldingathome.'

notarize_disable = 1
notarize_user = 'example.jane.doe@icloud.com'
notarize_pass = '@keychain:Developer altool: Jane Doe'
notarize_asc = 'C123456789'
notarize_team = 'C123456789'
