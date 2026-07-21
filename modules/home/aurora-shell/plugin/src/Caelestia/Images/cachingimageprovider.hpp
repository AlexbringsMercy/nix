// Vendored from caelestia-dots/shell — plugin/src/Caelestia/Images/cachingimageprovider.hpp. Aurora build; local changes tracked in git.
#pragma once

#include "imagecacher.hpp"

#include <qquickimageprovider.h>

namespace caelestia::images {

class CachingImageProvider : public QQuickAsyncImageProvider {
public:
    using FillMode = ImageCacher::FillMode;

    explicit CachingImageProvider(FillMode fillMode);

    QQuickImageResponse* requestImageResponse(const QString& id, const QSize& requestedSize) override;

private:
    FillMode m_fillMode;
};

} // namespace caelestia::images
