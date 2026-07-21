# Vendored from caelestia-dots/shell — plugin/cmake/sensorslib.cmake. Aurora build; local changes tracked in git.
find_library(SENSORS_LIBRARY NAMES sensors REQUIRED)
find_path(SENSORS_INCLUDE_DIR NAMES sensors/sensors.h REQUIRED)
if(NOT TARGET Sensors::Sensors)
    add_library(Sensors::Sensors UNKNOWN IMPORTED)
    set_target_properties(Sensors::Sensors PROPERTIES
        IMPORTED_LOCATION "${SENSORS_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${SENSORS_INCLUDE_DIR}"
    )
endif()
