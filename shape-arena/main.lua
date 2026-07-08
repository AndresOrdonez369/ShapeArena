-- =============================================================================
-- main.lua  —  SHAPE ARENA
-- =============================================================================
-- Una arena donde conviven círculos, rectángulos y triángulos. Todos son
-- "Entities" que se mueven, rebotan contra las paredes y CHOCAN entre sí. El
-- mouse puede "tocar" cualquier figura (picking) y hasta borrarla.
--
-- Fíjate en el patrón: main.lua NO conoce los detalles de cada figura. Solo
-- trabaja con Entities a través de un puñado de métodos comunes
-- (update / draw / contains / overlaps). Agregar una figura nueva NO obliga a
-- tocar este archivo. Eso es diseño orientado a objetos bien hecho.
--
--   love.load()   -> se llama UNA vez al arrancar (preparar el mundo)
--   love.update() -> se llama CADA frame (mover, chocar, pensar)
--   love.draw()   -> se llama CADA frame (solo pintar)
-- =============================================================================

local Circle    = require("circle")
local Rectangle = require("rectangle")
local Triangle  = require("triangle")
local Entity    = require("entity")

-- Estado global del juego (a nivel de este archivo).
local W, H              -- tamaño de la arena
local world            -- lista de todas las entidades
local paused           = false
local showBounds       = false   -- ¿mostrar los círculos envolventes? (broad phase)
local showHelp         = true
local collisionCount   = 0
local fontBig, fontSmall

-- Una paleta de colores agradables para las figuras.
local PALETTE = {
    { 0.95, 0.35, 0.42 },  -- rojo coral
    { 0.98, 0.75, 0.20 },  -- ámbar
    { 0.35, 0.85, 0.55 },  -- verde menta
    { 0.35, 0.70, 0.98 },  -- azul cielo
    { 0.75, 0.55, 0.98 },  -- lila
    { 0.98, 0.55, 0.80 },  -- rosa
}

-- ── Fábrica de entidades ─────────────────────────────────────────────────────
-- Crea una figura del tipo pedido y la envuelve en una Entity con posición,
-- color y velocidad al azar. Es el único lugar que decide "qué figura construir".
local function nuevaEntidad(kind, x, y)
    local shape
    if     kind == "circle"    then shape = Circle(love.math.random(14, 30))
    elseif kind == "rectangle" then shape = Rectangle(love.math.random(30, 70),
                                                      love.math.random(24, 50))
    else                            shape = Triangle(love.math.random(18, 34))
    end

    local color = PALETTE[love.math.random(#PALETTE)]
    local e = Entity(x, y, shape, color)

    -- Velocidad inicial en una dirección al azar.
    local ang   = love.math.random() * 2 * math.pi
    local speed = love.math.random(80, 190)
    e:setVelocity(math.cos(ang) * speed, math.sin(ang) * speed)
    return e
end

-- Suelta una figura en (x, y), respetando un tope para no saturar.
local function spawn(kind, x, y)
    if #world >= 80 then return end
    table.insert(world, nuevaEntidad(kind, x, y))
end

-- ── Respuesta al choque (rebote elástico simple, masas iguales) ──────────────
-- Separa dos entidades que se solapan e intercambia la parte de su velocidad
-- que va a lo largo de la línea que las une.
local function resolver(a, b)
    local dx, dy = b.x - a.x, b.y - a.y
    local dist   = math.sqrt(dx * dx + dy * dy)
    if dist == 0 then dx, dy, dist = 1, 0, 1 end   -- evita dividir por cero

    local ra, rb  = a.shape:boundingRadius(), b.shape:boundingRadius()
    local overlap = (ra + rb) - dist
    if overlap <= 0 then return end                -- ya no se tocan

    local nx, ny = dx / dist, dy / dist            -- normal unitaria a -> b

    -- 1) Separarlas (mitad para cada una) para que dejen de encimarse.
    a.x, a.y = a.x - nx * overlap / 2, a.y - ny * overlap / 2
    b.x, b.y = b.x + nx * overlap / 2, b.y + ny * overlap / 2

    -- 2) Rebote: solo si se están ACERCANDO (para no "pegarlas").
    local va   = a.vx * nx + a.vy * ny             -- velocidad de a sobre la normal
    local vb   = b.vx * nx + b.vy * ny             -- velocidad de b sobre la normal
    local diff = vb - va
    if diff < 0 then                               -- acercándose
        a.vx, a.vy = a.vx + diff * nx, a.vy + diff * ny
        b.vx, b.vy = b.vx - diff * nx, b.vy - diff * ny
    end
