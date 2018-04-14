# the name of the project
project (com.github.babluboy.nutty)

# the oldest stable cmake version we support
cmake_minimum_required (VERSION 2.8)

# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Set all the data directories
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/nutty")
set (ICON_DIR ${PKGDATADIR}/icons/hicolor)
set (SCRIPTS_DIR ${PKGDATADIR}/scripts)

# Set the application executable name and version info
set (EXEC_NAME "com.github.babluboy.nutty")
set (RELEASE_NAME "nutty v1.0.0")
set (VERSION "1.0.0")
set (VERSION_INFO "Nutty - A Network Information Utility")

# Translation files
set (GETTEXT_PACKAGE "${CMAKE_PROJECT_NAME}")
add_definitions ("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
add_subdirectory (po)

# Replace parameters in source code
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/src/constants.vala.in" "${CMAKE_SOURCE_DIR}/src/constants.vala" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/org.freedesktop.policykit.nutty.policy.in" "${CMAKE_SOURCE_DIR}/data/scripts/org.freedesktop.policykit.nutty.policy" @ONLY)

# define variable for sources
set (SOURCE_LIST
    src/main.vala
    src/nutty.vala
    src/headerbar.vala
    src/utils.vala
    src/constants.vala
    src/devices.vala
    src/database.vala
    src/entities.vala
    src/xmlHandler.vala
    src/info.vala
    src/window.vala
)

# we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
find_package(PkgConfig)

# now let's actually check for the required dependencies
pkg_check_modules(DEPS REQUIRED
                  gtk+-3.0
                  gee-0.8
                  granite>=0.5
                  sqlite3>=3.5.9
                  libxml-2.0
                  libnotify
)

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES} -lm)
link_directories(${DEPS_LIBRARY_DIRS})

# make sure we have vala
find_package(Vala REQUIRED)
# make sure we use vala
include(ValaVersion)
# make sure it's the desired version of vala
ensure_vala_version("0.36" MINIMUM)

# files we want to compile
include(ValaPrecompile)

set (BASIC_VALAC_OPTIONS
   -g
   --target-glib=2.38
)

set (GLOBAL_VALAC_OPTIONS
  ${BASIC_VALAC_OPTIONS}
)

vala_precompile(VALA_C ${EXEC_NAME}
    src/main.vala
    src/nutty.vala
    src/headerbar.vala
    src/utils.vala
    src/constants.vala
    src/devices.vala
    src/database.vala
    src/entities.vala
    src/xmlHandler.vala
    src/info.vala
    src/window.vala

# tell what libraries to use when compiling
PACKAGES
    gtk+-3.0
    gee-0.8
    granite>=0.5
    sqlite3
    libxml-2.0
    libnotify
)

# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C})

# set linking libraries
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

# install nutty app icons in generic folder - /usr/share/icons/hicolor
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/16/com.github.babluboy.nutty.svg DESTINATION ${DATADIR}/icons/hicolor/16x16/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/24/com.github.babluboy.nutty.svg DESTINATION ${DATADIR}/icons/hicolor/24x24/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/32/com.github.babluboy.nutty.svg DESTINATION ${DATADIR}/icons/hicolor/32x32/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/48/com.github.babluboy.nutty.svg DESTINATION ${DATADIR}/icons/hicolor/48x48/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/64/com.github.babluboy.nutty.svg DESTINATION ${DATADIR}/icons/hicolor/64x64/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/128/com.github.babluboy.nutty.svg DESTINATION ${DATADIR}/icons/hicolor/128x128/apps)

# install nutty specific icons in application specific folder - /usr/share/nutty/icons
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/24/nutty-open-menu.svg DESTINATION ${ICON_DIR}/24x24/actions/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/16/nutty-device-offline.svg DESTINATION ${ICON_DIR}/16x16/status)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/16/nutty-device-available.svg DESTINATION ${ICON_DIR}/16x16/status)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/16/nutty-application-default-icon.svg DESTINATION ${ICON_DIR}/16x16/status)

# install .desktop and .appdata files so the Applications menu will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.babluboy.nutty.desktop DESTINATION ${DATADIR}/applications/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.babluboy.nutty.appdata.xml DESTINATION ${DATADIR}/metainfo/)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/org.freedesktop.policykit.nutty.policy
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ
    DESTINATION ${DATADIR}/polkit-1/actions
)

# install scripts for nutty
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/speedtest-cli
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION ${SCRIPTS_DIR}
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/nutty_device_alert.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION ${SCRIPTS_DIR}
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/nutty_device_monitor.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION ${SCRIPTS_DIR}
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/nutty_nmap_script.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION ${SCRIPTS_DIR}
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/nutty_nethogs_script.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION ${SCRIPTS_DIR}
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/nutty_cli_script.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION ${SCRIPTS_DIR}
)
