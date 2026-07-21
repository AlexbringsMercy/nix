hl.on("hyprland.start", function()
    -- Keep the user-service lifecycle tied to this compositor session. The
    -- ordered command prevents graphical services from racing the Wayland and
    -- desktop environment import.
    local session_environment = "WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE"
    hl.exec_cmd("dbus-update-activation-environment --systemd " .. session_environment
        .. " && systemctl --user import-environment " .. session_environment
        .. " && systemctl --user start hyprland-session.target")

    -- Aurora: nm-applet + blueman-applet retired at the Stage 1 gate — the shell
    -- owns network/bluetooth status+popouts natively (bar/components/StatusIcons.qml),
    -- so these legacy tray applets were duplicate wifi/bt icons and drove a stuck
    -- "connecting" spinner. Nmcli/BlueZ daemons are unaffected.
    hl.exec_cmd("hyprctl setcursor Adwaita 24")

    -- Build-period only (removed at Stage 10 with build-harness.nix): a
    -- planned reboot arms a flag; this relaunches the build agent once.
    hl.exec_cmd("aurora-resume-agent")
end)

hl.on("hyprland.shutdown", function()
    -- Raw start-hyprland does not manage graphical-session.target for us.
    -- Stopping it here gives every PartOf= service a clean logout boundary.
    hl.exec_cmd("systemctl --user stop hyprland-session.target")
end)
