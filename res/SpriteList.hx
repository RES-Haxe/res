package res;

import haxe.io.Bytes;
import res.helpers.Funcs.wrapi;

class SpriteList implements Renderable {
	private final sprites:Array<Sprite> = [];

	var res:Res;

	@:allow(res)
	private function new(res:Res, ?initialList:Array<Sprite>) {
		this.res = res;

		if (initialList != null) {
			var nextPriority:Int = 0;

			for (item in initialList) {
				if (item.priority == null)
					item.priority = nextPriority++;
				sprites.push(item);
			}
		}
	}

	function sortSprites() {
		sprites.sort((a, b) -> a.priority == b.priority ? 0 : a.priority > b.priority ? 1 : -1);
	}

	public function add(sprite:Sprite) {
		if (sprite.priority == null)
			sprite.priority = sprites.length;

		sprites.push(sprite);

		sortSprites();
	}

	public function render(frameBuffer:Bytes, frameWidth:Int, frameHeight:Int) {
		for (sprite in sprites) {
			final frame = sprite.currentFrame;

			final lines:Int = sprite.hTiles * res.tileSize;
			final cols:Int = sprite.vTiles * res.tileSize;

			final fromX:Int = Std.int(sprite.x);
			final fromY:Int = Std.int(sprite.y);

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
							final color = sprite.paletteSample.get(sampleIndex - 1);

							final screenX:Int = wrapi(fromX + col, frameWidth);
							final screenY:Int = wrapi(fromY + scanline, frameHeight);

							frameBuffer.setInt32((screenY * frameWidth + screenX) * res.pixelSize, color.format(res.pixelFormat));
						}
					}
				}
			}
		}
	}
}
