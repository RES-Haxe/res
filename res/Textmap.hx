package res;

import haxe.io.Bytes;

class Textmap extends Tilemap {
	private var _charMap:Map<Int, Int> = [];

	@:allow(res)
	private function new(res:Res, tileset:Tileset, hTiles:Int, vTiles:Int, characters:String, ?firstTileIndex:Int = 0, ?paletteSample:PaletteSample) {
		super(res, tileset, hTiles, vTiles, paletteSample);

		for (ci in 0...characters.length) {
			_charMap[characters.charCodeAt(ci)] = firstTileIndex + ci + 1;
		}
	}

	public function textAt(atx:Int, aty:Int, text:String) {
		if (aty >= 0 && aty < map.length) {
			for (ci in 0...text.length) {
				final tx = atx + ci;
				if (tx >= 0 && tx < map[aty].length) {
					set(tx, aty, _charMap[text.charCodeAt(ci)]);
				}
			}
		}
	}
}
