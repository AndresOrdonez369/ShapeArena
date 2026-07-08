-- =============================================================================
-- entity.lua  —  COMPOSICIÓN: "tiene-un" en vez de "es-un".
-- =============================================================================
-- Una figura (Circle/Rectangle/Triangle) solo sabe de GEOMETRÍA: su forma. No
-- sabe dónde está ni hacia dónde se mueve. Una Entity ARMA un objeto de juego
-- juntando piezas:
--
--        Entity  =  Transform  +  Shape  +  Color  +  Estado
--                   (posición/    (forma)   (visual)  (hover/flash)
--                    velocidad)
--
-- Esto es COMPOSICIÓN. En vez de heredar todo de una súper-clase gigante, un
-- objeto se CONSTRUYE juntando responsabilidades pequeñas. Es exactamente la
-- idea detrás de los "componentes" de Unity/Godot y de los motores ECS.
--
-- Ventaja enorme: para tener un "enemigo triángulo" no creamos una clase nueva;
-- reusamos Entity y le metemos un Triangle. La forma es intercambiable.
-- =============================================================================

local Class   = require("class")
local collide = require("collide")

local Entity = Class()

-- Recibe la posición, la FIGURA ya construida y un color {r,g,b}.
function Entity:init(x, y, shape, color)
    -- ── Transform (el "dónde") ──────────────────────────────────────────────
    self.x, self.y   = x, y
    self.vx, self.vy = 0, 0
    -- ── Shape (el "qué forma") — inyectada desde afuera ─────────────────────
    self.shape = shape
    -- ── Visual + estado ─────────────────────────────────────────────────────
    self.color   = color or { 0.4, 0.7, 1.0 }
    self.hovered = false
    self._flash  = 0          -- 0..1: brillo temporal al chocar
end

-- Le damos una velocidad inicial (píxeles por segundo).
function Entity:setVelocity(vx, vy)
    self.vx, self.vy = vx, vy
    return self          -- devolvemos self para poder encadenar llamadas
end

-- Mueve la entidad y la hace rebotar contra los bordes de la arena (W×H).
function Entity:update(dt, W, H)
    self.x = self.x + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Rebote con paredes usando el RADIO ENVOLVENTE de la figura.
    -- Aquí NO preguntamos "¿eres círculo o triángulo?": le pedimos su radio y
    -- ya. Eso es polimorfismo: cada figura sabe responder boundingRadius().
    local r = self.shape:boundingRadius()
    if self.x - r < 0 then self.x = r;      self.vx =  math.abs(self.vx) end
    if self.x + r > W then self.x = W - r;   self.vx = -math.abs(self.vx) end
    if self.y - r < 0 then self.y = r;       self.vy =  math.abs(self.vy) end
    if self.y + r > H then self.y = H - r;   self.vy = -math.abs(self.vy) end

    -- El "flash" del choque se apaga solo con el tiempo.
    if self._flash > 0 then
        self._flash = math.max(0, self._flash - dt * 2.5)
    end
end

-- ¿Este punto cae sobre la entidad? Delegamos en la figura (composición: el
-- objeto reenvía la pregunta a la pieza que sabe responderla).
function Entity:contains(px, py)
    return self.shape:contains(self.x, self.y, px, py)
end

-- BROAD PHASE: ¿los círculos envolventes de dos entidades se tocan?
function Entity:overlaps(other)
    return collide.circleVsCircle(
        self.x,  self.y,  self.shape:boundingRadius(),
        other.x, other.y, other.shape:boundingRadius()
    )
end

-- Marca un destello (se llama cuando la entidad choca con otra).
function Entity:flash()
    self._flash = 1
end

function Entity:draw()
    local c, f = self.color, self._flash
    -- Mezclamos el color base hacia el blanco según el destello (0 = normal).
    love.graphics.setColor(
        c[1] + (1 - c[1]) * f,
        c[2] + (1 - c[2]) * f,
        c[3] + (1 - c[3]) * f,
        1
    )

    -- ★ LA LÍNEA MÁGICA ★  No sabemos ni nos importa qué figura es: le decimos
    -- "dibújate en (x,y)" y cada tipo lo hace a su manera. POLIMORFISMO puro.
    self.shape:draw(self.x, self.y)

    -- Si el mouse está encima, resaltamos con un anillo blanco.
    if self.hovered then
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", self.x, self.y, self.shape:boundingRadius() + 5)
        love.graphics.setLineWidth(1)
    end
end

return Entity
