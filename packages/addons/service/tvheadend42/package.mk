################################################################################
#      This file is part of LibreELEC - https://LibreELEC.tv
#      Copyright (C) 2016 Team LibreELEC
#
#  LibreELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  LibreELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with LibreELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="tvheadend42"
PKG_VERSION="7f24603"
PKG_VERSION_NUMBER="4.1.1933"
PKG_REV="102"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://www.tvheadend.org"
PKG_URL="https://github.com/tvheadend/tvheadend/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_DIR="tvheadend-${PKG_VERSION}*"
PKG_DEPENDS_TARGET="toolchain curl libdvbcsa libiconv libressl Python:host yasm"
PKG_PRIORITY="optional"
PKG_SECTION="service"
PKG_SHORTDESC="Tvheadend: a TV streaming server for Linux"
PKG_LONGDESC="Tvheadend($PKG_VERSION_NUMBER): is a TV streaming server for Linux supporting DVB-S/S2, DVB-C, DVB-T/T2, IPTV, SAT>IP, ATSC and ISDB-T"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Tvheadend 4.2"
PKG_ADDON_TYPE="xbmc.service"
PKG_AUTORECONF="no"
PKG_ADDON_REPOVERSION="7.0"

# transcoding only for generic
if [ "$TARGET_ARCH" = x86_64 ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libva-intel-driver"
  TVH_TRANSCODING="--enable-ffmpeg_static --enable-libav --enable-libfdkaac --disable-libtheora --enable-libvorbis --enable-libvpx --enable-libx264 --enable-libx265 --disable-qsv"
else
  TVH_TRANSCODING="--disable-ffmpeg_static --disable-libav"
fi

PKG_CONFIGURE_OPTS_TARGET="--prefix=/usr \
                           --arch=$TARGET_ARCH \
                           --cpu=$TARGET_CPU \
                           --cc=$TARGET_CC \
                           --disable-avahi \
                           --enable-bundle \
                           --disable-dbus_1 \
                           --enable-dvbcsa \
                           --disable-dvben50221 \
                           --enable-hdhomerun_client \
                           --enable-hdhomerun_static \
                           --enable-epoll \
                           --enable-inotify \
                           --disable-nvenc \
                           --disable-uriparser \
                           $TVH_TRANSCODING \
                           --enable-tvhcsa \
                           --nowerror \
                           --python=$ROOT/$TOOLCHAIN/bin/python"

post_unpack() {
  sed -e 's/VER="0.0.0~unknown"/VER="'$PKG_VERSION_NUMBER' ~ LibreELEC Tvh-addon v'$PKG_ADDON_REPOVERSION'.'$PKG_REV'"/g' -i $PKG_BUILD/support/version
}

pre_configure_target() {
# fails to build in subdirs
  cd $ROOT/$PKG_BUILD
  rm -rf .$TARGET_NAME

# transcoding
  if [ "$TARGET_ARCH" = x86_64 ]; then
    export AS=$ROOT/$TOOLCHAIN/bin/yasm
  fi

  export CROSS_COMPILE=$TARGET_PREFIX
  export CFLAGS="$CFLAGS -I$SYSROOT_PREFIX/usr/include/iconv -L$SYSROOT_PREFIX/usr/lib/iconv"
}

# transcoding link tvheadend with g++
if [ "$TARGET_ARCH" = x86_64 ]; then
  pre_make_target() {
    export CXX=$TARGET_CXX
  }
fi

post_make_target() {
  $CC -O -fbuiltin -fomit-frame-pointer -fPIC -shared -o capmt_ca.so src/extra/capmt_ca.c -ldl
}

makeinstall_target() {
  : # nothing to do here
}

addon() {
  mkdir -p $ADDON_BUILD/$PKG_ADDON_ID/bin
  cp -P $PKG_BUILD/build.linux/tvheadend $ADDON_BUILD/$PKG_ADDON_ID/bin
  cp -P $PKG_BUILD/capmt_ca.so $ADDON_BUILD/$PKG_ADDON_ID/bin
}
