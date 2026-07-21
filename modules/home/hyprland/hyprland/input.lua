hl.config({
    input = {
        kb_layout = "us",
        repeat_delay = 300,
        repeat_rate = 35,
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
            scroll_factor = 0.78
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
