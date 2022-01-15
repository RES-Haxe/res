package res.text;

import res.tiles.Tile;
import res.tiles.Tileset;

class Font {
	public final name:String;
	public final tileset:Tileset;
	public final characters:String;
	public final firstTileIndex:Int;

	final _charMap:Map<Int, Int>;

	public inline function new(name:String, tileset:Tileset, characters:String, firstTileIndex:Int = 0) {
		this.name = name;
		this.tileset = tileset;
		this.characters = characters;
		this.firstTileIndex = firstTileIndex;

		_charMap = [for (n in 0...characters.length) characters.charCodeAt(n) => n];
	}

	public function getTileIndex(char:Int):Null<Int> {
		return _charMap[char];
	}

	public function getTile(char:Int):Tile {
		final index = getTileIndex(char);

		if (index != null)
			return tileset.get(index);

		return null;
	}
}
