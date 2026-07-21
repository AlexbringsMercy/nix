// Vendored from caelestia-dots/shell — plugin/src/Caelestia/Services/sensorslib.hpp. Aurora build; local changes tracked in git.
#pragma once

#include <optional>

namespace caelestia::services::sensorslib {

void ensureInit();

[[nodiscard]] std::optional<double> cpuPackageTemp();
[[nodiscard]] std::optional<double> gpuPciAverageTemp();

} // namespace caelestia::services::sensorslib
