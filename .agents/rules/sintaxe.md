---
trigger: always_on
---

- Use estritamente GDScript compatível com Godot 4.x (TileMapLayer, Tween via create_tween(), @export tipado).
- NUNCA use sintaxes legadas do Godot 3:
  - Proibido: yield() -> use await
  - Proibido: TileMap legada -> use TileMapLayer
  - Proibido: SceneTreeTween antigo -> use create_tween()
  - Proibido: set_network_master() -> use set_multiplayer_authority()
- Sempre use tipagem estática (cell: Vector2i, id: String, pos: Vector2).
