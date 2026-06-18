project(mjpg-streamer)

cmake_minimum_required(VERSION 2.8.12)

if(SYSROOT)
        include_directories(
                ${SYSROOT}/usr/include/
		${SYSROOT}/usr/include/arm-linux-gnueabihf/
	)
        link_directories(
                ${SYSROOT}/usr/lib/
                ${SYSROOT}/usr/lib/arm-linux-gnueabihf/
        )
endif()

# Add warnings
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")

set(SOURCES mjpg_streamer.c utils.c)

add_executable(mjpg-streamer ${SOURCES})
target_link_libraries(mjpg-streamer dl pthread)

add_library(input_uvc SHARED plugins/input_uvc/input_uvc.c plugins/input_uvc/dynctrl.c plugins/input_uvc/v4l2uvc.c plugins/input_uvc/jpeg_utils.c)
set_target_properties(input_uvc PROPERTIES PREFIX "")

add_library(output_http SHARED plugins/output_http/output_http.c plugins/output_http/httpd.c)
set_target_properties(output_http PROPERTIES PREFIX "")

# Optional: WebP snapshot support (/?action=webpsnapshot)
# Requires libwebp-dev and libjpeg-dev.  Silently disabled if either is absent.
find_package(JPEG)
find_package(PkgConfig)
if(PkgConfig_FOUND OR PKG_CONFIG_FOUND)
    pkg_check_modules(WEBP libwebp)
endif()

if(JPEG_FOUND AND WEBP_FOUND)
    message(STATUS "WebP snapshot support enabled")
    target_compile_definitions(output_http PRIVATE HAVE_WEBP)
    target_include_directories(output_http PRIVATE ${JPEG_INCLUDE_DIR} ${WEBP_INCLUDE_DIRS})
    target_link_libraries(output_http ${JPEG_LIBRARIES} ${WEBP_LIBRARIES})
else()
    if(NOT JPEG_FOUND)
        message(STATUS "WebP snapshot support disabled: libjpeg not found")
    endif()
    if(NOT WEBP_FOUND)
        message(STATUS "WebP snapshot support disabled: libwebp not found")
    endif()
endif()


include(CPackConfig.cmake)

include(GNUInstallDirs)
install(TARGETS mjpg-streamer DESTINATION ${CMAKE_INSTALL_BINDIR})
install(TARGETS input_uvc DESTINATION /usr/lib/mjpg-streamer/)
install(TARGETS output_http DESTINATION /usr/lib/mjpg-streamer/)
