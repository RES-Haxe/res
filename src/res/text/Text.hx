package res.text;

import res.display.FrameBuffer;
import res.tiles.Tile;

class Text {
	public var font:Font;
	public var text:String;
	public var colorMap:ColorMap;
	public var x:Float = 0;
	public var y:Float = 0;

	public function new(font:Font, text:String, ?x:Float = 0, ?y:Float = 0, ?colorMap:ColorMap) {
		this.font = font;
		this.text = text;
		this.colorMap = colorMap;
		this.x = x;
		this.y = y;
	}

	public function render(frameBuffer:FrameBuffer) {
		drawText(frameBuffer, font, text, Math.floor(x), Math.floor(y), colorMap);
	}

	public static function drawText(frameBuffer:FrameBuffer, font:Font, text:String, x:Int, y:Int, ?colorMap:ColorMap) {
		var tx = x;
		var ty = y;
		for (cn in 0...text.length) {
			final char = text.charCodeAt(cn);

			if (char == '\n'.charCodeAt(0)) {
				tx = x;
				ty += font.tileset.tileSize;
			} else {
				final tile = font.getTile(char);

				if (tile != null)
					Tile.drawTile(frameBuffer, tile, tx, ty, colorMap);

				tx += font.tileset.tileSize;
			}
		}
	}
}