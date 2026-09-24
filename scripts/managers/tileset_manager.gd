extends Node

var loaded_packs: Dictionary = {} # pack_id -> TilesetPack
var asset_registry: Dictionary = {} # asset_id -> AssetData (global lookup)

func _ready() -> void:
	var default_texture = preload("res://assets/tilesets/tiles.png")
	
	# Mock data para manter o MVP funcionando na Fase D
	var grass = AssetData.new()
	grass.id = "base_fantasy.grass"
	grass.source_id = 0
	grass.atlas_coords = Vector2i(0, 0)
	grass.default_layer = "Ground"
	grass.use_autotiling = true
	grass.terrain_set = 0
	grass.terrain = 0
	grass.texture = default_texture
	asset_registry[grass.id] = grass
	
	var stone = AssetData.new()
	stone.id = "base_fantasy.stone"
	stone.source_id = 0
	stone.atlas_coords = Vector2i(1, 0)
	stone.default_layer = "Ground"
	stone.use_autotiling = true
	stone.terrain_set = 0
	stone.terrain = 1
	stone.texture = default_texture
	asset_registry[stone.id] = stone

	
	var default_props = preload("res://assets/tilesets/props.png")
	
	var tree = AssetData.new()
	tree.id = "base_fantasy.tree"
	tree.source_id = 1
	tree.atlas_coords = Vector2i(0, 0)
	tree.default_layer = "Objects"
	tree.use_autotiling = false
	tree.texture = default_props
	asset_registry[tree.id] = tree
	
	var rock = AssetData.new()
	rock.id = "base_fantasy.rock"
	rock.source_id = 1
	rock.atlas_coords = Vector2i(1, 0)
	rock.default_layer = "Objects"
	rock.use_autotiling = false
	rock.texture = default_props
	asset_registry[rock.id] = rock
	
	var crate = AssetData.new()
	crate.id = "base_fantasy.crate"
	crate.source_id = 1
	crate.atlas_coords = Vector2i(2, 0)
	crate.default_layer = "Objects"
	crate.use_autotiling = false
	crate.texture = default_props
	asset_registry[crate.id] = crate
	
	var barrel = AssetData.new()
	barrel.id = "base_fantasy.barrel"
	barrel.source_id = 1
	barrel.atlas_coords = Vector2i(3, 0)
	barrel.default_layer = "Objects"
	barrel.use_autotiling = false
	barrel.texture = default_props
	asset_registry[barrel.id] = barrel

func load_all_packs() -> void:
	# Futuramente: varrer a pasta content/tilesets e carregar os .tres
	pass

func get_asset(asset_id: String) -> AssetData:
	return asset_registry.get(asset_id)

func get_pack(pack_id: String) -> TilesetPack:
	return loaded_packs.get(pack_id)
