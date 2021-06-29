package res;

import haxe.io.Bytes;

class Textmap extends Tilemap {
	private var _charMap:Map<Int, Int> = [];

	@:allow(res)
	private function new(res:Res, hTiles:Int, vTiles:Int, data:Bytes, srcWidth:Int, srcHeight:Int, characters:String, ?paletteSample:PaletteSample) {
		var fontTileset = res.createTileset();

		fontTileset.fromBytes(data, srcWidth, srcHeight);

		super(res, fontTileset, hTiles, vTiles, paletteSample);

		for (ci in 0...characters.length) {
			_charMap[characters.charCodeAt(ci)] = ci + 1;
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
