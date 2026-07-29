// Aurora same-workspace minimize/restore plugin.
//
// Mechanism: generalizes hyprwm/Hyprland's own built-in `toggleswallow`
// dispatcher (src/config/shared/actions/ConfigActions.cpp, Actions::toggleSwallow(),
// pinned tree /nix/store/cr4vq0w7dn9i5m19847mrl99rm24vsba-source) from "the one
// swallowed window" to an arbitrary window chosen by selector. toggleSwallow's
// own body is exactly:
//   pWindow->m_swallowed->setHidden(false);
//   g_layoutManager->newTarget(pWindow->m_swallowed->layoutTarget(), pWindow->m_workspace->m_space);
// and the inverse with setHidden(true) + removeTarget(). setHidden() drops the
// window from render (Renderer.cpp: isNotRenderable = w->isHidden() || ...) and
// input (Window.cpp: acceptsInput() == !isHidden() && !isInputBlocked());
// removeTarget()/newTarget() drop/restore it from the tiled or floating layout
// tree. CWindow::m_workspace itself is never written by either step, which is
// what keeps a minimized window's real workspace identity intact -- the
// property the previous special:min-<address> backend
// (scripts/window-minimize, retired alongside this plugin) did not have.
//
// Built ABI-pinned against the already-built compositor at
// /nix/store/wrz9r718svay8k5dhghzl4sf4w5ddfjb-hyprland-0.55.4 -- see
// modules/home/hyprland/default.nix's patchedAuroraMinimize derivation,
// modelled on the same file's patchedHyprbars.

#define WLR_USE_UNSTABLE

#include <algorithm>
#include <stdexcept>
#include <string>
#include <vector>

#include <hyprland/src/Compositor.hpp>
#include <hyprland/src/desktop/Workspace.hpp>
#include <hyprland/src/desktop/state/FocusState.hpp>
#include <hyprland/src/desktop/view/Window.hpp>
#include <hyprland/src/layout/LayoutManager.hpp>
#include <hyprland/src/layout/target/Target.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/SharedDefs.hpp>

#include <hyprutils/string/String.hpp>

extern "C" {
#include <lauxlib.h>
#include <lua.h>
}

static HANDLE PHANDLE = nullptr;

namespace {

    // Aurora: setHidden()/removeTarget() do not remember whether a window was
    // fullscreen -- CDwindleAlgorithm::removeTarget() defensively force-clears
    // fullscreen on detach (DwindleAlgorithm.cpp) but forgets the mode, and
    // CCompositor::moveWindowToWorkspaceSafe (Compositor.cpp) shows the house
    // pattern for capturing eFullscreenMode before a detach and restoring it
    // after re-attach. This tiny weak-referenced table is the only state this
    // plugin keeps; it holds no window alive (PHLWINDOWREF, not PHLWINDOW) so a
    // window closed while minimized is never leaked or kept artificially alive.
    struct SAuroraMinimized {
        PHLWINDOWREF    window;
        eFullscreenMode fullscreenMode = FSMODE_NONE;
    };

    std::vector<SAuroraMinimized> g_minimized;

    eFullscreenMode takeFullscreenMode(const PHLWINDOW& w) {
        eFullscreenMode mode = FSMODE_NONE;
        std::erase_if(g_minimized, [&](SAuroraMinimized& e) {
            auto locked = e.window.lock();
            if (!locked)
                return true; // prune: window closed while minimized
            if (locked == w) {
                mode = e.fullscreenMode;
                return true;
            }
            return false;
        });
        return mode;
    }

    void forgetWindow(const PHLWINDOW& w) {
        std::erase_if(g_minimized, [&](SAuroraMinimized& e) {
            auto locked = e.window.lock();
            return !locked || locked == w;
        });
    }

    void rememberWindow(const PHLWINDOW& w, eFullscreenMode mode) {
        forgetWindow(w);
        g_minimized.push_back(SAuroraMinimized{.window = w, .fullscreenMode = mode});
    }

    // Aurora: accepts the same selector language every other window action
    // already understands via CCompositor::getWindowByRegex ("address:0x...",
    // "class:...", "title:...", "active", ...); empty selector = active
    // window, matching Config::Actions::xtract()'s own default (ConfigActions.cpp).
    //
    // Compatibility fix (load-bearing, verified against the real caller): the
    // Lua-visible HL.Window.address field (LuaWindow.cpp) and hyprctl clients
    // -j's own "address" field (HyprCtl.cpp) both format as a BARE
    // "0x{:x}" hex string with no "address:" prefix, and
    // src/config/lua/bindings/LuaBindingsInternal.cpp's
    // windowFromLuaSelectorOrObject() (the resolver behind hl.get_window())
    // forwards that bare string to getWindowByRegex() unmodified. getWindowByRegex()
    // itself (Compositor.cpp) only recognizes address-mode matching behind an
    // explicit "address:" prefix; a bare "0x..." falls through to its
    // class-regex branch with an empty pattern and resolves nothing.
    // modules/home/hyprland/hyprland/keybinds.lua (already written against
    // this plugin's contract) passes exactly that bare form -- e.g.
    // `hl.plugin.auroraminimize.minimize(win.address)` -- so both forms are
    // accepted here rather than only the documented "address:0x..." one.
    PHLWINDOW resolveWindow(const std::string& raw) {
        auto sel = Hyprutils::String::trim(raw);

        if (sel.empty())
            return Desktop::focusState()->window();

        if (sel.starts_with("0x") && !sel.contains(':'))
            return g_pCompositor->getWindowByRegex("address:" + sel);

        return g_pCompositor->getWindowByRegex(sel);
    }

