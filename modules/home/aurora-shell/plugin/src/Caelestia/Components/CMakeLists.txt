# Vendored from caelestia-dots/shell — plugin/src/Caelestia/Components/CMakeLists.txt. Aurora build; local changes tracked in git.
qml_module(caelestia-components
    URI Caelestia.Components
    SOURCES
        lazylistview.cpp
        wavyline.cpp
        buttonrow.cpp
    LIBRARIES
        Qt::Quick
)
