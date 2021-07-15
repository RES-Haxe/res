package res;

import res.tools.MathTools.wrapi;

class ObjectList implements Renderable implements Updateable {
	private final objects:Array<Object> = [];

	public var wrap:Bool = true;

	public function new() {}

	function sortObjects() {
		objects.sort((a, b) -> a.priority == b.priority ? 0 : a.priority > b.priority ? 1 : -1);
	}

	public function add(object:Object):Object {
		if (object.priority == null)
			object.priority = objects.length;

		objects.push(object);

		sortObjects();

		return object;
	}

	public function render(frameBuffer:FrameBuffer) {
		for (object in objects) {
			// TODO: If wrap throw away objects that are completely out of the screen
			final tileSize:Int = object.sprite.tileset.tileSize;

			final frame = object.currentFrame;

			final lines:Int = object.sprite.hTiles * tileSize;
			final cols:Int = object.sprite.vTiles * tileSize;

			final fromX:Int = Std.int(object.x);
			final fromY:Int = Std.int(object.y);

			for (scanline in 0...lines) {
				if (!((!wrap && (scanline < 0 || scanline >= frameBuffer.frameHeight)))) {
					for (col in 0...cols) {
						final ty:Int = Std.int(scanline / tileSize);
						final tx:Int = Std.int(col / tileSize);

						final tileLine:Int = scanline % tileSize;
						final tileCol:Int = col % tileSize;

						final tileIndex:Int = frame.indecies[ty * object.sprite.hTiles + tx];

						if (tileIndex > 0 && tileIndex - 1 < object.sprite.tileset.numTiles) {
							final tile = object.sprite.tileset.get(tileIndex - 1);

							final sampleIndex:Int = tile.indecies.get(tileLine * tileSize + tileCol);
							if (sampleIndex != 0) {
								final screenX:Int = wrap ? wrapi(fromX + col, frameBuffer.frameWidth) : fromX + col;
								final screenY:Int = wrap ? wrapi(fromY + scanline, frameBuffer.frameHeight) : fromY + scanline;

								if (wrap
									|| (screenX >= 0 && screenY >= 0 && screenX < frameBuffer.frameWidth && screenY < frameBuffer.frameHeight))
									frameBuffer.setIndex(screenX, screenY, object.paletteIndecies[sampleIndex - 1]);
							}
						}
					}
				}
			}
		}
	}

	public function update(dt:Float) {
		for (obj in objects)
			obj.update(dt);
	}
}
