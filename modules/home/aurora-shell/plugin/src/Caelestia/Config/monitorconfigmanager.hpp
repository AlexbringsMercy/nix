// Vendored from caelestia-dots/shell — plugin/src/Caelestia/Config/monitorconfigmanager.hpp. Aurora build; local changes tracked in git.
#pragma once

#include <qhash.h>
#include <qobject.h>
#include <qqmlengine.h>

namespace caelestia::config {

class GlobalConfig;
class TokenConfig;

class MonitorConfigManager : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    static MonitorConfigManager* instance();
    static MonitorConfigManager* create(QQmlEngine*, QJSEngine*);

    [[nodiscard]] Q_INVOKABLE GlobalConfig* configForScreen(const QString& screen);
    [[nodiscard]] Q_INVOKABLE TokenConfig* tokensForScreen(const QString& screen);

private:
    explicit MonitorConfigManager(QObject* parent = nullptr);

    struct ScreenOverlay {
        GlobalConfig* config = nullptr;
        TokenConfig* tokens = nullptr;
    };

    QHash<QString, ScreenOverlay> m_overlays;
};

} // namespace caelestia::config
