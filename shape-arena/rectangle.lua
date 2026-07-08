-- =============================================================================
-- rectangle.lua  —  Rectangle HEREDA de Shape.
-- =============================================================================
-- Un rectángulo "alineado a los ejes" (AABB: Axis-Aligned Bounding Box): sus
-- lados son paralelos a X y a Y (no rota). Eso hace que dibujarlo, saber si un
-- punto está dentro y detectar choques sea MUY barato.
--
-- Guardamos el ANCHO y el ALTO; el centro (x, y) lo pone quien lo dibuja
-- (la Entity). Así el rectángulo es geometría pura y reutilizable.
-- =============================================================================

local Class   = require("class")
local Shape   = require("shape")
local collide = require("collide")

local Rectangle = Class(Shape)   -- HERENCIA

function Rectangle:init(w, h)
    Shape.init(self, "rectangulo")
    self:setSize(w or 40, h or 28)
end

-- ── Encapsulamiento con invariante (ancho y alto positivos) ──────────────────
function Rectangle:setSize(w, h)
    assert(w > 0 and h > 0, "El ancho y el alto deben ser > 0")
    self._w, self._h = w, h
end

function Rectangle:getWidth()  return self._w end
function Rectangle:getHeight() return self._h end

-- ── Polimorfismo ─────────────────────────────────────────────────────────────

function Rectangle:draw(x, y)
    -- LÖVE dibuja el rectángulo desde su esquina superior-izquierda, pero
    -- nosotros trabajamos con el CENTRO (x, y). Restamos la mitad para centrar.
    local left, top = x - self._w / 2, y - self._h / 2
    love.graphics.rectangle("fill", left, top, self._w, self._h)
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.rectangle("line", left, top, self._w, self._h)
end

--- Punto dentro de un rectángulo centrado: cae dentro si está dentro del rango
--- horizontal Y del rango vertical al mismo tiempo.
function Rectangle:contains(x, y, px, py)
    return collide.pointInRect(px, py, x, y, self._w, self._h)
end

--- El círculo que envuelve al rectángulo pasa por sus esquinas: su radio es la
--- media diagonal = raíz((w/2)² + (h/2)²).
function Rectangle:boundingRadius()
    local hw, hh = self._w / 2, self._h / 2
    return math.sqrt(hw * hw + hh * hh)
end

return Rectangle
