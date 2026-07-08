-- =============================================================================
-- class.lua  —  Un mini "sistema de clases" para Lua.
-- =============================================================================
-- Lua NO tiene clases de fábrica: solo tiene TABLAS y METATABLAS.
-- Este archivo empaqueta el truco de siempre (setmetatable + __index) en una
-- sola función `Class(padre)` para que el resto del proyecto se lea limpio.
--
-- ¿Qué resuelve cada pieza?
--   __index  -> "si no encuentras el método en la instancia, búscalo en la clase"
--   __index  (de la clase) -> "si no está en la clase, búscalo en el PADRE"  == HERENCIA
--   __call   -> nos deja escribir  Circle(10)  en vez de  Circle.new(10)
--
-- Uso:
--   local Animal = Class()
--   function Animal:init(nombre) self.nombre = nombre end   -- "constructor"
--   function Animal:hablar() return "..." end
--
--   local Perro = Class(Animal)                 -- Perro HEREDA de Animal
--   function Perro:hablar() return "Guau!" end  -- OVERRIDE (polimorfismo)
--
--   local p = Perro("Fido")                     -- llama a init automáticamente
--   print(p.nombre, p:hablar())                 --> Fido   Guau!
-- =============================================================================

local function Class(parent)
    local cls = {}
    cls.__index = cls        -- las INSTANCIAS buscan sus métodos aquí (en la clase)
    cls.super   = parent     -- guardamos al padre por comodidad (super:init, etc.)

    -- La metatabla de la CLASE hace dos cosas:
    setmetatable(cls, {
        -- 1) HERENCIA: lo que no esté en `cls`, se busca en `parent`.
        __index = parent,

        -- 2) AZÚCAR: permite usar la clase como si fuera una función:  Circle(10)
        __call = function(self, ...)
            local obj = setmetatable({}, self)   -- nace la instancia
            if obj.init then obj:init(...) end   -- corre el "constructor"
            return obj
        end,
    })

    return cls
end

return Class
