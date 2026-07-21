-- Aurora desktop: Hyprland 0.55 native Lua configuration.
-- Order is intentional: environment and core settings precede consumers.
require("hyprland.env")
require("hyprbars") -- Aurora: load and configure the matched titlebar plugin before window rules.
require("hyprland.general")
require("hyprland.animations")
require("hyprland.input")
require("hyprland.rules")
require("hyprland.keybinds")
require("hyprland.autostart")

-- Wallpaper changes atomically replace this optional final override and then
-- request a normal compositor reload. The curated static palette above remains
-- a valid fallback if the cache is ever removed manually.
local cache_home = os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")
local theme_path = cache_home .. "/aurora-theme/hyprland.lua"
local theme_file = io.open(theme_path, "r")
if theme_file then
    theme_file:close()
    local loaded, load_error = pcall(dofile, theme_path)
    if not loaded then
        print("Aurora theme override failed: " .. tostring(load_error))
    end
end
