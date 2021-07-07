package res;

class Textmap extends Tilemap {
	private var _charMap:Map<Int, Int> = [];

	@:allow(res)
	private function new(res:Res, tileset:Tileset, hTiles:Int, vTiles:Int, characters:String, ?firstTileIndex:Int = 0, ?paletteSample:PaletteSample) {
		super(res, tileset, hTiles, vTiles, paletteSample);

		for (ci in 0...characters.length)
			_charMap[characters.charCodeAt(ci)] = firstTileIndex + ci + 1;
	}

	public function textAt(atx:Int, aty:Int, text:String, ?clearEnd:Bool = true) {
		if (aty >= 0 && aty < map.length) {
			for (tx in atx...hTiles) {
				var ci = tx - atx;

				if (ci < text.length)
					set(tx, aty, _charMap[text.charCodeAt(ci)]);
				else if (clearEnd)
					set(tx, aty, 0);
				else
					return;
			}
		}
	}
}
