-- conf.lua — configuración de la ventana.
-- LÖVE lee este archivo ANTES de love.load().
function love.conf(t)
    t.window.title  = "Shape Arena — Figuras y Colisiones con POO"
    t.window.width  = 900
    t.window.height = 640
    t.window.msaa   = 4      -- suaviza los bordes de las figuras (antialiasing)
end
