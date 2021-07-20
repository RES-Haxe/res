package res;

import res.tools.MathTools.wrapi;

class ObjectList implements Renderable implements Updateable {
	private final objects:Array<Object> = [];

	public var wrap:Bool = true;

	public var x:Int = 0;
	public var y:Int = 0;

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

			final frame = object.currentFrame;

			final lines:Int = object.sprite.height;
			final cols:Int = object.sprite.width;

			final fromX:Int = x + Std.int(object.x);
			final fromY:Int = y + Std.int(object.y);

			for (scanline in 0...lines) {
				if (!((!wrap && (scanline < 0 || scanline >= frameBuffer.frameHeight)))) {
					for (col in 0...cols) {
						final sampleIndex:Int = frame.data.get(scanline * object.sprite.width + col);
						if (sampleIndex != 0) {
							final screenX:Int = wrap ? wrapi(fromX + col, frameBuffer.frameWidth) : fromX + col;
							final screenY:Int = wrap ? wrapi(fromY + scanline, frameBuffer.frameHeight) : fromY + scanline;

							if (wrap
								|| (screenX >= 0 && screenY >= 0 && screenX < frameBuffer.frameWidth && screenY < frameBuffer.frameHeight))
								frameBuffer.setIndex(screenX, screenY, object.paletteIndecies == null ? sampleIndex : object.paletteIndecies[sampleIndex - 1]);
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
