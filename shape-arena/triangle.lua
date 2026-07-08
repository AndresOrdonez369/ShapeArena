-- =============================================================================
-- triangle.lua  —  Triangle HEREDA de Shape (nuestro primer POLÍGONO).
-- =============================================================================
-- Un triángulo equilátero que "apunta hacia arriba", definido por un tamaño
-- `size` (la distancia del centro a cada vértice). Guardamos los 3 vértices en
-- coordenadas LOCALES (relativas a su centro); al dibujar/testear los movemos
-- al mundo sumándoles (x, y).
--
-- Es el caso interesante: dibujar y "¿contiene el punto?" ya NO son una fórmula
-- de una línea. Aun así, desde afuera se usa EXACTAMENTE igual que un círculo o
-- un rectángulo. Eso es el poder del polimorfismo.
-- =============================================================================

local Class   = require("class")
local Shape   = require("shape")
local collide = require("collide")

local Triangle = Class(Shape)   -- HERENCIA

function Triangle:init(size)
    Shape.init(self, "triangulo")
    self:setSize(size or 26)
end

function Triangle:setSize(size)
    assert(size > 0, "El tamano debe ser > 0")
    self._size = size
    -- Vértices locales (centro en 0,0). En LÖVE la Y crece hacia ABAJO,
    -- así que "arriba" es Y negativa.
    local s = size
    local h = s * math.sqrt(3) / 2        -- media base
    self._verts = {
        {  0, -s   },                     -- vértice superior
        { -h,  s/2 },                     -- inferior izquierdo
        {  h,  s/2 },                     -- inferior derecho
    }
end

function Triangle:getSize() return self._size end

-- Ayuda: entrega los 3 vértices ya trasladados a (x, y) como lista plana
-- {x1,y1, x2,y2, x3,y3}, que es justo lo que love.graphics.polygon espera.
function Triangle:worldVertices(x, y)
    local v = self._verts
    return {
        x + v[1][1], y + v[1][2],
        x + v[2][1], y + v[2][2],
        x + v[3][1], y + v[3][2],
    }
end

-- ── Polimorfismo ─────────────────────────────────────────────────────────────

function Triangle:draw(x, y)
    local pts = self:worldVertices(x, y)
    love.graphics.polygon("fill", pts)
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.polygon("line", pts)
end

--- Punto dentro de un triángulo: pasamos los 3 vértices del mundo a la caja de
--- herramientas, que aplica el "test del signo" (ver collide.pointInTriangle).
function Triangle:contains(x, y, px, py)
    local p = self:worldVertices(x, y)
    return collide.pointInTriangle(px, py, p[1], p[2], p[3], p[4], p[5], p[6])
end

--- El vértice más lejano está a distancia `size` del centro, así que ese es
--- el radio del círculo que lo envuelve.
function Triangle:boundingRadius()
    return self._size
end

return Triangle
