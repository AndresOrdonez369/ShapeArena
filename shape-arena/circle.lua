-- =============================================================================
-- circle.lua  —  Circle HEREDA de Shape.
-- =============================================================================
-- Aquí se ven 3 pilares a la vez:
--   HERENCIA        -> Class(Shape): Circle recibe gratis lo de Shape (describe...)
--   POLIMORFISMO    -> reimplementa draw/contains/boundingRadius a SU manera.
--   ENCAPSULAMIENTO -> el radio vive en self._r; se toca con getRadius/setRadius,
--                      que protegen la INVARIANTE "el radio siempre es > 0".
-- =============================================================================

local Class   = require("class")
local Shape   = require("shape")
local collide = require("collide")   -- reusamos la matemática, no la copiamos

local Circle = Class(Shape)   -- <<< HERENCIA: Circle es-un Shape

-- Constructor. Nota cómo REUSAMOS el constructor del padre.
function Circle:init(r)
    Shape.init(self, "circulo")        -- llama al init del PADRE (pone self.kind)
    self:setRadius(r or 20)            -- usamos el setter para validar de una vez
end

-- ── Encapsulamiento: acceso controlado al radio ──────────────────────────────
function Circle:getRadius()
    return self._r
end

function Circle:setRadius(r)
    assert(type(r) == "number" and r > 0, "El radio debe ser un numero > 0")
    self._r = r                        -- '_' = convención de "no me toques directo"
end

-- ── Polimorfismo: la MISMA firma que Shape, pero comportamiento de círculo ────

function Circle:draw(x, y)
    love.graphics.circle("fill", x, y, self._r)
    love.graphics.setColor(0, 0, 0, 0.25)          -- un borde sutil
    love.graphics.circle("line", x, y, self._r)
end

--- ¿El punto está dentro? Delegamos en la caja de herramientas: un punto está
--- dentro del círculo si su distancia al centro es menor que el radio.
function Circle:contains(x, y, px, py)
    return collide.pointInCircle(px, py, x, y, self._r)
end

function Circle:boundingRadius()
    return self._r
end

return Circle
