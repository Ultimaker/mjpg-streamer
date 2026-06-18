set(CPACK_PACKAGE_NAME "mjpg-streamer")
set(CPACK_PACKAGE_VENDOR "Ultimaker B.V.")
set(CPACK_PACKAGE_CONTACT "firmware@ultimaker.com")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "MJPG-streamer")

# Bumped above the Cloudsmith-distributed 12.0.0 so apt will upgrade in-place.
set(CPACK_PACKAGE_VERSION_MAJOR 12)
set(CPACK_PACKAGE_VERSION_MINOR 0)
set(CPACK_PACKAGE_VERSION_PATCH 1)

set(CPACK_GENERATOR "DEB")

# ── Debian-specific ───────────────────────────────────────────────────────────

# New runtime deps introduced by the WebP snapshot feature.  The base binary
# and input_uvc.so have no additional deps beyond what was in 12.0.0.
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6, libjpeg62-turbo, libwebp7")

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
