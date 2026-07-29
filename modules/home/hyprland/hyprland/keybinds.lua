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
-- Aurora: the dashboard UI is retired architecture (GRAND_PLAN.md §10.2 item 19),
-- but it is retired on paper only so far -- modules/dashboard/ is still 24 QML
-- files in the shell and caelestia:dashboard is still a live registered global.
-- The replacement widgets (calendar/media/weather/resources) arrive with the
-- Stage 3 top bar. Removing this bind now would delete the only access path to a
-- surface that still exists, with nothing in its place -- the same error the
-- operator caught when hiding special:min-* before the taskbar shipped would have
-- made minimize a one-way trip. It retires WITH the Stage 3 top bar, not before.
hl.bind("SUPER + K", hl.dsp.global("caelestia:dashboard"), { description = "Shell: Dashboard" }) -- Aurora: retained until Stage 3 ships the replacement widgets.
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
-- Aurora: Super+Alt+M (restore last minimized) is rebound below, alongside
-- Super+Down, once the auroraminimize helpers are declared -- both now target
-- hl.plugin.auroraminimize instead of the retired window-minimize script.
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

-- Aurora: Super+Up maximize (Windows-style, native 0.55 lua). Super+Down
-- minimize is rebound below alongside Super+Alt+M restore.
hl.bind("SUPER + Up", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }), { description = "Window: Maximize" })

-- Exact-resize marker: end-4/dots-hyprland — dots/.config/hypr/hyprland/keybinds.lua:359.
-- Active window/monitor geometry and scale handling: caelestia-dots/caelestia —
-- hypr/hyprland/keybinds.lua:109-119 and hypr/hyprland/functions.lua:52-75.
-- Native float/resize/move forms: caelestia-dots/caelestia —
-- hypr/hyprland/execs.lua:32-37 and hypr/hyprland/functions.lua:72-75.
-- Window at/size/floating fields: installed Hyprland 0.55.4 hl.meta.lua:717-748.
-- Float-toggle form: installed Hyprland 0.55.4 hyprland.lua:262.
-- Geometry constants mirror general.lua:20-21 and hyprbars.lua.in:12; hyprbars
-- reserves its bar above the client (hyprbars/barDeco.cpp:56-67 in the pinned source).
--
-- Aurora deterministic two-pane snap + minimize, additional forms cited against
-- the installed stub (/nix/store/.../hyprland-0.55.4/share/hypr/stubs/hl.meta.lua):
--   hl.get_window(selector)              -- HL.API, hl.meta.lua:804
--   hl.get_windows(filters?)             -- HL.API, hl.meta.lua:805
--   hl.on(event, cb) -> HL.EventSubscription -- HL.API, hl.meta.lua:811;
--     event names window.close/window.destroy/window.fullscreen/
--     window.move_to_workspace are literal members of the HL.EventName alias,
--     hl.meta.lua:19,20,21,23.
--   hl.timer(callback, {timeout, type}) -- HL.API, hl.meta.lua:813;
--     HL.TimerOptions.type "repeat"|"oneshot", hl.meta.lua:439-442.
--   HL.Window fields used below (address/floating/hidden/fullscreen/monitor/
--     workspace) — hl.meta.lua:717-749. HL.Workspace.id — hl.meta.lua:766.
--   hl.dsp.window.float({action="toggle", window=<HL.Window>}) is not itself
--     verbatim in prior code, but composes two independently-proven shapes
--     already in this file: action="toggle" with no window (line below, second
--     -press release) and action="on" with an explicit window object (the snap
--     path above) -- see report for why "toggle" is used instead of a "off"
--     literal that has no in-file precedent.
--   hl.plugin.auroraminimize.minimize(addr?) / .restore(addr) are NOT stub
--     forms -- hl.meta.lua only guarantees hl.plugin is an indexable namespace
--     (HL.PluginNamespace, hl.meta.lua:901-904) that a loaded plugin populates.
--     The method names/signatures come from this session's binding contract
--     (aurora minimize/restore interface), guarded below in case that plugin
--     is not yet loaded.
local snap_gaps_in = 5
local snap_gaps_out = 8
local snap_titlebar_height = 30

local function snap_geometry(screen, side)
    local monitor_width = math.floor((screen.width / screen.scale) + 0.5)
    local monitor_height = math.floor((screen.height / screen.scale) + 0.5)
    local usable_width = monitor_width - (2 * snap_gaps_out) - snap_gaps_in
    local left_width = math.floor(usable_width / 2)
    local snap_width = side == "right" and (usable_width - left_width) or left_width
    local move_x = screen.x + snap_gaps_out
    if side == "right" then
        move_x = move_x + left_width + snap_gaps_in
    end

    return {
        x = math.floor(move_x),
        y = math.floor(screen.y + snap_gaps_out + snap_titlebar_height),
        width = snap_width,
        height = monitor_height - (2 * snap_gaps_out) - snap_titlebar_height
    }
