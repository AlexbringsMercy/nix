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
-- Aurora: Super+K is deliberately unbound. The dashboard UI is retired
-- (GRAND_PLAN.md §10.2 item 19) and every entry path to it is disabled by
-- operator decision 22, 2026-07-29 -- an explicit approved EXCEPTION to the
-- replacement-before-removal rule (decision 21), granted because the dashboard is
-- unwanted duplication rather than a capability needing temporary preservation.
-- The "caelestia:dashboard" global is no longer registered by the shell, so this
-- bind would dispatch a name that does not exist. Its backend services still run;
-- the Stage 3 ilyamiro widgets consume them.
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
-- Geometry: the pane gap now derives from the live compositor config
-- (general.gaps_in/general.gaps_out) instead of a hand-copied mirror of
-- general.lua:20-21; hyprbars.lua.in:20 still owns bar_height=30, a
-- PER-WINDOW decoration extent applied separately below exactly as before
-- (hyprbars reserves its bar above the client, hyprbars/barDeco.cpp:56-67 in
-- the pinned source) -- see the block below for why THAT one constant stays
-- a literal.
--
-- Aurora deterministic two-pane snap + minimize, additional forms cited against
-- the installed stub (/nix/store/.../hyprland-0.55.4/share/hypr/stubs/hl.meta.lua):
--   hl.get_window(selector)              -- HL.API, hl.meta.lua:804
--   hl.get_windows(filters?)             -- HL.API, hl.meta.lua:805
--   hl.get_config(key)                   -- HL.API, hl.meta.lua:793; "general.gaps_in"/
--     "general.gaps_out" are literal HL.ConfigKey members, hl.meta.lua:160-161 (alias)
--     and hl.meta.lua:1034-1035 (typed integer|HL.CssGap, alias at hl.meta.lua:382).
--   hl.on(event, cb) -> HL.EventSubscription -- HL.API, hl.meta.lua:811;
--     event names window.close/window.destroy/window.fullscreen/
--     window.move_to_workspace are literal members of the HL.EventName alias,
--     hl.meta.lua:19,20,21,23.
--   hl.timer(callback, {timeout, type}) -- HL.API, hl.meta.lua:813;
--     HL.TimerOptions.type "repeat"|"oneshot", hl.meta.lua:439-442.
--   HL.Window fields used below (address/floating/hidden/fullscreen/monitor/
--     workspace) — hl.meta.lua:717-749. HL.Workspace.id — hl.meta.lua:766.
--   HL.Monitor fields (x/y/width/height/scale/name) — hl.meta.lua:668-688.
--   hl.dsp.window.float({action="toggle", window=<HL.Window>}) is not itself
--     verbatim in prior code, but composes two independently-proven shapes
--     already in this file: action="toggle" with no window (line below, second
--     -press release) and action="on" with an explicit window object (the snap
--     path above) -- see report for why "toggle" is used instead of a "off"
--     literal that has no in-file precedent.
--   hl.plugin.auroraminimize.minimize(addr?) / .restore(addr) are NOT stub
--     forms -- hl.meta.lua only guarantees hl.plugin is an indexable namespace
--     (HL.PluginNamespace, hl.meta.lua:901-904) that a loaded plugin populates.
--     Confirmed live (2026-07-29): `hyprctl plugins list` shows aurora-minimize
--     loaded, and modules/home/hyprland/aurora-minimize/main.cpp:312-313
--     registers exactly these two names via HyprlandAPI::addLuaFunction(PHANDLE,
--     "auroraminimize", "minimize"/"restore", ...) -- the guard below is
--     defense-in-depth, not evidence the plugin is actually missing.
--
-- Work-area derivation (fixes the reported "offset beyond the usable
-- upper-left work area" / "does not occupy the exact half" bug): the
-- installed 0.55.4 HL.Monitor Lua object (hl.meta.lua:668-688) has NO
-- `reserved` field -- only HL.MonitorSpec (the WRITE-only input to
-- hl.monitor(), hl.meta.lua:560-561) types `reserved`/`reserved_area`, and
-- that sets a rule, it does not read the compositor's live computed
-- exclusive-zone total. This exact gap is documented upstream:
-- github.com/hyprwm/Hyprland discussion #14378 ("Lua API for getting monitor
-- reserved areas") -- a maintainer confirms a real `.reserved` read accessor
-- exists on HEAD (src/config/lua/objects/LuaMonitor.cpp, monitorIndex():
-- `else if (key == "reserved")`, pushing a table with top/right/bottom/left)
-- but not yet in 0.55.0/0.55.2. This file speculatively probes
-- `screen.reserved` first (safe even if absent: Lua's C-function __index
-- metamethod here returns nil for any key it does not recognise rather than
-- erroring) in case this machine's installed 0.55.4 already carries it
-- despite the stub not typing it, then falls back to the one workaround that
-- discussion identifies for any 0.55.x release: shell out to
-- `hyprctl monitors -j` and read the "reserved" field the compositor already
-- computes. That field's array order -- [left, top, right, bottom] -- comes
-- from Hyprland's own current JSON serialiser (src/ipc/s1/Commands.cpp:
-- `"reserved": [{}, {}, {}, {}]` populated from `m->m_reservedArea.left()`,
-- `.top()`, `.right()`, `.bottom()` in that literal order) and was
-- cross-checked against this machine's live numbers (`hyprctl monitors -j`,
-- 2026-07-29: reserved = [60, 10, 10, 10], i.e. left=60/top=10/right=10/
-- bottom=10): already-tiled windows on this box sit at logical at=[70,50]
-- (`hyprctl clients -j`), and 60 (reserved.left) + 8 (gaps_out) = 68 ~= 70,
-- 10 (reserved.top) + 30 (hyprbars bar_height) + 8 (gaps_out) = 48 ~= 50 --
-- both within a couple of px of border/rounding, corroborating both the
-- field order and that reserved is already in the same logical/layout
-- coordinate space as window at/size and monitor x/y (no further scale
-- division needed). io.popen itself is not an hl.* stub form -- it is the
-- ordinary Lua 5.4 `io` library, already proven reachable from this exact
-- native-Lua config chain: hyprland.lua:17 already calls io.open and
-- hyprland.lua:15 already calls os.getenv from the same process that
-- requires this file. Whether io.popen specifically (as opposed to
-- io.open) is left enabled inside Hyprland's embedded Lua state is the one
-- piece of this that needs a live test (flagged in the report) -- it cannot
-- be proven without the real compositor process, only reproduced against a
-- standalone Lua 5.4 interpreter outside Hyprland (which does work).
local snap_titlebar_height = 30

