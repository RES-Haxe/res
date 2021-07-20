package res.text;

import res.tiles.Tilemap;
import res.tiles.Tileset;

class Textmap extends Tilemap {
	private var _charMap:Map<Int, Int> = [];

	@:allow(res)
	private function new(tileset:Tileset, hTiles:Int, vTiles:Int, characters:String, ?firstTileIndex:Int = 0, ?paletteIndecies:Array<Int>) {
		super(tileset, hTiles, vTiles, paletteIndecies);

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

	/**
		Set a centered line of text

		@param aty line at which the text should be displayed
		@param text text to display
		@param clearStart remove any tiles from the left side to the first character of the string
		@param clearEnd remove any tiles to the end of the line
	 */
	public function textCentered(aty:Int, text:String, ?clearStart:Bool = true, ?clearEnd:Bool = true) {
		final pos:Int = Std.int((hTiles - text.length) / 2);

		if (clearStart)
			if (pos > 0)
				for (x in 0...pos)
					set(x, aty, 0);

		textAt(pos, aty, text, clearEnd);
	}
}
