// Vendored from caelestia-dots/shell — plugin/src/Caelestia/Config/dashboardconfig.hpp. Aurora build; local changes tracked in git.
#pragma once

#include "configobject.hpp"

namespace caelestia::config {

class DashboardPerformance : public ConfigObject {
    Q_OBJECT
    QML_ANONYMOUS

    CONFIG_PROPERTY(bool, showBattery, true)
    CONFIG_PROPERTY(bool, showGpu, true)
    CONFIG_PROPERTY(bool, showCpu, true)
    CONFIG_PROPERTY(bool, showMemory, true)
    CONFIG_PROPERTY(bool, showStorage, true)
    CONFIG_PROPERTY(bool, showNetwork, true)

public:
    explicit DashboardPerformance(QObject* parent = nullptr)
        : ConfigObject(parent) {}
};

class DashboardConfig : public ConfigObject {
    Q_OBJECT
    QML_ANONYMOUS

    // Aurora: the dashboard UI is retired (GRAND_PLAN.md §10.2 item 19) and its
    // every entry path is disabled by operator decision 22, 2026-07-29 — an
    // explicit approved exception to the replacement-before-removal rule, because
    // the dashboard is unwanted duplication rather than a capability needing
    // temporary preservation. `enabled=false` makes Wrapper.qml's shouldBeActive
    // false regardless of screenState, so no entry path can raise the surface even
    // if one is missed; `showOnHover=false` kills the top-edge hover reveal in
    // Interactions.qml. The BACKEND SERVICES under services/ are untouched and
    // still run — the Stage 3 ilyamiro widgets consume them.
    CONFIG_PROPERTY(bool, enabled, false)
    CONFIG_PROPERTY(bool, showOnHover, false)
    CONFIG_PROPERTY(bool, showDashboard, true)
    CONFIG_PROPERTY(bool, showMedia, true)
    CONFIG_PROPERTY(bool, showPerformance, true)
    CONFIG_PROPERTY(bool, showWeather, true)
    CONFIG_GLOBAL_PROPERTY(int, mediaUpdateInterval, 500)
    CONFIG_GLOBAL_PROPERTY(int, resourceUpdateInterval, 1000)
    CONFIG_PROPERTY(int, dragThreshold, 50)
    CONFIG_SUBOBJECT(DashboardPerformance, performance)

public:
    explicit DashboardConfig(QObject* parent = nullptr)
        : ConfigObject(parent)
        , m_performance(new DashboardPerformance(this)) {}
};

} // namespace caelestia::config