local function compositor_gap(key, default)
    local ok, value = pcall(hl.get_config, key)
    if ok and type(value) == "number" then
        return value
    end
    return default
end

-- Aurora: derive the pane/outer gap from the live compositor config instead
-- of a hand-copied constant that silently goes stale if general.lua ever
-- changes. The defaults below (matching this project's current general.lua
-- gaps_in=5/gaps_out=8) apply only if hl.get_config errors or returns a
-- non-numeric HL.CssGap table (asymmetric per-side gaps) -- a safe last
-- resort, never a silently wrong answer.
local snap_gaps_in = compositor_gap("general.gaps_in", 5)
local snap_gaps_out = compositor_gap("general.gaps_out", 8)

-- Aurora: split one already-fetched `hyprctl monitors -j` JSON array into its
-- top-level monitor objects by brace-depth counting -- deliberately not a
-- full JSON parser, scoped to this one payload shape, where monitor
-- names/descriptions never contain literal braces -- so a nested field such
-- as "activeWorkspace": {...} can never be mistaken for the end of the
-- monitor object that contains it.
local function json_top_level_objects(raw)
    local objects = {}
    local depth = 0
    local start = nil
    for i = 1, #raw do
        local c = raw:sub(i, i)
        if c == "{" then
            if depth == 0 then start = i end
            depth = depth + 1
        elseif c == "}" then
            depth = depth - 1
            if depth == 0 and start then
                table.insert(objects, raw:sub(start, i))
                start = nil
            end
        end
    end
    return objects
end

-- Aurora: the one workaround github.com/hyprwm/Hyprland discussion #14378
-- documents for reading a monitor's real reserved-area total on any 0.55.x
-- release -- shell out to `hyprctl monitors -j` and read the field the
-- compositor itself already computes (every layer-shell exclusive zone plus
-- any static monitor-rule reserved value, summed), matched to the right
-- output by name so a multi-monitor setup cannot pick up a sibling display's
-- margins. Only called once per explicit Super+Left/Right keypress -- never
-- from the 400ms poll timer, see side_ok below, which compares against a
-- geometry snapshot captured at snap time instead of recomputing this on
-- every tick -- so the discussion's "majorly slows down event handlers"
-- warning does not apply to this call site. Fails closed to all-zero
-- margins (the previous, rail-unaware math) rather than erroring, so a
-- shell/parse failure degrades to the old behaviour instead of breaking
-- every bind in this file.
local function monitor_reserved_via_hyprctl(screen)
    local fallback = { left = 0, top = 0, right = 0, bottom = 0 }
    if not (screen and screen.name and io and io.popen) then
        return fallback
    end

    local ok, handle = pcall(io.popen, "hyprctl monitors -j 2>/dev/null")
    if not ok or not handle then
        return fallback
    end

    local raw = handle:read("*a")
    handle:close()
    if type(raw) ~= "string" or raw == "" then
        return fallback
    end

    for _, chunk in ipairs(json_top_level_objects(raw)) do
        local name = chunk:match('"name"%s*:%s*"([^"]*)"')
        if name == screen.name then
            local l, t, r, b = chunk:match(
                '"reserved"%s*:%s*%[%s*(%-?%d+)%s*,%s*(%-?%d+)%s*,%s*(%-?%d+)%s*,%s*(%-?%d+)%s*%]'
            )
            if l then
                return { left = tonumber(l), top = tonumber(t), right = tonumber(r), bottom = tonumber(b) }
            end
            return fallback
        end
    end

    return fallback
