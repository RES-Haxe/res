package res.text;

import res.tiles.Tilemap;
import res.tiles.Tileset;
import res.tools.MathTools.wrapi;

class Textmap extends Tilemap {
	private final _charMap:Map<Int, Int> = [];

	public final cursor:{x:Int, y:Int} = {x: 0, y: 0};

	public function new(tileset:Tileset, hTiles:Int, vTiles:Int, characters:String, ?firstTileIndex:Int = 0, ?colorMap:ColorMap) {
		super(tileset, hTiles, vTiles, colorMap);

		for (ci in 0...characters.length)
			_charMap[characters.charCodeAt(ci)] = firstTileIndex + ci + 1;
	}

	public function moveTo(x:Int, y:Int) {
		cursor.x = wrapi(x, hTiles);
		cursor.y = wrapi(y, vTiles);
	}

	public function print(text:String, ?colorMap:Array<Int>) {
		for (c in 0...text.length) {
			final char = text.charAt(c);

			if (char != '\n') {
				setChar(cursor.x, cursor.y, char, colorMap);
				cursor.x++;
			} else {
				cursor.x = 0;
				cursor.y++;
			}

			if (cursor.x >= hTiles) {
				cursor.y++;
				cursor.x = 0;
			}

			if (cursor.y >= vTiles)
				cursor.y = 0;
		}
	}

	/**
		Set a particular character at specified tile place

		@param atx Tile x coordinate
		@param aty Tile y coordinate
		@param char String containing the character to place. Only the first character will be used if the string is longer
		@param colorMap Array of color indecies to use
	 */
	public function setChar(atx:Int, aty:Int, char:String, ?colorMap:Array<Int>) {
		if (char.length == 0)
			throw '`char` must contain a character to set';
		set(atx, aty, _charMap[char.charCodeAt(0)], colorMap);
	}

	/**
		Set character indecies for the given text

		@param atx Tile x coordinate to start setting characters
		@param aty Tile y coordinate
		@param text Text to set
		@param colorMap Array of color indecies to use
		@param clearEnd Clear any tiles to the end of the line
	 */
	public function textAt(atx:Int, aty:Int, text:String, ?colorMap:Array<Int>, ?clearEnd:Bool = true) {
		if (aty >= 0 && aty < map.length) {
			for (tx in atx...hTiles) {
				var ci = tx - atx;

				if (ci < text.length)
					setChar(tx, aty, text.charAt(ci), colorMap);
				else if (clearEnd)
					set(tx, aty, 0);
				else
					return;
			}
		}
	}

	/**
		Set a centered line of text

		@param aty Line at which the text should be displayed
		@param text Text to display
		@param colorMap Array of color indecies to use
		@param clearStart Remove any tiles from the left side to the first character of the string
		@param clearEnd Clear any tiles to the end of the line
	 */
	public function textCentered(aty:Int, text:String, ?colorMap:Array<Int>, ?clearStart:Bool = true, ?clearEnd:Bool = true) {
		final pos:Int = Std.int((hTiles - text.length) / 2);

		if (clearStart)
			if (pos > 0)
				for (x in 0...pos)
					set(x, aty, 0);

		textAt(pos, aty, text, colorMap, clearEnd);
	}
}
