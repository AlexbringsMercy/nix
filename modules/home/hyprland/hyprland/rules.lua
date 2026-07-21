-- Aurora: keep five persistent workspaces on the internal display for the Stage 2A model.
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "eDP-1", persistent = true }) -- Aurora: add workspace 3.
hl.workspace_rule({ workspace = "4", monitor = "eDP-1", persistent = true }) -- Aurora: add workspace 4.
hl.workspace_rule({ workspace = "5", monitor = "eDP-1", persistent = true }) -- Aurora: add workspace 5.

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
    decorate = false, -- Aurora: suppress hyprbars on compact Picture-in-Picture windows.
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    size = {"(monitor_w*0.29)", "(monitor_h*0.29)"},
    move = {"(monitor_w*0.69)", "(monitor_h*0.66)"}
})

for name, class in pairs({ -- Aurora: suppress server titlebars where the shell or a CSD app already owns chrome.
    ["no-bar-aurora-shell"] = "^(org\\.quickshell|quickshell|caelestia|aurora-shell)(.*)$", -- Aurora: cover shell-owned floating windows; layer namespaces are not client windows.
    ["no-bar-gnome-csd"] = "^(org\\.gnome\\..*|org\\.gtk\\..*|io\\.missioncenter\\.MissionCenter|com\\.github\\.wwmm\\.easyeffects)$" -- Aurora: avoid double bars on the installed GNOME/libadwaita CSD family.
}) do -- Aurora: share the native-Lua decoration suppression rule shape.
    hl.window_rule({ -- Aurora: emit one named rule per no-bar client family.
        name = name, -- Aurora: keep runtime rule inspection legible.
        match = { class = class }, -- Aurora: match application IDs/classes rather than layer namespaces.
        decorate = false -- Aurora: native-Lua equivalent of the plugin's legacy hyprbars:no_bar property.
    }) -- Aurora: close the no-bar window rule.
end -- Aurora: finish shell and CSD no-bar rules.

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