end

-- Aurora: try the native Lua accessor first (speculative -- see the citation
-- block above), fall back to the hyprctl shell-out only if it is absent.
local function monitor_reserved(screen)
    if type(screen.reserved) == "table" and type(screen.reserved.left) == "number" then
        return screen.reserved
    end
    return monitor_reserved_via_hyprctl(screen)
end

-- Aurora: exact usable-half geometry, now excluding the monitor's real
-- reserved margins (left rail + any other layer-shell exclusive zone)
-- instead of only the constant outer/inner gaps -- the fix for "offset
-- beyond the usable upper-left work area" / "does not occupy the exact
-- half". `reserved` is pre-fetched once per keypress by the caller
-- (half_snap) and passed in so this can be called twice (left+right)
-- without shelling out twice.
local function snap_geometry(screen, reserved, side)
    local monitor_width = math.floor((screen.width / screen.scale) + 0.5)
    local monitor_height = math.floor((screen.height / screen.scale) + 0.5)

    local usable_left = screen.x + reserved.left
    local usable_top = screen.y + reserved.top
    local usable_right = screen.x + monitor_width - reserved.right
    local usable_bottom = screen.y + monitor_height - reserved.bottom

    local usable_width = (usable_right - snap_gaps_out) - (usable_left + snap_gaps_out)
    local left_width = math.floor((usable_width - snap_gaps_in) / 2)
    local snap_width = side == "right" and (usable_width - snap_gaps_in - left_width) or left_width

    local move_x = usable_left + snap_gaps_out
    if side == "right" then
        move_x = move_x + left_width + snap_gaps_in
    end

    return {
        x = math.floor(move_x),
        y = math.floor(usable_top + snap_gaps_out + snap_titlebar_height),
        width = snap_width,
        height = (usable_bottom - snap_gaps_out) - (usable_top + snap_gaps_out) - snap_titlebar_height
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

local function is_half_snapped(win, left_geometry, right_geometry)
    return matches_snap(win, left_geometry) or matches_snap(win, right_geometry)
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
--   left_geometry = {x,y,width,height} | nil,  -- exact geometry applied when
--     this side was last placed. side_ok compares a tracked window's LIVE
--     at/size against THIS stored snapshot rather than recomputing
--     snap_geometry() (and therefore re-shelling-out to hyprctl) on every
--     400ms poll tick -- see monitor_reserved_via_hyprctl's own comment on
--     why that call site is deliberately kept off the hot path.
--   right_geometry = ... (same, for the right side)
--   surplus = { [address] = true, ... }, -- every window this file minimized
--     because of this pair, restorable as a set regardless of which one the
--     rail restores first
-- }
--
-- Aurora: there is deliberately no `completed` gate any more. The prior
-- design minimized a replaced same-side occupant immediately but only swept
-- every OTHER visible window once, the first time both sides became filled
-- -- which left any window that predates this file's own tracking (the very
-- first snap on a workspace that already had other tiled windows, or any
-- snap after a `hyprctl reload` wiped this file's in-memory state) completely
-- unrecognised as an occupant: neither replaced nor swept. That is exactly
-- the operator-reported bug ("the existing surplus window remains tiled
-- beneath/alongside it instead of minimizing"). half_snap below now
-- reconciles unconditionally on every call, against LIVE workspace occupancy
-- rather than only its own remembered addresses, and does so BEFORE placing
-- the active window (not after) -- deterministic ordering per the operator's
-- explicit correction, rather than relying on Hyprland's dwindle
-- opportunistically settling first.
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
-- its own workspace, and still exactly at the geometry THIS file applied when
-- it was placed -- the stored left_geometry/right_geometry snapshot, not a
-- freshly recomputed snap_geometry(), which would mean re-deriving the work
-- area (and therefore re-shelling out to hyprctl) on every 400ms poll tick.
-- Any other state (moved, resized, unsnapped, maximized, closed, or dragged to
-- another workspace) means "not ok" and triggers dissolution for that side.
local function side_ok(win, ws_id, side)
    local s = pairs_by_ws[ws_id]
    local geometry = s and s[side .. "_geometry"]
    return win ~= nil
        and win.floating
        and not win.hidden
        and (win.fullscreen == 0 or win.fullscreen == nil)
        and win.workspace ~= nil
        and win.workspace.id == ws_id
        and geometry ~= nil
        and matches_snap(win, geometry)
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

    -- Aurora: a window opened AFTER the pair completed dissolves it. half_snap's
    -- own reconcile-before-placement sweep only runs on an explicit
    -- Super+Left/Right press, so a window that opens on its own while a
    -- complete pair is already showing is never minimized by that path -- it
    -- must surface normally. But leaving the pair standing would strand two
    -- floating halves over a freshly tiled window and keep stale bookkeeping
    -- alive, so the pair returns to ordinary tiling instead. Only a *strict*
    -- pair reacts: with a single side snapped there is no pair to dissolve and
    -- new windows tile normally as they always have.
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

    -- Aurora: one work-area fetch per keypress (see monitor_reserved's
    -- comment for why this must never move onto the poll-timer hot path),
    -- reused below both for the second-press/release check and for whichever
    -- side is actually being snapped, so a single Super+Left/Right press
    -- never shells out to hyprctl more than once.
    local reserved = monitor_reserved(screen)
    local left_geometry = snap_geometry(screen, reserved, "left")
    local right_geometry = snap_geometry(screen, reserved, "right")
    local geometry = side == "left" and left_geometry or right_geometry

    -- A second Left/Right press on either half releases the float back into the
    -- dwindle tree. After a native Super+LMB drag changes the geometry, the window
    -- is an ordinary float again and the next arrow press snaps it rather than tiles it.
    if is_half_snapped(win, left_geometry, right_geometry) then
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
        -- Aurora: an explicit unsnap is one of the pair-dissolution triggers.
        -- Reconcile immediately so the opposite half and any surplus return to
        -- ordinary tiling without waiting for the poll timer below.
        reconcile_all_pairs()
        return
    end

    local ws = win.workspace
    if not ws then return end
    local s = pair_state(ws.id)
    local other_side = side == "left" and "right" or "left"

    -- Aurora: reconcile FIRST, place SECOND -- deterministic ordering per the
    -- operator's explicit correction ("the operation must reconcile/minimize
    -- the existing occupant and surplus windows before final placement...
    -- must not rely on Hyprland opportunistically allocating a dwindle slot
    -- before the snap state machine finishes"). Everything currently visible
    -- on this workspace except the active window and (if still genuinely
    -- alive, unhidden and on this workspace) the opposite side's current
    -- occupant is surplus and gets minimized right now, before any
    -- float/resize/move dispatch for the active window -- so Hyprland's own
    -- dwindle layout has already settled by the time the active window is
    -- placed, instead of racing a float toggle against a not-yet-issued
    -- minimize. This also closes the bootstrap/amnesia gap: an occupant is
    -- discovered from LIVE workspace state every call, not only from this
    -- file's own previous bookkeeping (s[side]), so the very first snap on a
    -- workspace that already has other tiled windows -- or any snap after a
    -- `hyprctl reload` reset this file's in-memory pair state -- still
    -- correctly clears whatever else is already there, rather than the
    -- occupant silently being nil and nothing getting minimized (the
    -- operator-reported bug).
    local keep = { [win.address] = true }
    local other_addr = s[other_side]
    if other_addr then
        local other_win = hl.get_window(other_addr)
        if other_win and not other_win.hidden and other_win.workspace and other_win.workspace.id == ws.id then
            keep[other_addr] = true
        else
            s[other_side] = nil
            s[other_side .. "_geometry"] = nil
        end
    end

    for _, w in ipairs(workspace_windows(ws.id)) do
        if not w.hidden and not keep[w.address] then
            if minimize_window(w.address) then
                s.surplus[w.address] = true
            end
        end
    end

    -- Floating first is explicit: exact pixel resize/move cannot half-snap a tiled
    -- dwindle node without removing it from the layout tree. Exact coordinates
    -- address the client box, so y includes the reserved bar and height excludes it.
    -- By this point every surplus/occupant window above has already been
    -- minimized, so this places into a settled layout rather than a
    -- transitional one.
    local actions = {
        hl.dsp.window.float({ action = "on", window = win }),
        hl.dsp.window.resize({ x = geometry.width, y = geometry.height, "exact", window = win }),
        hl.dsp.window.move({ x = geometry.x, y = geometry.y, relative = false, window = win })
    }
    for _, action in ipairs(actions) do
        hl.dispatch(action)
    end

    s[side] = win.address
    s[side .. "_geometry"] = geometry
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
