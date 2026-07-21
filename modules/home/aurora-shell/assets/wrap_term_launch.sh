#!/usr/bin/env sh
# Vendored from caelestia-dots/shell — assets/wrap_term_launch.sh. Aurora build; local changes tracked in git.

cat ~/.local/state/caelestia/sequences.txt 2>/dev/null

exec "$@"
