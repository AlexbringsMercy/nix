cmake_minimum_required(VERSION 3.27)

project(aurora-minimize
    DESCRIPTION "Aurora same-workspace minimize/restore plugin for Hyprland"
    VERSION 0.1
)

set(CMAKE_CXX_STANDARD 23)

file(GLOB_RECURSE SRC "*.cpp")

add_library(aurora-minimize SHARED ${SRC})

# Aurora: mirrors hyprbars/CMakeLists.txt's module list exactly (see
# hyprland-plugins' hyprbars, fetched by patchedHyprbars in ../default.nix) so
# this plugin links against the identical transitive set already proven to
# build against the pinned compositor -- hyprland.pc's own Requires: chain
# does not list pixman-1/libudev, so they are kept explicit rather than
# assumed transitive.
find_package(PkgConfig REQUIRED)
pkg_check_modules(deps REQUIRED IMPORTED_TARGET
    hyprland
    libdrm
    libinput
    libudev
    pixman-1
    wayland-server
    xkbcommon
)
target_link_libraries(aurora-minimize PRIVATE rt PkgConfig::deps)

install(TARGETS aurora-minimize)
