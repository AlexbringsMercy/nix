-- Generated atomically by apply-wallpaper. Load from hyprland.lua with:
-- dofile(os.getenv("XDG_CACHE_HOME") .. "/aurora-theme/hyprland.lua")
hl.config({
    general = {
        col = {
            active_border = {
                colors = {
                    "rgba({{colors.tertiary.default.hex_stripped}}ff)",
                    "rgba({{colors.primary.default.hex_stripped}}ff)",
                    "rgba({{colors.secondary.default.hex_stripped}}ff)"
                },
                angle = 45
            },
            inactive_border = "rgba(31405288)"
        }
    },
    group = {
        col = {
            border_active = "rgb({{colors.primary.default.hex_stripped}})",
            border_inactive = "rgb(314052)",
            border_locked_active = "rgb({{colors.error.default.hex_stripped}})",
            border_locked_inactive = "rgb(314052)"
        }
    }
})