    SDispatchResult doMinimize(const std::string& selector) {
        auto window = resolveWindow(selector);
        if (!window)
            return {.success = false, .error = "aurora-minimize: no matching window"};

        if (window->isHidden()) // already minimized: idempotent no-op
            return {};

        const bool            WASFULLSCREEN = window->isFullscreen();
        const eFullscreenMode FSMODE         = window->m_fullscreenState.internal;

        // Aurora: clear fullscreen the same way moveWindowToWorkspaceSafe does
        // before any detach, so removeTarget()'s own defensive clear becomes a
        // no-op and we own the single, capturable state transition.
        if (WASFULLSCREEN)
            g_pCompositor->setWindowFullscreenInternal(window, FSMODE_NONE);

        rememberWindow(window, WASFULLSCREEN ? FSMODE : FSMODE_NONE);

        const bool WASFOCUSED = Desktop::focusState()->window() == window;

        window->setHidden(true);
        g_layoutManager->removeTarget(window->layoutTarget());

        // Aurora: setHidden(true) clears the compositor's focus reference when
        // the hidden window held it (Window.cpp) but does not pick a
        // replacement. Hand focus to the workspace's own next candidate
        // (CWorkspace::getFocusCandidate: last-focused -> top-left -> first,
        // all pre-filtered by acceptsInput()) so minimizing the active window
        // never leaves focus on nothing.
        if (WASFOCUSED && window->m_workspace) {
            if (auto next = window->m_workspace->getFocusCandidate(); next)
                Desktop::focusState()->fullWindowFocus(next, Desktop::FOCUS_REASON_OTHER);
        }

        g_pCompositor->updateSuspendedStates();

        return {};
    }

    SDispatchResult doRestore(const std::string& selector) {
        auto trimmed = Hyprutils::String::trim(selector);
        if (trimmed.empty())
            return {.success = false, .error = "aurora-minimize: restore requires a window address"};

        auto window = resolveWindow(trimmed);
        if (!window)
            return {.success = false, .error = "aurora-minimize: no matching window"};

        if (!window->isHidden()) {
            // Not minimized: nothing to detach/re-attach, but keep the "one
            // call restores and focuses" contract even when called redundantly.
            Desktop::focusState()->fullWindowFocus(window, Desktop::FOCUS_REASON_OTHER);
            return {};
        }

        if (!window->m_workspace)
            return {.success = false, .error = "aurora-minimize: window has no origin workspace"};

        const auto FSMODE = takeFullscreenMode(window);

        // Aurora: exact inverse of Actions::toggleSwallow()'s restore path --
        // re-attach to the SAME CSpace window->m_workspace already points at
        // (never reassigned during minimize), then unhide. Requirement "restore
        // never requires visiting another workspace" falls directly out of this:
        // there is no other workspace, m_workspace was never touched.
        g_layoutManager->newTarget(window->layoutTarget(), window->m_workspace->m_space);
        window->setHidden(false);

        if (FSMODE != FSMODE_NONE)
            g_pCompositor->setWindowFullscreenInternal(window, FSMODE);

        // Aurora: one-call restore + focus.
        Desktop::focusState()->fullWindowFocus(window, Desktop::FOCUS_REASON_OTHER);

        g_pCompositor->updateSuspendedStates();

        return {};
    }

    // ---- Lua: hl.plugin.auroraminimize.minimize(addr?) / .restore(addr) ----
    //
    // Registered via HyprlandAPI::addLuaFunction, so these are ordinary
    // synchronous Lua callables -- not "hl.dsp.*" dispatcher-factory objects --
    // matching exactly how modules/home/hyprland/hyprland/keybinds.lua already
    // calls them (`hl.plugin.auroraminimize.minimize(addr)`, direct call, no
    // hl.dispatch() wrapping). Deliberately fail silently on a runtime
    // resolution miss (never raise a Lua config error here): keybinds.lua's
    // own minimize_window()/restore_window() wrappers are written to degrade
    // to a no-op rather than propagate a hard error that would abort whatever
    // keybind closure called them (its own comment: "a hard Lua error...
    // would break every other bind in this file").

    int luaMinimize(lua_State* L) {
        std::string sel;
        if (lua_gettop(L) >= 1 && lua_isstring(L, 1))
            sel = lua_tostring(L, 1);

        doMinimize(sel);
        return 0;
    }

    int luaRestore(lua_State* L) {
        std::string sel;
        if (lua_gettop(L) >= 1 && lua_isstring(L, 1))
            sel = lua_tostring(L, 1);

        doRestore(sel);
        return 0;
    }

