pkg_name="dash"
pkg_origin="ryanwoodsmall"
pkg_version="0.5.12"
pkg_license=("BSD")
pkg_maintainer="ryanwoodsmall <rwoodsmall@gmail.com>"
pkg_description="DASH is a POSIX-compliant implementation of /bin/sh that aims to be as small as possible."
pkg_upstream_url="http://gondor.apana.org.au/~herbert/dash/"
pkg_dirname="${pkg_name}-${pkg_version}"
pkg_filename="${pkg_dirname}.tar.gz"
pkg_source="http://gondor.apana.org.au/~herbert/dash/files/${pkg_filename}"
pkg_shasum="6a474ac46e8b0b32916c4c60df694c82058d3297d8b385b74508030ca4a8f28a"
pkg_build_deps=("core/gcc" "core/musl" "core/file" "core/busybox-static" "core/make")
pkg_bin_dirs=("bin")

DO_CHECK=1

do_build() {
  cd "${SRC_PATH}" || exit 1
  local CC="$(pkg_path_for core/musl)/bin/musl-gcc"
  export CC
  ./configure \
    --prefix="${pkg_prefix}" \
    --disable-silent-rules \
    --enable-static \
    --without-libedit \
      CC="${CC}" \
      CFLAGS="-Os -g0 -Wl,-s -Wl,-static" \
      LDFLAGS="-s -static" \
      CPPFLAGS= \
      PKG_CONFIG_{LIBDIR,PATH}=
  sed -i '/^AM_CFLAGS_FOR_BUILD = /s/$/ -Wl,-static/' src/Makefile
  make
  unset CC
}

do_install() {
  cd "${SRC_PATH}" || exit 1
  make install
}

do_check() {
  cd "${SRC_PATH}" || exit 1
  build_line "checking that dash is static"
  file src/dash | grep 'ELF.*static'
  build_line "checking that dash can run something"
  build_line "set internal..."
  env -i ./src/dash -c set
  build_line "env from busybox..."
  env -i PATH=$(pkg_path_for core/busybox-static)/bin ./src/dash -c env
}
