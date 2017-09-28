# the name of the project
project (nutty)

# the oldest stable cmake version we support
cmake_minimum_required (VERSION 2.6)

# tell cmake where its modules can be found in our project directory
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# where we install data directory (if we have any)
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

# what to call that directory where we install data too
set (PKGDATADIR "${DATADIR}/nutty")

set (EXEC_NAME "nutty")
set (RELEASE_NAME "nutty v0.9")
set (VERSION "0.9")
set (VERSION_INFO "Nutty - A Network Information Utility")

# Translation files
set (GETTEXT_PACKAGE "${CMAKE_PROJECT_NAME}")
add_definitions ("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"")
add_subdirectory (po)

# define variable for sources
set (SOURCE_LIST
    src/nutty.vala
    src/utils.vala
    src/constants.vala
)

# we're about to use pkgconfig to make sure dependencies are installed so let's find pkgconfig first
find_package(PkgConfig)

# now let's actually check for the required dependencies
pkg_check_modules(DEPS REQUIRED
                  gtk+-3.0
                  gee-0.8
                  granite>=0.3.0
                 )

add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

# make sure we have vala
find_package(Vala REQUIRED)
# make sure we use vala
include(ValaVersion)
# make sure it's the desired version of vala
ensure_vala_version("0.26" MINIMUM)

# files we want to compile
include(ValaPrecompile)

vala_precompile(VALA_C ${EXEC_NAME}
    src/nutty.vala
    src/utils.vala
    src/constants.vala

# tell what libraries to use when compiling
PACKAGES
    gtk+-3.0
    gee-0.8
    granite>=0.3.0
)

# tell cmake what to call the executable we just made
add_executable(${EXEC_NAME} ${VALA_C})

# set linking libraries
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

# install support scripts for nutty
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/speedtest-cli
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION /opt/nutty
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/nutty_device_alert.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION /opt/nutty
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/nutty_device_monitor.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION /opt/nutty
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/nutty_nmap_script.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION /opt/nutty
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/nutty_nethogs_script.sh
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ WORLD_EXECUTE
    DESTINATION /opt/nutty
)
install(
    FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/scripts/org.freedesktop.policykit.nutty.policy
    PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ WORLD_READ
    DESTINATION /usr/share/polkit-1/actions
)

# install nutty app icons
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/16/nutty.png DESTINATION share/icons/hicolor/16x16/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/24/nutty.png DESTINATION share/icons/hicolor/24x24/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/32/nutty.png DESTINATION share/icons/hicolor/32x32/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/48/nutty.png DESTINATION share/icons/hicolor/48x48/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/64/nutty.png DESTINATION share/icons/hicolor/64x64/apps)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/128/nutty.png DESTINATION share/icons/hicolor/128x128/apps)
# install nutty status icons
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/16/nutty-device-offline.svg DESTINATION share/icons/hicolor/16x16/status)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/16/nutty-device-available.svg DESTINATION share/icons/hicolor/16x16/status)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/16/nutty-application-default-icon.svg DESTINATION share/icons/hicolor/16x16/status)

# install our .desktop and .appdata files so the Applications menu will see it
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.babluboy.nutty.desktop DESTINATION ${DATADIR}/applications/)
install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/com.github.babluboy.nutty.appdata.xml DESTINATION ${DATADIR}/metainfo/)
