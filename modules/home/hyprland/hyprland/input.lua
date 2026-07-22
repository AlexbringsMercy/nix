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
            scroll_factor = 0.3 -- Aurora: normalize the T2 touchpad's overly sensitive scroll.
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

local function adjust_volume(event) -- Aurora: implement Hyprland's native live-function gesture against PipeWire.
    local amount = -0.25 * event.delta.y -- Aurora: turn vertical gesture distance into small continuous percentage steps.
    if math.abs(amount) < 0.01 then return end -- Aurora: ignore begin/end events and zero-distance updates.
    local suffix = amount > 0 and "%+" or "%-" -- Aurora: express wpctl's relative direction without a signed percentage.
    local command = string.format("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ %.2f%s", math.abs(amount), suffix) -- Aurora: retain the same 100%% cap as the volume key.
    hl.dispatch(hl.dsp.exec_cmd(command)) -- Aurora: use the verified native dispatcher form for each live update.
end -- Aurora: finish the continuous volume callback.

hl.gesture({ -- Aurora: add the Stage 2 three-finger vertical live-volume gesture.
    fingers = 3, -- Aurora: preserve horizontal workspace and partition only the vertical axis.
    direction = "vertical", -- Aurora: accept either vertical direction as relative volume movement.
    action = adjust_volume -- Aurora: feed native gesture events to the continuous PipeWire callback.
}) -- Aurora: finish the live-volume gesture.

hl.gesture({ -- Aurora: add the native compositor magnifier gesture.
    fingers = 2, -- Aurora: use the standard two-finger pinch without adding any four-finger Stage 5/8 action.
    direction = "pinch", -- Aurora: accept pinch-in and pinch-out.
    action = "cursor_zoom", -- Aurora: use Hyprland 0.55's native zoom action.
    zoom_level = 1, -- Aurora: make zoom track pinch scale from the normal 1x baseline.
    mode = "live" -- Aurora: keep magnification continuous during the pinch.
}) -- Aurora: finish the live cursor-zoom gesture.
