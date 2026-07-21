local terminal = "kitty"
local browser = "google-chrome-stable --ozone-platform-hint=auto"
local files = "thunar"
local launcher = "rofi-toggle"

-- Bare Super opens the clickable launcher too; Super+D is the discoverable
-- Windows-style fallback.  Release avoids opening it during another chord.
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd(launcher), {
    release = true,
    description = "Desktop: Open applications"
})
hl.bind("SUPER + SUPER_R", hl.dsp.exec_cmd(launcher), { release = true })
hl.bind("SUPER + D", hl.dsp.exec_cmd(launcher), { description = "Desktop: Open applications" })

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
hl.bind("SUPER + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Float or tile" })
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Window: Toggle split" })
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"), { description = "Session: Lock" })
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("qs -c aurora-shell ipc call panels toggle power"), {
    description = "Session: Open power controls"
})

-- Aurora: keyboard window MOVE stays on Super+Shift+arrows (rearrange tiles).
for i, direction in ipairs({"left", "right", "up", "down"}) do
    local key = ({"Left", "Right", "Up", "Down"})[i]
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }), {
        description = "Window: Move " .. direction
    })
end

local function snap_window(size, position) -- Aurora: route percentage geometry through the legacy pixel dispatchers required by 0.55.
    hl.dispatch(hl.dsp.window.float({ action = "enable" })) -- Aurora: percentage snaps operate on a floating window rectangle.
    hl.dispatch(hl.dsp.exec_cmd('hyprctl dispatch resizewindowpixel "exact ' .. size .. ',activewindow"')) -- Aurora: the native Lua resize dispatcher accepts pixels only.
    hl.dispatch(hl.dsp.exec_cmd('hyprctl dispatch movewindowpixel "exact ' .. position .. ',activewindow"')) -- Aurora: anchor the resized window to the selected monitor half.
end -- Aurora: keep the snap binds on one verified dispatcher path.

-- Aurora: Windows-style snap on bare Super+arrows (operator 2026-07-21): Left/Right
-- halves, Up maximize, Down minimize — matching Windows muscle memory. Keyboard
-- tile-focus is dropped in favor of this; pointer focus is follow_mouse (input.lua).
hl.bind("SUPER + Left", function() snap_window("50% 100%", "0 0") end, { description = "Window: Snap left half" })
hl.bind("SUPER + Right", function() snap_window("50% 100%", "50% 0") end, { description = "Window: Snap right half" })
hl.bind("SUPER + Up", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Window: Maximize" })
hl.bind("SUPER + Down", hl.dsp.exec_cmd("window-minimize"), { description = "Window: Minimize" })

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
-- PipeWire changes are observed by the permanent QuickShell volume OSD. Using
-- SwayOSD for the same output would draw two overlays for every key press.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise --device=intel_backlight --min-brightness 2"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower --device=intel_backlight --min-brightness 2"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("brightnessctl --device=':white:kbd_backlight' set 10%+"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl --device=':white:kbd_backlight' set 10%-"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("swayosd-client --playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("swayosd-client --playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("swayosd-client --playerctl prev"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("swayosd-client --playerctl stop"), { locked = true })
