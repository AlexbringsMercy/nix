hl.config({
    input = {
        kb_layout = "us",
        repeat_delay = 350, -- Aurora: slow the initial repeat to the Stage 2 input target.
        repeat_rate = 22, -- Aurora: keep held-key repeat controlled rather than runaway-fast.
        follow_mouse = 0, -- Aurora: require a click so pointer travel cannot retarget window actions.
        focus_on_close = 2, -- Aurora: return focus to the most-recent window after a close.
        sensitivity = 0.05,
        accel_profile = "adaptive",
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            tap_and_drag = true,
            drag_lock = false,
            disable_while_typing = true,
            clickfinger_behavior = true,
            tap_button_map = "lrm",
            scroll_factor = 0.6 -- Aurora: 0.3 was too slow (operator) — bumped up; tune to feel.
        }
    },
    gestures = {
        workspace_swipe_distance = 520,
        workspace_swipe_cancel_ratio = 0.22,
        workspace_swipe_min_speed_to_force = 12,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = false
    }
})

-- One deliberate gesture: three-finger horizontal swipe between the two
-- persistent workspaces.  New workspaces cannot be created by overshooting.
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Aurora: 3-finger vertical live-volume removed — a lua-function gesture action
-- faulted at runtime (operator saw the error). Deferred until a verified native
-- form is found; pinch-zoom below is a standard string action and works.
hl.gesture({ -- Aurora: add the native compositor magnifier gesture.
    fingers = 2, -- Aurora: use the standard two-finger pinch without adding any four-finger Stage 5/8 action.
    direction = "pinch", -- Aurora: accept pinch-in and pinch-out.
    action = "cursor_zoom", -- Aurora: use Hyprland 0.55's native zoom action.
    zoom_level = 1, -- Aurora: make zoom track pinch scale from the normal 1x baseline.
    mode = "live" -- Aurora: keep magnification continuous during the pinch.
}) -- Aurora: finish the live cursor-zoom gesture.
