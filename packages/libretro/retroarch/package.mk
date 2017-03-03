################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="retroarch"
PKG_VERSION="b3aef50"
PKG_REV="3"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/libretro/RetroArch"
PKG_URL="$LAKKA_MIRROR/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain alsa-lib freetype zlib retroarch-assets retroarch-overlays core-info retroarch-joypad-autoconfig common-shaders lakka-update libretro-database ffmpeg joyutils libass libvdpau"
PKG_PRIORITY="optional"
PKG_SECTION="libretro"
PKG_SHORTDESC="Reference frontend for the libretro API."
PKG_LONGDESC="RetroArch is the reference frontend for the libretro API. Popular examples of implementations for this API includes videogame system emulators and game engines, but also more generalized 3D programs. These programs are instantiated as dynamic libraries. We refer to these as libretro cores."

PKG_IS_ADDON="no"
PKG_AUTORECONF="no"

if [ "$OPENGLES_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $OPENGLES"
else
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET $OPENGL"
fi

if [ "$SAMBA_SUPPORT" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET samba"
fi

if [ "$AVAHI_DAEMON" = yes ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET avahi nss-mdns"
fi

if [ "$OPENGLES" == "no" ]; then
  RETROARCH_GL="--enable-kms"
elif [ "$OPENGLES" == "bcm2835-driver" ]; then
  RETROARCH_GL="--enable-opengles --disable-kms --disable-x11"
  CFLAGS="$CFLAGS -I$SYSROOT_PREFIX/usr/include/interface/vcos/pthreads \
                  -I$SYSROOT_PREFIX/usr/include/interface/vmcs_host/linux"
elif [ "$OPENGLES" == "sunxi-mali" ] || [ "$OPENGLES" == "odroidc1-mali" ] || [ "$OPENGLES" == "odroidxu3-mali" ] || [ "$OPENGLES" == "opengl-meson6" ] || [ "$OPENGLES" == "opengl-meson8" ]; then
  RETROARCH_GL="--enable-opengles --disable-kms --disable-x11 --enable-mali_fbdev"
elif [ "$OPENGLES" == "gpu-viv-bin-mx6q" ]; then
  RETROARCH_GL="--enable-opengles --disable-kms --disable-x11 --enable-vivante_fbdev"
  CFLAGS="$CFLAGS -DLINUX -DEGL_API_FB"
fi

if [[ "$TARGET_FPU" =~ "neon" ]]; then
  RETROARCH_NEON="--enable-neon"
fi

TARGET_CONFIGURE_OPTS=""
PKG_CONFIGURE_OPTS_TARGET="--disable-vg \
                           --disable-sdl \
                           $RETROARCH_GL \
                           $RETROARCH_NEON \
                           --enable-fbo \
                           --enable-zlib \
                           --enable-freetype"

pre_configure_target() {
  strip_lto # workaround for https://github.com/libretro/RetroArch/issues/1078
  cd $ROOT/$PKG_BUILD
}

make_target() {
  make V=1 HAVE_LAKKA=1 HAVE_ZARCH=0
  make -C gfx/video_filters compiler=$CC extra_flags="$CFLAGS"
  make -C audio/audio_filters compiler=$CC extra_flags="$CFLAGS"
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/bin
  mkdir -p $INSTALL/etc
    cp $ROOT/$PKG_BUILD/retroarch $INSTALL/usr/bin
    cp $ROOT/$PKG_BUILD/retroarch.cfg $INSTALL/etc
  mkdir -p $INSTALL/usr/share/video_filters
    cp $ROOT/$PKG_BUILD/gfx/video_filters/*.so $INSTALL/usr/share/video_filters
    cp $ROOT/$PKG_BUILD/gfx/video_filters/*.filt $INSTALL/usr/share/video_filters
  mkdir -p $INSTALL/usr/share/audio_filters
    cp $ROOT/$PKG_BUILD/audio/audio_filters/*.so $INSTALL/usr/share/audio_filters
    cp $ROOT/$PKG_BUILD/audio/audio_filters/*.dsp $INSTALL/usr/share/audio_filters
  
  # General configuration
  sed -i -e "s/# libretro_directory =/libretro_directory = \"\/tmp\/cores\"/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# libretro_info_path =/libretro_info_path = \"\/tmp\/cores\"/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# rgui_browser_directory =/rgui_browser_directory =\/storage\/roms/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# content_database_path =/content_database_path =\/tmp\/database\/rdb/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# playlist_directory =/playlist_directory =\/storage\/playlists/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# savefile_directory =/savefile_directory =\/storage\/savefiles/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# savestate_directory =/savestate_directory =\/storage\/savestates/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# system_directory =/system_directory =\/storage\/system/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# screenshot_directory =/screenshot_directory =\/storage\/screenshots/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# video_shader_dir =/video_shader_dir =\/usr\/share\/common-shaders/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# rgui_show_start_screen = true/rgui_show_start_screen = false/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# assets_directory =/assets_directory =\/tmp\/assets/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# overlays_directory =/overlays_directory =\/usr\/share\/retroarch-overlays/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# cheat_database_path =/cheat_database_path =\/tmp\/database\/cht/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# menu_driver = \"rgui\"/menu_driver = \"xmb\"/" $INSTALL/etc/retroarch.cfg
  echo "core_assets_directory =/storage/roms/downloads" >> $INSTALL/etc/retroarch.cfg
  
  # Video
  sed -i -e "s/# video_fullscreen = false/video_fullscreen = true/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# video_windowed_fullscreen = true/video_windowed_fullscreen = false/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# video_smooth = true/video_smooth = false/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# video_aspect_ratio_auto = false/video_aspect_ratio_auto = true/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# video_threaded = false/video_threaded = true/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# video_font_path =/video_font_path =\/usr\/share\/retroarch-assets\/xmb\/monochrome\/font.ttf/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# video_font_size = 48/video_font_size = 32/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# video_filter_dir =/video_filter_dir =\/usr\/share\/video_filters/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# video_gpu_screenshot = true/video_gpu_screenshot = false/" $INSTALL/etc/retroarch.cfg

  # Audio
  sed -i -e "s/# audio_driver =/audio_driver = \"alsathread\"/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# audio_filter_dir =/audio_filter_dir =\/usr\/share\/audio_filters/" $INSTALL/etc/retroarch.cfg
  if [ "$PROJECT" == "OdroidXU3" ]; then # workaround the 55fps bug
    sed -i -e "s/# audio_out_rate = 48000/audio_out_rate = 44100/" $INSTALL/etc/retroarch.cfg
  fi

  # Saving
  echo "savestate_thumbnail_enable = \"false\"" >> $INSTALL/etc/retroarch.cfg
  
  # Input
  sed -i -e "s/# input_driver = sdl/input_driver = udev/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# input_max_users = 16/input_max_users = 5/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# input_autodetect_enable = true/input_autodetect_enable = true/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# joypad_autoconfig_dir =/joypad_autoconfig_dir = \/tmp\/joypads/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# input_remapping_directory =/input_remapping_directory = \/storage\/remappings/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# input_menu_toggle_gamepad_combo = 0/input_menu_toggle_gamepad_combo = 2/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# all_users_control_menu = false/all_users_control_menu = true/" $INSTALL/etc/retroarch.cfg

  # Menu
  sed -i -e "s/# menu_core_enable = true/menu_core_enable = false/" $INSTALL/etc/retroarch.cfg
  sed -i -e "s/# thumbnails_directory =/thumbnails_directory = \/storage\/thumbnails/" $INSTALL/etc/retroarch.cfg
  echo "menu_show_advanced_settings = \"false\"" >> $INSTALL/etc/retroarch.cfg
  echo "menu_wallpaper_opacity = \"1.0\"" >> $INSTALL/etc/retroarch.cfg
  echo "xmb_show_images = \"false\"" >> $INSTALL/etc/retroarch.cfg
  echo "xmb_show_music = \"false\"" >> $INSTALL/etc/retroarch.cfg
  echo "xmb_show_video = \"false\"" >> $INSTALL/etc/retroarch.cfg

  # Updater
  if [ "$ARCH" == "arm" ]; then
    sed -i -e "s/# core_updater_buildbot_url = \"http:\/\/buildbot.libretro.com\"/core_updater_buildbot_url = \"http:\/\/buildbot.libretro.com\/nightly\/linux\/armhf\/latest\/\"/" $INSTALL/etc/retroarch.cfg
  fi
  
  # Playlists
  echo "playlist_names = \"$RA_PLAYLIST_NAMES\"" >> $INSTALL/etc/retroarch.cfg
  echo "playlist_cores = \"$RA_PLAYLIST_CORES\"" >> $INSTALL/etc/retroarch.cfg

  # Gamegirl
  if [ "$PROJECT" == "Gamegirl" ]; then
    echo "xmb_theme = 3" >> $INSTALL/etc/retroarch.cfg
    echo "xmb_menu_color_theme = 9" >> $INSTALL/etc/retroarch.cfg
    echo "video_font_size = 10" >> $INSTALL/etc/retroarch.cfg
    echo "aspect_ratio_index = 0" >> $INSTALL/etc/retroarch.cfg
    echo "audio_device = \"sysdefault:CARD=ALSA\"" >> $INSTALL/etc/retroarch.cfg
    echo "menu_timedate_enable = false" >> $INSTALL/etc/retroarch.cfg
    echo "xmb_shadows_enable = true" >> $INSTALL/etc/retroarch.cfg
    sed -i -e "s/input_menu_toggle_gamepad_combo = 2/input_menu_toggle_gamepad_combo = 4/" $INSTALL/etc/retroarch.cfg
    sed -i -e "s/video_smooth = false/video_smooth = true/" $INSTALL/etc/retroarch.cfg
    sed -i -e "s/video_font_path =\/usr\/share\/retroarch-assets\/xmb\/monochrome\/font.ttf//" $INSTALL/etc/retroarch.cfg
  fi
}

post_install() {  
  # link default.target to retroarch.target
#  ln -sf retroarch.target $INSTALL/usr/lib/systemd/system/default.target
  
  enable_service retroarch-autostart.service
  enable_service retroarch.service
  enable_service tmp-cores.mount
  enable_service tmp-joypads.mount
  enable_service tmp-database.mount
  enable_service tmp-assets.mount
}

post_makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/retroarch
  mkdir -p $INSTALL/usr/bin
    cp $PKG_DIR/scripts/retroarch-config $INSTALL/usr/lib/retroarch
    cp $PKG_DIR/scripts/retroarch.sh $INSTALL/usr/bin
    cp $PKG_DIR/scripts/retroarch.start $INSTALL/usr/bin
}
