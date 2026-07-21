# Vendored from caelestia-dots/shell — plugin/src/Caelestia/Images/CMakeLists.txt. Aurora build; local changes tracked in git.
qml_module(caelestia-images
    URI Caelestia.Images
    SOURCES
        cachingimageprovider.cpp
        imagecacher.cpp
        iutils.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Concurrent
)
