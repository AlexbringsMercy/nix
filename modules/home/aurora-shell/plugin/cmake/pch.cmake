# Vendored from caelestia-dots/shell — plugin/cmake/pch.cmake. Aurora build; local changes tracked in git.
add_library(caelestia-pch INTERFACE)
target_precompile_headers(caelestia-pch INTERFACE
    <qobject.h>
    <qqmlintegration.h>
    <qstring.h>
    <qqmlengine.h>
    <qloggingcategory.h>
    <qvariant.h>
    <qtimer.h>
    <qdir.h>
    <qlist.h>
    <qstringlist.h>
    <qpointer.h>
)