end

local function near(actual, expected)
    return type(actual) == "number" and math.abs(actual - expected) <= 1
end

local function matches_snap(win, geometry)
    return win.floating
        and type(win.at) == "table"
        and type(win.size) == "table"
        and near(win.at.x, geometry.x)
        and near(win.at.y, geometry.y)
        and near(win.size.x, geometry.width)
        and near(win.size.y, geometry.height)
end

local function is_half_snapped(win, screen)
    return matches_snap(win, snap_geometry(screen, "left"))
        or matches_snap(win, snap_geometry(screen, "right"))
end

-- Aurora: per-workspace pair state. This is plain process-local Lua state --
-- module-level `local` tables in this file's closure -- not written to disk
-- and not read from anywhere else. A `hyprctl reload` or a Hyprland restart
-- re-executes this whole chunk and rebuilds these tables empty; it does NOT
-- touch the physical windows, so a pair active at reload time keeps rendering
-- exactly as it was, but this file forgets it was ever a tracked pair (see
-- report for the consequence and the live-test needed to characterize it).
--
-- pairs_by_ws[workspace_id] = {
--   left = <address string> | nil,   -- current left-half occupant
--   right = <address string> | nil,  -- current right-half occupant
--   surplus = { [address] = true, ... }, -- every window this file minimized
--     because of this pair (replaced occupants + pair-completion sweep),
--     restorable as a set regardless of which one the rail restores first
--   completed = true | nil,          -- both sides have been filled at least
--     once; gates the one-time "minimize everything else" sweep so a later
--     replacement on an already-complete pair does not re-sweep and swallow
--     a genuinely new window that opened after completion (Requirement 3 reads
--     as a one-time event, not a standing rule -- flagged in the report as an
--     interpretation worth PM/Alex confirmation)
-- }
local pairs_by_ws = {}

-- Aurora: our own LIFO of addresses minimized through this file's actions,
-- solely to give Super+Alt+M a "last minimized" target -- the auroraminimize
-- restore(addr) call requires an explicit address, and the binding contract
-- does not expose a "restore most recent" query. A minimize triggered by any
-- other surface (e.g. the rail calling hl.plugin.auroraminimize.minimize
-- directly) will not appear here; pair bookkeeping does not depend on this
-- stack (see workspace_windows/reconcile below, which read live window state
-- instead), only the redundant Super+Alt+M hotkey does.
local minimize_stack = {}

local function pair_state(ws_id)
    local s = pairs_by_ws[ws_id]
    if not s then
        s = { left = nil, right = nil, surplus = {} }
        pairs_by_ws[ws_id] = s
    end
    return s
end

-- Aurora: reads win.workspace on every client directly -- the same per-client
-- field `hyprctl clients -j` reports and that a minimized window keeps -- and
-- never HL.Workspace.windows (an aggregate count) or anything derived from
-- `hyprctl workspaces -j`. Per the binding contract: detaching a minimized
-- window's layout target removes it from the workspace's tiling target list,
-- so the workspaces aggregate under-counts a workspace holding minimized
-- windows; occupancy must come from each client's own record instead.
local function workspace_windows(ws_id)
    local result = {}
    for _, w in ipairs(hl.get_windows()) do
        if w.workspace and w.workspace.id == ws_id then
            table.insert(result, w)
        end
    end
    return result
end

-- Aurora: the sanctioned minimize/restore backend (binding contract). Guarded
-- so a missing/not-yet-loaded auroraminimize plugin degrades to a silent
-- no-op -- the window is simply left exactly as it was, visible and tiled --
-- rather than a hard Lua error that would break every other bind in this
-- file, or a half-applied state that could strand a window unrepresented
-- anywhere. Returns true only when the plugin call was actually made, so
-- callers only record "surplus" bookkeeping for windows that were genuinely
-- minimized.
local function minimize_window(addr)
    if not addr then return false end
    if not (hl.plugin and hl.plugin.auroraminimize and hl.plugin.auroraminimize.minimize) then
        return false
    end
    hl.plugin.auroraminimize.minimize(addr)
    table.insert(minimize_stack, addr)
    return true
end

local function restore_window(addr)
    if not addr then return false end
    if not (hl.plugin and hl.plugin.auroraminimize and hl.plugin.auroraminimize.restore) then
        return false
    end
    hl.plugin.auroraminimize.restore(addr)
    for i = #minimize_stack, 1, -1 do
        if minimize_stack[i] == addr then
            table.remove(minimize_stack, i)
        end
    end
    return true
