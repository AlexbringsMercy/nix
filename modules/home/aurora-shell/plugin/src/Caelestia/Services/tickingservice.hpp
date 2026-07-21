// Vendored from caelestia-dots/shell — plugin/src/Caelestia/Services/tickingservice.hpp. Aurora build; local changes tracked in git.
#pragma once

#include "service.hpp"

namespace caelestia::services {

class TickingService : public Service {
    Q_OBJECT

    Q_PROPERTY(int updateInterval READ updateInterval NOTIFY updateIntervalChanged)

public:
    explicit TickingService(QObject* parent = nullptr);

    [[nodiscard]] int updateInterval() const;

signals:
    void updateIntervalChanged();

protected:
    void start() final;
    void stop() final;

    virtual void tick() = 0;

private:
    void applyInterval(int ms);

    QTimer* m_timer;
    int m_interval = 1000;
    bool m_running = false;
};

} // namespace caelestia::services
