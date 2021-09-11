package res.text;

import res.tiles.Tileset;

class Font {
	public final name:String;
	public final tileset:Tileset;
	public final characters:String;
	public final firstTileIndex:Int;
	public final numColors:Int;

	public inline function new(name:String, tileset:Tileset, characters:String, firstTileIndex:Int = 0, numColors:Int = 1) {
		this.name = name;
		this.tileset = tileset;
		this.characters = characters;
		this.firstTileIndex = firstTileIndex;
		this.numColors = numColors;
	}
}
