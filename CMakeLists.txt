project(mjpg-streamer)

cmake_minimum_required(VERSION 2.8.12)

if(SYSROOT)
        include_directories(
                ${SYSROOT}/usr/include/
		${SYSROOT}/usr/include/arm-linux-gnueabihf/
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


include(CPackConfig.cmake)

include(GNUInstallDirs)
install(TARGETS mjpg-streamer DESTINATION ${CMAKE_INSTALL_BINDIR})
install(TARGETS input_uvc DESTINATION /usr/lib/mjpg-streamer/)
install(TARGETS output_http DESTINATION /usr/lib/mjpg-streamer/)