    // ---- addDispatcherV2: "aurora:minimize" / "aurora:restore" --------------
    //
    // Registered under the exact contracted dispatcher names. IMPORTANT,
    // verified against source rather than assumed: on Aurora's native-Lua
    // Hyprland config (Config::mgr()->type() == Config::CONFIG_LUA), these are
    // NOT reachable via `hyprctl dispatch aurora:minimize <args>` -- HyprCtl.cpp's
    // dispatchRequest() unconditionally rewrites every "dispatch" request into
    // an `hl.dispatch(<args>)` Lua eval when the config is Lua-typed, and
    // hl.dispatch() (LuaBindingsToplevel.cpp/LuaBindingsDispatcherUtils.cpp)
    // requires its argument to already be a Lua function or "Dispatcher"
    // userdata, never a bare dispatcher-name string. They are also not
    // reachable from a Lua keybind: hl.bind() (LuaBindingsToplevel.cpp)
    // always stores the keybind as an internal "__lua" callback reference,
    // never the classic dispatcher-name+arg form these entries live under
    // (g_pKeybindManager->m_dispatchers). They are registered anyway because
    // the binding contract names this exact mechanism and other in-flight
    // work may reference it, and because it costs nothing -- but the working
    // "shell drives it over IPC without writing Lua" surface is the pair of
    // raw hyprctl commands registered further down under the identical names.

    SDispatchResult dispMinimize(std::string arg) {
        return doMinimize(arg);
    }

    SDispatchResult dispRestore(std::string arg) {
        return doRestore(arg);
    }

    // ---- registerHyprCtlCommand: `hyprctl aurora:minimize [selector]` -------
    // ---- and `hyprctl aurora:restore <selector>` ----------------------------
    //
    // A brand new top-level hyprctl command, matched by CHyprCtl::getReply()
    // against its own name before "dispatch" is ever considered -- entirely
    // unaffected by Config::mgr()->type(), and so the genuine non-Lua IPC path
    // for an external process (e.g. the QuickShell rail) that cannot embed
    // Lua source in its call.

    std::string stripCommandName(const std::string& request, const std::string& name) {
        std::string rest = request.size() > name.size() ? request.substr(name.size()) : std::string();
        return Hyprutils::String::trim(rest);
    }

    std::string ctlMinimize(eHyprCtlOutputFormat, std::string request) {
        auto res = doMinimize(stripCommandName(request, "aurora:minimize"));
        return res.success ? "ok" : res.error;
    }

    std::string ctlRestore(eHyprCtlOutputFormat, std::string request) {
        auto res = doRestore(stripCommandName(request, "aurora:restore"));
        return res.success ? "ok" : res.error;
    }

    SP<SHyprCtlCommand> g_ctlMinimizeHandle;
    SP<SHyprCtlCommand> g_ctlRestoreHandle;

} // namespace

// Do NOT change this function.
APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    PHANDLE = handle;

    const std::string HASH        = __hyprland_api_get_hash();
    const std::string CLIENT_HASH = __hyprland_api_get_client_hash();

    if (HASH != CLIENT_HASH) {
        HyprlandAPI::addNotification(PHANDLE, "[aurora-minimize] Failure in initialization: Version mismatch (headers ver is not equal to running hyprland ver)",
                                      CHyprColor{1.0, 0.2, 0.2, 1.0}, 5000);
        throw std::runtime_error("[aurora-minimize] Version mismatch");
    }

    HyprlandAPI::addDispatcherV2(PHANDLE, "aurora:minimize", dispMinimize);
    HyprlandAPI::addDispatcherV2(PHANDLE, "aurora:restore", dispRestore);

    HyprlandAPI::addLuaFunction(PHANDLE, "auroraminimize", "minimize", ::luaMinimize);
    HyprlandAPI::addLuaFunction(PHANDLE, "auroraminimize", "restore", ::luaRestore);

    g_ctlMinimizeHandle = HyprlandAPI::registerHyprCtlCommand(PHANDLE, SHyprCtlCommand{.name = "aurora:minimize", .exact = false, .fn = ctlMinimize});
    g_ctlRestoreHandle  = HyprlandAPI::registerHyprCtlCommand(PHANDLE, SHyprCtlCommand{.name = "aurora:restore", .exact = false, .fn = ctlRestore});

    return {"aurora-minimize", "Same-workspace minimize/restore for Aurora (generalizes Hyprland's own toggleSwallow mechanism).", "Aurora", "0.1"};
}

APICALL EXPORT void PLUGIN_EXIT() {
    if (g_ctlMinimizeHandle)
        HyprlandAPI::unregisterHyprCtlCommand(PHANDLE, g_ctlMinimizeHandle);
    if (g_ctlRestoreHandle)
        HyprlandAPI::unregisterHyprCtlCommand(PHANDLE, g_ctlRestoreHandle);

    HyprlandAPI::removeDispatcher(PHANDLE, "aurora:minimize");
    HyprlandAPI::removeDispatcher(PHANDLE, "aurora:restore");

    HyprlandAPI::removeLuaFunction(PHANDLE, "auroraminimize", "minimize");
    HyprlandAPI::removeLuaFunction(PHANDLE, "auroraminimize", "restore");

    g_minimized.clear();
}
