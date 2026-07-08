SHAPE ARENA — Figuras y Colisiones con POO en Lua + LÖVE (Love2D)
================================================================
Ejemplo de la ÚLTIMA CLASE — Especialización en Diseño y Desarrollo de
Videojuegos (CUN). Continúa lo visto en "coin-hunt" y lo lleva a POO seria:
abstracción, encapsulamiento, herencia, polimorfismo y composición.


CÓMO CORRERLO
-------------
  1) Instala LÖVE 11.x desde https://love2d.org
  2) Opción A (terminal): entra a esta carpeta y ejecuta:   love .
     Opción B (VSCode):    abre esta carpeta, instala la extensión
                           "Love2D Support" (Pixelbyte) y presiona Alt+L.
     Opción C: arrastra la carpeta "shape-arena" sobre el ejecutable de LÖVE.


CONTROLES
---------
  1 / 2 / 3   crear círculo / rectángulo / triángulo (aparece en el mouse)
  Click izq.  borrar la figura que está bajo el cursor
  Click der.  soltar una figura al azar
  G           mostrar/ocultar los círculos envolventes (broad phase)
  Espacio     pausar / reanudar
  C           limpiar la arena
  H           mostrar/ocultar la ayuda
  Esc         salir


QUÉ MIRAR 
---------------------------
  • Enciende G: verás el "círculo envolvente" de cada figura. Ese es el
    descarte barato (BROAD PHASE) que usamos antes de una prueba exacta.
  • Pasa el mouse por encima de un triángulo: se resalta. Eso usa contains(),
    que en el triángulo es matemática distinta a la del círculo... pero desde
    afuera se llama IGUAL. Eso es POLIMORFISMO.
  • Crea muchas figuras mezcladas (1,2,3) y observa que un SOLO bucle las
    mueve, dibuja y choca a todas. main.lua no sabe qué figura es cada una.


ARQUITECTURA (qué enseña cada archivo)
--------------------------------------
  class.lua      Mini sistema de clases (metatables, __index, herencia).
  shape.lua      CLASE BASE = el "contrato" de toda figura (ABSTRACCIÓN).
  circle.lua     Circle  : Shape   (HERENCIA + POLIMORFISMO + ENCAPSULAMIENTO)
  rectangle.lua  Rectangle : Shape  (AABB)
  triangle.lua   Triangle : Shape   (polígono; contains con test del signo)
  collide.lua    Caja de herramientas de COLISIONES (matemática reutilizable).
  entity.lua     COMPOSICIÓN: Entity = Transform + Shape + Color + estado.
  main.lua       El juego: love.load / update / draw + entradas del usuario.
  conf.lua       Configuración de la ventana.


RETOS (para profundizar)
------------------------
  1. Agrega una nueva figura (Pentágono/Estrella): crea "pentagon.lua" que
     herede de Shape. Si NO tienes que tocar main.lua, tu diseño es bueno.
  2. Usa la NARROW PHASE: cuando dos círculos envolventes se toquen, confirma
     con la prueba exacta (collide.aabbVsAabb o collide.circleVsRect) antes de
     rebotar.
  3. Dale "masa" a cada Entity (según su área) y usa masas distintas en el
     rebote.
  4. Lleva estas clases a coin-hunt: que la moneda y el jugador sean Entities.
