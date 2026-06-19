set(CPACK_PACKAGE_NAME "mjpg-streamer")
set(CPACK_PACKAGE_VENDOR "Ultimaker B.V.")
set(CPACK_PACKAGE_CONTACT "firmware@ultimaker.com")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "MJPG-streamer")

# Version is normally injected by CI via -DCPACK_PACKAGE_VERSION=X.Y.Z.
# The sentinel "9999.99.99" marks a local / untagged build.
if(NOT DEFINED CPACK_PACKAGE_VERSION OR CPACK_PACKAGE_VERSION STREQUAL "")
    set(CPACK_PACKAGE_VERSION "9999.99.99")
endif()

set(CPACK_GENERATOR "DEB")

# ── Debian-specific ───────────────────────────────────────────────────────────

# Runtime dependencies: libjpeg62-turbo and libwebp7 are only required when the
# WebP snapshot feature is compiled in (WEBP_ENABLED is set by CMakeLists.txt).
if(WEBP_ENABLED)
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libjpeg62-turbo, libwebp7")
else()
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6")
endif()

set(CPACK_DEBIAN_PACKAGE_SECTION  "devel")
set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")

# Cross-compiled for arm64; set explicitly so the filename is correct even when
# cpack is run on an amd64 host.
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")

# Produces:  mjpg-streamer_12.0.1_arm64.deb
set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")

# Restart the streaming service after installation.
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${CMAKE_SOURCE_DIR}/debian/postinst")

include(CPack)