end

-- Aurora: a tracked half is "ok" (still a live, undisturbed pair member) only
-- if it is present, floating, not hidden, not fullscreen/maximized, still on
-- its own workspace, and still exactly at its side's snap geometry -- checked
-- against the window's own monitor (win.monitor), not hl.get_active_monitor(),
-- because reconciliation can run while a different window/monitor is active.
-- Any other state (moved, resized, unsnapped, maximized, closed, or dragged to
-- another workspace) means "not ok" and triggers dissolution for that side.
local function side_ok(win, ws_id, side)
    return win ~= nil
        and win.floating
        and not win.hidden
        and (win.fullscreen == 0 or win.fullscreen == nil)
        and win.monitor ~= nil
        and win.workspace ~= nil
        and win.workspace.id == ws_id
        and matches_snap(win, snap_geometry(win.monitor, side))
end

-- Aurora: tears a pair down and returns the workspace to ordinary tiling.
-- opts.skip_left/skip_right mark a side that already changed itself (dragged,
-- unsnapped, maximized, or gone) and must not be touched again; the other,
-- still-snapped side is toggled back out of floating so it rejoins the
-- dwindle tree, and every surplus window this pair minimized is restored.
local function dissolve_pair(ws_id, opts)
    local s = pairs_by_ws[ws_id]
    if not s then return end
    opts = opts or {}

    if s.left and not opts.skip_left then
        local win = hl.get_window(s.left)
        if win and win.floating then
            hl.dispatch(hl.dsp.window.float({ action = "toggle", window = win }))
        end
    end
    if s.right and not opts.skip_right then
        local win = hl.get_window(s.right)
        if win and win.floating then
            hl.dispatch(hl.dsp.window.float({ action = "toggle", window = win }))
        end
    end

    for addr in pairs(s.surplus) do
        local win = hl.get_window(addr)
        if win and win.hidden then
            restore_window(addr)
        end
    end

    pairs_by_ws[ws_id] = nil
end

-- Aurora: re-validates one workspace's tracked pair. This is the single choke
-- point that notices (a) a half was dragged/unsnapped/maximized/closed/moved
-- to another workspace, and (b) a surplus window came back -- whether restored
-- through this file's own Super+Alt+M or through the rail calling
-- hl.plugin.auroraminimize.restore directly, which this file cannot hook.
local function reconcile_pair(ws_id)
    local s = pairs_by_ws[ws_id]
    if not s then return end

    local left_win = s.left and hl.get_window(s.left)
    local right_win = s.right and hl.get_window(s.right)
    local left_ok = (not s.left) or side_ok(left_win, ws_id, "left")
    local right_ok = (not s.right) or side_ok(right_win, ws_id, "right")

    local surplus_returned = false
    for addr in pairs(s.surplus) do
        local win = hl.get_window(addr)
        if not win or not win.hidden then
            surplus_returned = true
            break
        end
    end

    -- Aurora: a window opened AFTER the pair completed dissolves it. The
    -- completion sweep is deliberately one-time (gated on s.completed), so a new
    -- window is never minimized -- it must surface normally. But leaving the pair
    -- standing would strand two floating halves over a freshly tiled window and
    -- keep stale bookkeeping alive, so the pair returns to ordinary tiling
    -- instead. Only a *strict* pair reacts: with a single side snapped there is
    -- no pair to dissolve and new windows tile normally as they always have.
    local intruder = false
    if s.left and s.right then
        for _, w in ipairs(workspace_windows(ws_id)) do
            if not w.hidden and w.address ~= s.left and w.address ~= s.right and not s.surplus[w.address] then
                intruder = true
                break
            end
        end
    end

    if not left_ok or not right_ok or surplus_returned or intruder then
        dissolve_pair(ws_id, { skip_left = not left_ok, skip_right = not right_ok })
    end
end

local function reconcile_all_pairs()
    local ok, err = pcall(function()
        for ws_id in pairs(pairs_by_ws) do
            reconcile_pair(ws_id)
        end
    end)
    if not ok then
        print("aurora snap: reconcile_all_pairs error: " .. tostring(err))
    end
end

