-- Curves adapted from end-4's expressive motion language, shortened slightly
-- for the low-power dual-core Air while retaining coordinated movement/fades.
hl.curve("auroraSpatial", {
    type = "bezier",
    points = {{0.38, 1.21}, {0.22, 1.00}}
})
hl.curve("auroraDecel", {
    type = "bezier",
    points = {{0.05, 0.72}, {0.10, 1.00}}
})
hl.curve("auroraAccel", {
    type = "bezier",
    points = {{0.30, 0.00}, {0.80, 0.15}}
})
hl.curve("auroraMenu", {
    type = "bezier",
    points = {{0.10, 1.00}, {0.00, 1.00}}
})
hl.curve("auroraLinear", {
    type = "bezier",
    points = {{0.00, 0.00}, {1.00, 1.00}}
})

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "auroraDecel", style = "popin 88%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3.8, bezier = "auroraDecel" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3.1, bezier = "auroraAccel", style = "popin 94%" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.8, bezier = "auroraAccel" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.5, bezier = "auroraSpatial", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 6.5, bezier = "auroraDecel" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 18, bezier = "auroraLinear", loop = true })

hl.animation({ leaf = "layersIn", enabled = true, speed = 4.0, bezier = "auroraDecel", style = "popin 96%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3.0, bezier = "auroraAccel", style = "popin 97%" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 3.5, bezier = "auroraMenu" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.8, bezier = "auroraAccel" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 5.2, bezier = "auroraSpatial", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn", enabled = true, speed = 4.0, bezier = "auroraDecel", style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3.0, bezier = "auroraAccel", style = "slidevert" })
