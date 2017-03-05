################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
#
#  OpenELEC is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  OpenELEC is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

PKG_NAME="service.rom.collection.browser.robert"
PKG_VERSION="131f133"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="http://www.kodi.tv"
PKG_URL="https://github.com/prfiredragon/RomCollectionBrowserService/archive/$PKG_VERSION.tar.gz"
PKG_SOURCE_DIR="RomCollectionBrowserService-131f1336de8c57d41185f8c4bfd208f6e192727f"
PKG_DEPENDS_TARGET="toolchain kodi-platform"
PKG_PRIORITY="optional"
PKG_SECTION=""
PKG_SHORTDESC="rom.collection.browser"
PKG_LONGDESC="rom.collection.browser"
PKG_AUTORECONF="no"

PKG_IS_ADDON="yes"
PKG_ADDON_TYPE="xbmc.service"

configure_target() {
#  cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_CONF \
#        -DCMAKE_INSTALL_PREFIX=/usr \
#        -DCMAKE_MODULE_PATH=$SYSROOT_PREFIX/usr/lib/kodi \
#        -DCMAKE_PREFIX_PATH=$SYSROOT_PREFIX/usr \
#        ..
mkdir -p .install_pkg/usr/share/kodi/addons/$PKG_NAME/
cp *.* .install_pkg/usr/share/kodi/addons/$PKG_NAME/
ls
}

make_target() {
ls
}

makeinstall_target() {
ls
}

addon() {
  mkdir -p $ADDON_BUILD/$PKG_ADDON_ID/
  cp -R $PKG_BUILD/.install_pkg/usr/share/kodi/addons/$PKG_NAME/* $ADDON_BUILD/$PKG_ADDON_ID/

  ADDONSO=$(xmlstarlet sel -t -v "/addon/extension/@library_linux" $ADDON_BUILD/$PKG_ADDON_ID/addon.xml)
  cp -L $PKG_BUILD/.install_pkg/usr/lib/kodi/addons/$PKG_NAME/$ADDONSO $ADDON_BUILD/$PKG_ADDON_ID/
}