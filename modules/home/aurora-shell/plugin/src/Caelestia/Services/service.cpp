// Vendored from caelestia-dots/shell — plugin/src/Caelestia/Services/service.cpp. Aurora build; local changes tracked in git.
#include "service.hpp"

#include <qpointer.h>

namespace caelestia::services {

Service::Service(QObject* parent)
    : QObject(parent) {}

void Service::ref(QObject* sender) {
    if (m_refs.isEmpty()) {
        start();
    }

    QObject::connect(sender, &QObject::destroyed, this, &Service::unref);
    m_refs << sender;
}

void Service::unref(QObject* sender) {
    if (m_refs.remove(sender) && m_refs.isEmpty()) {
        stop();
    }
}

} // namespace caelestia::services