end

-- =============================================================================
-- CALLBACKS DE LÖVE
-- =============================================================================

function love.load()
    W, H = love.graphics.getDimensions()
    love.graphics.setBackgroundColor(0.09, 0.11, 0.17)
    fontBig   = love.graphics.newFont(18)
    fontSmall = love.graphics.newFont(14)

    world = {}
    local tipos = { "circle", "rectangle", "triangle" }
    for _ = 1, 9 do            -- unas cuantas figuras para arrancar
        local x = love.math.random(60, W - 60)
        local y = love.math.random(60, H - 60)
        spawn(tipos[love.math.random(3)], x, y)
    end
end

function love.update(dt)
    if not paused then
        -- 1) Mover cada entidad (y rebotar en las paredes).
        for _, e in ipairs(world) do
            e:update(dt, W, H)
        end

        -- 2) Chocar cada par UNA sola vez (i con j>i).
        for i = 1, #world do
            for j = i + 1, #world do
                local a, b = world[i], world[j]
                if a:overlaps(b) then            -- broad phase (círculos envolventes)
                    a:flash(); b:flash()
                    resolver(a, b)
                    collisionCount = collisionCount + 1
                end
            end
        end
    end

    -- 3) Picking: marcar la figura que está bajo el mouse (la de más arriba).
    local mx, my = love.mouse.getPosition()
    for _, e in ipairs(world) do e.hovered = false end
    for i = #world, 1, -1 do                     -- de la última (encima) a la primera
        if world[i]:contains(mx, my) then
            world[i].hovered = true
            break
        end
    end
end

function love.draw()
    -- Círculos envolventes (si están activados): así se VE el broad phase.
    if showBounds then
        love.graphics.setColor(1, 1, 1, 0.15)
        love.graphics.setLineWidth(1)
        for _, e in ipairs(world) do
            love.graphics.circle("line", e.x, e.y, e.shape:boundingRadius())
        end
    end

    -- Todas las figuras, con el MISMO código para cualquier tipo (polimorfismo).
    for _, e in ipairs(world) do
        e:draw()
    end

    drawHUD()
end

-- ── Interfaz (texto informativo) ─────────────────────────────────────────────
function drawHUD()
    -- Panel superior con estadísticas.
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", 0, 0, W, 34)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(fontBig)
    love.graphics.print(("SHAPE ARENA   |   figuras: %d   |   choques: %d   |   %s")
        :format(#world, collisionCount, paused and "PAUSA" or "corriendo"), 12, 7)
    love.graphics.setFont(fontSmall)
    love.graphics.printf(("FPS %d"):format(love.timer.getFPS()), W - 90, 9, 80, "right")

    if not showHelp then return end

    -- Panel de ayuda (abajo a la izquierda).
    local lines = {
        "1 / 2 / 3  ->  crear circulo / rectangulo / triangulo (en el mouse)",
        "Click izq  ->  borrar la figura bajo el cursor   |   Click der -> figura al azar",
        "G  ->  ver circulos envolventes (broad phase)    |   Espacio -> pausa",
        "C  ->  limpiar    |    H -> ocultar/mostrar esta ayuda    |    Esc -> salir",
    }
    local h = #lines * 18 + 16
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", 0, H - h, 560, h)
    love.graphics.setColor(1, 1, 1, 0.92)
    love.graphics.setFont(fontSmall)
    for i, t in ipairs(lines) do
        love.graphics.print(t, 12, H - h + 8 + (i - 1) * 18)
    end
end

-- ── Entradas del usuario ─────────────────────────────────────────────────────
function love.keypressed(key)
    local mx, my = love.mouse.getPosition()
    if     key == "1"      then spawn("circle",    mx, my)
    elseif key == "2"      then spawn("rectangle", mx, my)
    elseif key == "3"      then spawn("triangle",  mx, my)
    elseif key == "space"  then paused     = not paused
    elseif key == "g"      then showBounds = not showBounds
    elseif key == "h"      then showHelp   = not showHelp
    elseif key == "c"      then world = {}; collisionCount = 0
    elseif key == "escape" then love.event.quit()
    end
end

function love.mousepressed(mx, my, button)
    if button == 1 then
        -- Borrar la figura de más arriba que contenga el clic (usa :contains).
        for i = #world, 1, -1 do
            if world[i]:contains(mx, my) then
                table.remove(world, i)
                break
            end
        end
    elseif button == 2 then
        local tipos = { "circle", "rectangle", "triangle" }
        spawn(tipos[love.math.random(3)], mx, my)
    end
end
