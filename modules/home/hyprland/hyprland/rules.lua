-- Exactly two persistent workspaces on the internal display.
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1", persistent = true })

-- Browsers remain first-class tiled clients.  Dialogs and utilities float.
hl.window_rule({
    name = "tile-chrome",
    match = { class = "^(google-chrome|google-chrome-stable|Google-chrome|chromium-browser)$" },
    tile = true
})

hl.window_rule({
    name = "float-file-dialogs",
    match = { title = "^(Open File|Select a File|Open Folder|Save As|File Upload)(.*)$" },
    float = true,
    center = true,
    size = {"(monitor_w*0.68)", "(monitor_h*0.70)"}
})

for _, class in ipairs({
    "^(nm-connection-editor)$",
    "^(blueman-manager)$",
    "^(com.github.wwmm.easyeffects)$",
    "^(org.pulseaudio.pavucontrol)$",
    "^(pwvucontrol)$"
}) do
    hl.window_rule({
        match = { class = class },
        float = true,
        center = true,
        size = {"(monitor_w*0.72)", "(monitor_h*0.72)"}
    })
end

hl.window_rule({
    name = "picture-in-picture",
    match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    size = {"(monitor_w*0.29)", "(monitor_h*0.29)"},
    move = {"(monitor_w*0.69)", "(monitor_h*0.66)"}
})

-- Frost the translucent GTK/QML surfaces, without forcing blur on opaque app
-- windows.  QuickShell panels keep independent placement and animation state.
for _, namespace in ipairs({
    "waybar",
    "rofi",
    "launcher",
    "swayosd",
    "osd",
    "notifications",
    "quickshell:.*",
    "aurora-.*"
}) do
    hl.layer_rule({ match = { namespace = namespace }, blur = true })
    hl.layer_rule({ match = { namespace = namespace }, blur_popups = true })
    hl.layer_rule({ match = { namespace = namespace }, ignore_alpha = 0.50 })
end

hl.layer_rule({ match = { namespace = "waybar" }, animation = "slide top" })
hl.layer_rule({ match = { namespace = "quickshell:notification.*" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "quickshell:.*left.*" }, animation = "slide left" })
hl.layer_rule({ match = { namespace = "quickshell:.*right.*" }, animation = "slide right" })
