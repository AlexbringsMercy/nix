# Vendored from caelestia-dots/shell — plugin/src/Caelestia/Models/CMakeLists.txt. Aurora build; local changes tracked in git.
qml_module(caelestia-models
    URI Caelestia.Models
    SOURCES
        filesystemmodel.hpp filesystemmodel.cpp
    LIBRARIES
        Qt::Gui
        Qt::Concurrent
)
