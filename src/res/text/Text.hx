package res.text;

import res.display.FrameBuffer;
import res.tiles.Tile;

class Text {
	public static function drawText(frameBuffer:FrameBuffer, font:Font, text:String, x:Int, y:Int, ?colorMap:ColorMap) {
		for (cn in 0...text.length) {
			final tile = font.getTile(text.charCodeAt(cn));

			if (tile != null)
				Tile.drawTile(frameBuffer, tile, x + cn * font.tileset.tileSize, y, colorMap);
		}
	}
}
