-- The internal Retina panel is the only display on this build.  The explicit
-- mode avoids an accidental low-DPI fallback; 1.5 gives ~1707x1067 logical px.
hl.monitor({
    output = "eDP-1",
    mode = "2560x1600@60",
    position = "0x0",
    scale = 1.5
})

hl.config({
    -- 2560x1600 at 1.5 produces fractional logical dimensions.  Without this,
    -- Hyprland 0.55 validates against a clean divisor and lays surfaces out as
    -- 1600x1000 while still rendering at 1.5, leaving right/bottom dead bands.
    debug = {
        disable_scale_checks = true
    },

    general = {
        layout = "dwindle",
        gaps_in = 5,
        gaps_out = 8,
        gaps_workspaces = 24,
        border_size = 2,
        resize_on_border = true,
        extend_border_grab_area = 12,
        hover_icon_on_border = true,
        allow_tearing = false,
        col = {
            active_border = {
                colors = {
                    "rgba(9b6dffff)",
                    "rgba(54d7ffff)",
                    "rgba(39e6c5ff)"
                },
                angle = 45
            },
            inactive_border = "rgba(34334a88)"
        },
        snap = {
            enabled = true,
            window_gap = 5,
            monitor_gap = 8,
            respect_gaps = true
        }
    },

    decoration = {
        rounding = 10,
        rounding_power = 2.2,
        active_opacity = 1.0,
        inactive_opacity = 0.96,
        fullscreen_opacity = 1.0,
        blur = {
            enabled = true,
            xray = false,
            special = true,
            new_optimizations = true,
            size = 8,
            passes = 2,
            noise = 0.018,
            contrast = 1.08,
            brightness = 0.84,
            vibrancy = 0.24,
            vibrancy_darkness = 0.38,
            popups = true,
            popups_ignorealpha = 0.62,
            input_methods = true,
            input_methods_ignorealpha = 0.75
        },
        shadow = {
            enabled = true,
            range = 20,
            offset = {0, 4},
            render_power = 3,
            color = "rgba(00000888)"
        },
        dim_inactive = true,
        dim_strength = 0.035,
        dim_special = 0.20
    },

    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        vrr = 0,
        focus_on_activate = true,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = true,
        animate_mouse_windowdragging = true,
        initial_workspace_tracking = false,
        middle_click_paste = false,
        allow_session_lock_restore = true
    },

    xwayland = {
        force_zero_scaling = true
    }
})
