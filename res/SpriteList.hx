package res;

import haxe.io.Bytes;

class SpriteList implements Renderable {
	public final sprites:Array<Sprite> = [];

	var res:Res;

	@:allow(res)
	private function new(res:Res, ?initialList:Array<Sprite>) {
		this.res = res;

		if (initialList != null)
			for (item in initialList)
				sprites.push(item);
	}

	public function render(frameBuffer:Bytes, frameWidth:Int, frameHeight:Int) {
		for (sprite in sprites) {
			final frame = sprite.currentFrame;

			final lines:Int = sprite.hTiles * res.tileSize;
			final cols:Int = sprite.vTiles * res.tileSize;

			final fromX:Int = Std.int(sprite.x);
			final fromY:Int = Std.int(Math.max(0, sprite.y));

			final toX:Int = fromX + res.tileSize * sprite.hTiles;
			final toY:Int = fromY + res.tileSize * sprite.vTiles;

			for (scanline in 0...lines) {
				for (col in 0...cols) {
					final ty:Int = Std.int(scanline / res.tileSize);
					final tx:Int = Std.int(col / res.tileSize);

					final tileLine:Int = scanline % res.tileSize;
					final tileCol:Int = col % res.tileSize;

					final tileIndex:Int = frame.indecies[ty * sprite.hTiles + tx];

					if (tileIndex > 0 && tileIndex - 1 < sprite.tileset.numTiles) {
						final tile = sprite.tileset.get(tileIndex - 1);

						final sampleIndex:Int = tile.indecies.get(tileLine * res.tileSize + tileCol);
						if (sampleIndex != 0) {
							final color = res.palette.get(sampleIndex - 1);

							final screenX:Int = fromX + col;
							final screenY:Int = fromY + scanline;

							frameBuffer.setInt32((screenY * frameWidth + screenX) * res.pixelSize, color.format(res.pixelFormat));
						}
					}
				}
			}
		}
	}
}