local function half_snap(side)
    local win = hl.get_active_window()
    local screen = hl.get_active_monitor()
    if not (win and screen and type(screen.width) == "number" and type(screen.height) == "number"
        and type(screen.scale) == "number" and screen.scale > 0) then
        return
    end

    -- A second Left/Right press on either half releases the float back into the
    -- dwindle tree. After a native Super+LMB drag changes the geometry, the window
    -- is an ordinary float again and the next arrow press snaps it rather than tiles it.
    if is_half_snapped(win, screen) then
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
        -- Aurora: an explicit unsnap is one of the pair-dissolution triggers.
        -- Reconcile immediately so the opposite half and any surplus return to
        -- ordinary tiling without waiting for the poll timer below.
        reconcile_all_pairs()
        return
    end

    local geometry = snap_geometry(screen, side)

    -- Floating first is explicit: exact pixel resize/move cannot half-snap a tiled
    -- dwindle node without removing it from the layout tree. Exact coordinates
    -- address the client box, so y includes the reserved bar and height excludes it.
    local actions = {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.resize({ x = geometry.width, y = geometry.height, "exact", window = win }),
        hl.dsp.window.move({ x = geometry.x, y = geometry.y, relative = false, window = win })
    }
    for _, action in ipairs(actions) do
        hl.dispatch(action)
    end

    local ws = win.workspace
    if not ws then return end
    local s = pair_state(ws.id)

    -- Requirement: snapping onto an already-occupied side minimizes the
    -- previous occupant of that side (a replacement, not itself a dissolution
    -- -- the pair keeps going with the new window in that slot).
    local occupant = s[side]
    if occupant and occupant ~= win.address then
        if minimize_window(occupant) then
            s.surplus[occupant] = true
        end
    end
    s[side] = win.address

    -- Requirement: once both sides are filled, every other visible window on
    -- this workspace is minimized -- a one-time sweep at the moment of
    -- completion (see the `completed` note on pairs_by_ws above).
    local other_side = side == "left" and "right" or "left"
    local other = s[other_side]
    if other and other ~= win.address and not s.completed then
        for _, w in ipairs(workspace_windows(ws.id)) do
            if not w.hidden and w.address ~= win.address and w.address ~= other and not s.surplus[w.address] then
                if minimize_window(w.address) then
                    s.surplus[w.address] = true
                end
            end
        end
        s.completed = true
    end
end

hl.bind("SUPER + Left", function() half_snap("left") end, { description = "Window: Snap left half" })
hl.bind("SUPER + Right", function() half_snap("right") end, { description = "Window: Snap right half" })

-- Aurora: no window-moved/window-resized event exists on this build's Lua
-- event surface (the full HL.EventName set is enumerated at hl.meta.lua:5-33),
-- so drag/resize/unsnap detection is polling-based: every tick, each tracked
-- half is re-checked against its exact expected snap geometry via side_ok.
-- The four explicit events below give close/maximize/cross-workspace-move an
-- immediate reconcile instead of waiting a full poll interval; the timer
-- remains the ground-truth safety net for drag/resize/unsnap and for a
-- surplus window restored from the rail, whose restore call this file cannot
-- observe directly.
hl.timer(function() reconcile_all_pairs() end, { timeout = 400, type = "repeat" })

for _, event in ipairs({ "window.close", "window.destroy", "window.fullscreen", "window.move_to_workspace" }) do
    hl.on(event, function(...) reconcile_all_pairs() end)
end

hl.bind("SUPER + Down", function()
    local win = hl.get_active_window()
    if win then minimize_window(win.address) end
end, { description = "Window: Minimize" })

hl.bind("SUPER + ALT + M", function()
    while #minimize_stack > 0 do
        local addr = table.remove(minimize_stack)
        local win = hl.get_window(addr)
        if win and win.hidden then
            restore_window(addr)
            reconcile_all_pairs()
            return
        end
        -- stale entry (already restored elsewhere, or the window closed while
        -- minimized): drop it and keep looking down the stack.
    end
end, { description = "Window: Restore last minimized" })

for workspace = 1, 5 do -- Aurora: expose the five persistent daily workspaces.
    hl.bind("SUPER + " .. workspace, hl.dsp.focus({ workspace = workspace }), {
        description = "Workspace: Focus " .. workspace
    })
    hl.bind("SUPER + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = true }), {
        description = "Workspace: Move window to " .. workspace
    })
end

-- Aurora: both capture paths run inside the shell (modules/areapicker), which
-- hides its selection UI and waits for a fresh frame before saving, so no
-- selector overlay can be baked into the output. The shell registers these
-- names as global shortcuts, the same route the launcher, dashboard and nexus
-- binds already use.
hl.bind("SUPER + SHIFT + S", hl.dsp.global("caelestia:screenshot"), {
    locked = true,
    description = "Utilities: Select screenshot to file and clipboard"
})
hl.bind("Print", hl.dsp.global("caelestia:screenshotFull"), {
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
