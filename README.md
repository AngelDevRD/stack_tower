# Stack Tower

Juego de apilar bloques (estilo Stack/Tower Tumble) hecho en Flutter para
portafolio: Material 3, Riverpod, Clean Architecture ligera y persistencia
local.

## Qué incluye

- Bloque en oscilación horizontal continua; toque en pantalla para soltarlo.
- Cálculo de solape/corte real: la parte que no se superpone con el bloque de
  abajo se recorta y cae con una animación de caída + desvanecimiento.
- Fin de partida cuando el solape es cero (fallo completo).
- Dificultad progresiva: la velocidad de oscilación aumenta con la altura.
- Cámara que sigue la torre suavemente conforme crece más allá de la
  pantalla visible.
- Efecto de partículas al colocar un bloque, con variante especial para
  colocaciones "perfectas" (near-100% de solape) + bonus de puntaje.
- Vibración configurable en colocación/colocación perfecta/fin de partida.
- Logros, estadísticas (partidas, mejor altura, colocaciones perfectas,
  tiempo jugado) y modo infinito + reto diario (altura objetivo que cambia
  cada día).
- 4 paletas de color para los bloques, desbloqueables por hitos de puntaje.
- Tutorial de primer lanzamiento, splash animado, layout responsive.

## Simplificaciones deliberadas frente al listado original

- **`shared_preferences` en vez de Hive/Isar**: cubre ajustes/progreso/
  estadísticas/reto diario sin generación de código.
- **Sin archivos de audio reales**: `AudioService` está cableado con
  `audioplayers`, pero si el asset no existe el error se captura y se
  loguea con `debugPrint` en vez de romper la app.
- **Un solo idioma (español)**: sin infraestructura ARB/flutter_intl
  completa.
- **Paletas de bloques en vez de "skins" complejas**: 4 paletas de color
  fijas desbloqueadas por puntaje, sin economía de monedas.
- **Reto diario simplificado**: una única altura objetivo por día
  (determinística por fecha), sin motor de misiones.

## Arquitectura

- `lib/domain`: matemática de solape/corte, curva de dificultad,
  oscilación — Dart puro, testeable de forma aislada.
- `lib/data`: repositorios sobre `shared_preferences` + `AudioService`.
- `lib/providers`: `GameController` (StateNotifier impulsado por un
  `Ticker` para el bucle de juego a 60fps).
- `lib/presentation`: pantallas y widgets (incluye la cámara con scroll
  animado), navegación con `go_router`.

## Cómo correr

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test
```

Cubren el cálculo de solape/corte (perfecto, parcial, fallo total), la
progresión de dificultad y el reinicio del reto diario por fecha.
