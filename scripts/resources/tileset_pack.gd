extends Resource
class_name TilesetPack

@export var pack_id: String = ""
@export var pack_name: String = ""

# Referência para o TileSet real que será assinalado ao TileMapLayer
@export var tileset: TileSet 

# Lista de definições de cada elemento do pack para que a UI do Mestre possa montar a paleta
@export var assets: Array[AssetData] = []
