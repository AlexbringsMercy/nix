# Vendored from caelestia-dots/shell — plugin/src/Caelestia/Internal/CMakeLists.txt. Aurora build; local changes tracked in git.
qml_module(caelestia-internal
    URI Caelestia.Internal
    SOURCES
        circularbuffer.cpp
        circularindicatormanager.cpp
        linearindicatormanager.cpp
        hyprdevices.cpp
        hyprextras.cpp
        sparklineitem.cpp
        visualiserbars.cpp
    LIBRARIES
        Qt::Gui
        Qt::Quick
        Qt::Network
)
