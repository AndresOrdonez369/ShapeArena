-- =============================================================================
-- collide.lua  —  La "caja de herramientas" de COLISIONES (pura matemática).
-- =============================================================================
-- Un módulo con SOLO funciones, sin estado. Reunir aquí la matemática de choques
-- es un buen hábito de diseño (una sola responsabilidad): las figuras y el juego
-- la usan, pero nadie repite fórmulas.
--
-- Se organiza en dos familias:
--   1) PUNTO vs FIGURA  -> las usa cada figura en su :contains() (picking, clicks)
--   2) FIGURA vs FIGURA -> las usa el juego para detectar y resolver choques
--
-- Idea clave para videojuegos: BROAD PHASE vs NARROW PHASE.
--   • Broad phase  = descarte rápido y aproximado (círculos envolventes).
--   • Narrow phase = prueba exacta, más cara (AABB exacto, círculo-rect, SAT...).
-- Primero el descarte barato; solo si "quizá chocan", la prueba fina.
-- =============================================================================

local collide = {}

-- ── 1) PUNTO vs FIGURA ───────────────────────────────────────────────────────

--- ¿El punto (px,py) está dentro del círculo de centro (cx,cy) y radio r?
--- Comparamos distancia² con radio² para evitar la raíz cuadrada (más rápido).
function collide.pointInCircle(px, py, cx, cy, r)
    local dx, dy = px - cx, py - cy
    return dx * dx + dy * dy <= r * r
end

--- ¿El punto está dentro del rectángulo CENTRADO en (cx,cy) de tamaño w×h?
function collide.pointInRect(px, py, cx, cy, w, h)
    local hw, hh = w / 2, h / 2
    return px >= cx - hw and px <= cx + hw
       and py >= cy - hh and py <= cy + hh
end

--- ¿El punto está dentro del triángulo de vértices A, B, C?
--- "Test del signo": miramos de qué lado del punto queda cada arista (producto
--- cruz). Si el punto está del mismo lado de las 3, está dentro.
function collide.pointInTriangle(px, py, ax, ay, bx, by, cx, cy)
    local function lado(x1, y1, x2, y2)
        return (x2 - x1) * (py - y1) - (y2 - y1) * (px - x1)
    end
    local d1 = lado(ax, ay, bx, by)
    local d2 = lado(bx, by, cx, cy)
    local d3 = lado(cx, cy, ax, ay)
    local neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
    local pos = (d1 > 0) or (d2 > 0) or (d3 > 0)
    return not (neg and pos)   -- dentro = no hay mezcla de signos
end

-- ── 2) FIGURA vs FIGURA ──────────────────────────────────────────────────────

--- Círculo contra círculo. Chocan si la distancia entre centros es menor que la
--- SUMA de sus radios. (Es la prueba que ya usaba coin-hunt, y la base del
--- broad-phase: todo objeto tiene un "círculo envolvente".)
function collide.circleVsCircle(x1, y1, r1, x2, y2, r2)
    local dx, dy = x2 - x1, y2 - y1
    local rs = r1 + r2
    return dx * dx + dy * dy <= rs * rs
end

--- AABB vs AABB (rectángulos centrados, sin rotar). Chocan si se solapan a la
--- vez en el eje X y en el eje Y.
function collide.aabbVsAabb(x1, y1, w1, h1, x2, y2, w2, h2)
    return math.abs(x1 - x2) <= (w1 + w2) / 2
       and math.abs(y1 - y2) <= (h1 + h2) / 2
end

--- Círculo vs rectángulo centrado: buscamos el PUNTO del rectángulo más cercano
--- al centro del círculo (recortando/"clamp" las coordenadas al borde) y vemos
--- si ese punto cae dentro del círculo.
function collide.circleVsRect(cx, cy, r, rx, ry, rw, rh)
    local hw, hh = rw / 2, rh / 2
    local nx = math.max(rx - hw, math.min(cx, rx + hw))  -- clamp en X
    local ny = math.max(ry - hh, math.min(cy, ry + hh))  -- clamp en Y
    local dx, dy = cx - nx, cy - ny
    return dx * dx + dy * dy <= r * r
end

return collide
