local terminal = "kitty"
local browser = "google-chrome-stable --ozone-platform-hint=auto"
local files = "thunar"

-- Bare Super opens the clickable launcher too; Super+D is the discoverable
-- Windows-style fallback.  Release avoids opening it during another chord.
hl.bind("SUPER + SUPER_L", hl.dsp.global("caelestia:launcher"), { -- Aurora: route the primary Apps entry to caelestia's registered launcher.
    release = true,
    description = "Desktop: Open applications"
})
hl.bind("SUPER + SUPER_R", hl.dsp.global("caelestia:launcher"), { release = true }) -- Aurora: keep either Super key on the shell launcher.
hl.bind("SUPER + D", hl.dsp.global("caelestia:launcher"), { description = "Desktop: Open applications" }) -- Aurora: keep the discoverable Apps fallback on caelestia too.

hl.bind("SUPER + Space", hl.dsp.global("caelestia:launcher"), { description = "Shell: Open launcher" }) -- Aurora: make Cmd+Space the headline caelestia launcher path.
hl.bind("SUPER + N", hl.dsp.global("caelestia:sidebar"), { description = "Shell: Notification history" }) -- Aurora: open caelestia's notification sidebar.
hl.bind("SUPER + K", hl.dsp.global("caelestia:dashboard"), { description = "Shell: Dashboard" }) -- Aurora: retain caelestia's upstream panels chord for the dashboard surface.
hl.bind("SUPER + U", hl.dsp.global("caelestia:utilities"), { description = "Shell: Utilities" }) -- Aurora: expose the utilities drawer directly.
hl.bind("SUPER + Comma", hl.dsp.global("caelestia:nexus"), { description = "Shell: Nexus settings" }) -- Aurora: use the familiar Cmd+, settings chord for Nexus.

hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal), { description = "Apps: Terminal" })
hl.bind("SUPER + E", hl.dsp.exec_cmd(files), { description = "Apps: Files" })
hl.bind("SUPER + B", hl.dsp.exec_cmd(browser), { description = "Apps: Browser" })

-- Apps with client-side title bars drag naturally.  These mouse bindings are
-- the universal fallback for undecorated tiled and floating clients.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Move" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize" })
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Window: Close" })
hl.bind("ALT + F4", hl.dsp.window.close(), { description = "Window: Close (Windows convention)" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Window: Maximize" })
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), { description = "Window: Fullscreen" })
hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("window-minimize restore"), { description = "Window: Restore last minimized" }) -- Aurora: expose the omarchy LIFO restore path until taskbar restore lands.
hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Float or tile" }) -- Aurora: free Cmd+Space for the launcher while retaining float-toggle.
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Window: Toggle split" })
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"), { description = "Session: Lock" })
hl.bind("CTRL + ALT + Delete", hl.dsp.global("caelestia:session"), { -- Aurora: replace the retired old-QuickShell power IPC with caelestia's session surface.
    description = "Session: Open power controls"
})

-- Aurora: keyboard window MOVE stays on Super+Shift+arrows (rearrange tiles).
for i, direction in ipairs({"left", "right", "up", "down"}) do
    local key = ({"Left", "Right", "Up", "Down"})[i]
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }), {
        description = "Window: Move " .. direction
    })
end

-- Aurora: Super+Up maximize / Super+Down minimize (Windows-style, native 0.55 lua).
hl.bind("SUPER + Up", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Window: Maximize" })
hl.bind("SUPER + Down", hl.dsp.exec_cmd("window-minimize"), { description = "Window: Minimize" })

-- Exact-resize marker: end-4/dots-hyprland — dots/.config/hypr/hyprland/keybinds.lua:359.
-- Active window/monitor geometry and scale handling: caelestia-dots/caelestia —
-- hypr/hyprland/keybinds.lua:109-119 and hypr/hyprland/functions.lua:52-75.
-- Native float/resize/move forms: caelestia-dots/caelestia —
-- hypr/hyprland/execs.lua:32-37 and hypr/hyprland/functions.lua:72-75.
local function half_snap(side)
    local win = hl.get_active_window()
    local screen = hl.get_active_monitor()
    if not (win and screen and type(screen.width) == "number" and type(screen.height) == "number" and type(screen.scale) == "number") then
        return
    end

    local monitor_width = math.floor((screen.width / screen.scale) + 0.5)
    local monitor_height = math.floor((screen.height / screen.scale) + 0.5)
    local split_x = math.floor(monitor_width / 2)
    local snap_width = side == "right" and (monitor_width - split_x) or split_x
    local move_x = math.floor(screen.x + (side == "right" and split_x or 0))
    local move_y = math.floor(screen.y)

    -- Floating first is explicit: exact pixel resize/move cannot half-snap a tiled
    -- dwindle node without removing it from the layout tree.
    local actions = {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.resize({ x = snap_width, y = monitor_height, "exact", window = win }),
        hl.dsp.window.move({ x = move_x, y = move_y, relative = false, window = win })
    }
    for _, action in ipairs(actions) do
        hl.dispatch(action)
    end
end

hl.bind("SUPER + Left", function() half_snap("left") end, { description = "Window: Snap left half" })
hl.bind("SUPER + Right", function() half_snap("right") end, { description = "Window: Snap right half" })

for workspace = 1, 5 do -- Aurora: expose the five persistent daily workspaces.
    hl.bind("SUPER + " .. workspace, hl.dsp.focus({ workspace = workspace }), {
        description = "Workspace: Focus " .. workspace
    })
    hl.bind("SUPER + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = true }), {
        description = "Workspace: Move window to " .. workspace
    })
end

hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("screenshot-area"), {
    locked = true,
    description = "Utilities: Select screenshot to file and clipboard"
})
hl.bind("Print", hl.dsp.exec_cmd("screenshot-full"), {
    locked = true,
    description = "Utilities: Full screenshot to file and clipboard"
})

-- Mac function row / multimedia keys.  Locked binds continue to work while the
-- session is locked; repeating applies only to continuous level adjustment.
-- Aurora: direct device/service commands are observed by caelestia, leaving one shell-owned OSD.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true }) -- Aurora: let caelestia observe source mute directly.
hl.bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true, repeating = true }) -- Aurora: let caelestia change brightness + show its own OSD (brightnessctl fired no OSD).
hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true, repeating = true }) -- Aurora: caelestia owns brightness + OSD.
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl --device=':white:kbd_backlight' set 10%+"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl --device=':white:kbd_backlight' set 10%-"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true }) -- Aurora: let caelestia's MPRIS service observe playback.
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true }) -- Aurora: map either play/pause key to the same MPRIS toggle.
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true }) -- Aurora: use the direct MPRIS next command.
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true }) -- Aurora: use playerctl's full previous verb.
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true }) -- Aurora: use the direct MPRIS stop command.
