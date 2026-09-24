---
trigger: always_on
---

- Eventos de tela DEVEM usar InputEventScreenTouch e InputEventScreenDrag.
- Ao tratar arrasto de elementos (tokens, UI), sempre consuma o evento com:
  `get_viewport().set_input_as_handled()` para não propagar para a Camera2D (touch_camera_2d.gd).
- Nunca rely em "Emulate Mouse from Touch" para lógicas multi-touch (pinch-to-zoom exige múltiplos índices).
