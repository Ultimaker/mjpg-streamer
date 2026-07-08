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
target_compile_definitions(output_http PRIVATE MANAGMENT)

# Optional: WebP snapshot support (/?action=webpsnapshot)
# Requires libwebp-dev and libjpeg-dev.  Silently disabled if either is absent.
# Pass -DWITH_WEBP=OFF to cmake to explicitly disable even if the libs are present.
option(WITH_WEBP "Enable WebP snapshot support" ON)
find_package(JPEG)
find_package(PkgConfig)
if(PkgConfig_FOUND OR PKG_CONFIG_FOUND)
    pkg_check_modules(WEBP libwebp)
endif()

if(WITH_WEBP AND JPEG_FOUND AND WEBP_FOUND)
    message(STATUS "WebP snapshot support enabled")
    set(WEBP_ENABLED TRUE)
    target_compile_definitions(output_http PRIVATE HAVE_WEBP)
    target_include_directories(output_http PRIVATE ${JPEG_INCLUDE_DIR} ${WEBP_INCLUDE_DIRS})
    target_link_libraries(output_http ${JPEG_LIBRARIES} ${WEBP_LIBRARIES})
else()
    set(WEBP_ENABLED FALSE)
    if(NOT WITH_WEBP)
        message(STATUS "WebP snapshot support disabled: WITH_WEBP=OFF")
    endif()
    if(WITH_WEBP AND NOT JPEG_FOUND)
        message(STATUS "WebP snapshot support disabled: libjpeg not found")
    endif()
    if(WITH_WEBP AND NOT WEBP_FOUND)
        message(STATUS "WebP snapshot support disabled: libwebp not found")
    endif()
endif()


include(CPackConfig.cmake)

include(GNUInstallDirs)
install(TARGETS mjpg-streamer DESTINATION ${CMAKE_INSTALL_BINDIR})
install(TARGETS input_uvc DESTINATION /usr/lib/mjpg-streamer/)
install(TARGETS output_http DESTINATION /usr/lib/mjpg-streamer/)
