-- =============================================================================
-- shape.lua  —  La CLASE BASE (aquí vive la ABSTRACCIÓN).
-- =============================================================================
-- Una "figura" no es un círculo ni un rectángulo en concreto: es la IDEA de que
-- toda figura sabe hacer ciertas cosas. Eso es ABSTRACCIÓN: hablamos del "qué"
-- (una figura se dibuja, se puede preguntar si contiene un punto...) sin decir
-- todavía el "cómo".
--
-- A la lista de métodos que TODA figura debe implementar la llamamos su CONTRATO
-- (o "interfaz"). Aquí lo declaramos y, si una subclase se olvida de cumplirlo,
-- reventamos con un error claro en vez de fallar en silencio.
-- =============================================================================

local Class = require("class")

local Shape = Class()   -- Shape es la raíz de nuestra jerarquía de figuras

-- ── Constructor base: guarda lo COMÚN a todas las figuras ────────────────────
-- Las subclases llamarán a  Shape.init(self, "circulo")  para reusar esto.
function Shape:init(kind)
    self.kind = kind or "figura"
end

-- ── EL CONTRATO (métodos "abstractos") ───────────────────────────────────────
-- Lua no tiene "métodos abstractos" de verdad, así que los simulamos: si alguien
-- llama a estos sin haberlos sobreescrito, lanzamos un error explicativo.

--- Dibuja la figura centrada en (x, y). DEBE implementarse en cada subclase.
function Shape:draw(x, y)
    error(("draw() no implementado en la figura '%s'"):format(self.kind))
end

--- ¿El punto (px, py) cae DENTRO de la figura centrada en (x, y)?
--- Se usa para "picking" con el mouse. DEBE implementarse en cada subclase.
function Shape:contains(x, y, px, py)
    error(("contains() no implementado en la figura '%s'"):format(self.kind))
end

--- Radio del círculo más pequeño que envuelve a la figura (para broad-phase).
--- DEBE implementarse en cada subclase.
function Shape:boundingRadius()
    error(("boundingRadius() no implementado en la figura '%s'"):format(self.kind))
end

-- ── Métodos COMPARTIDOS (se heredan tal cual; no hace falta reescribirlos) ────

--- Texto descriptivo. Todas las figuras lo heredan gratis.
function Shape:describe()
    return ("Figura tipo '%s' (r≈%.0f)"):format(self.kind, self:boundingRadius())
end

return Shape
