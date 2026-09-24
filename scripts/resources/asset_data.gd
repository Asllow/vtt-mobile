extends Resource
class_name AssetData

@export var id: String = ""
@export var name: String = ""
@export_enum("Terrain", "Structures", "Decoration", "Entities", "Effects") var category: String = "Terrain"
@export var pack_id: String = "base_fantasy"

# Informações para mapear com o TileSet do Godot
@export var source_id: int = 0
@export var atlas_coords: Vector2i = Vector2i.ZERO

# Autotiling / Terrain Sets
@export var use_autotiling: bool = false
@export var terrain_set: int = 0
@export var terrain: int = 0

@export var texture: Texture2D
@export var visual_size: Vector2 = Vector2(64, 64)
@export var anchor: Vector2 = Vector2(0.5, 0.5)
@export var footprint: Vector2i = Vector2i(1, 1)

# Enum para a Camada sugerida onde o Tile deve ser pintado
@export_enum("Ground", "Objects", "Effects") var default_layer: String = "Ground"

@export var is_blocking: bool = false
@export var selectable: bool = true
