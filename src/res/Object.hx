package res;

import res.tools.MathTools.wrapi;

@:enum abstract ObjectAnimDirection(Int) from Int to Int {
	var Forward = 1;
	var Backwards = -1;
}

class Object extends Renderable implements Updateable {
	private final children:Array<Object> = [];

	public var x:Float = 0;
	public var y:Float = 0;

	public var flipX:Bool = false;
	public var flipY:Bool = false;

	public var playing:Bool = false;

	public var animDirection:ObjectAnimDirection = Forward;

	public var loop:Bool = true;

	public var priority:Null<Int> = null;

	public final sprite:Sprite;

	public final paletteIndecies:Array<Int>;

	public var wrap:Bool = true;

	public var currentFrame(get, never):SpriteFrame;

	function get_currentFrame():SpriteFrame
		return sprite.frames[currentFrameIndex];

	var frameTime:Float = 0;

	public var currentFrameIndex:Int = 0;

	public function new(?sprite:Sprite, ?paletteIndecies:Array<Int>) {
		this.sprite = sprite;
		this.paletteIndecies = paletteIndecies;
	}

	function sortChildren() {
		children.sort((a, b) -> a.priority == b.priority ? 0 : a.priority > b.priority ? 1 : -1);
	}

	public function add(object:Object):Object {
		if (object.priority == null)
			object.priority = children.length;

		children.push(object);

		sortChildren();

		return object;
	}

	public function remove(object:Object):Object {
		children.remove(object);
		return object;
	}

	public dynamic function stopped() {};

	public function update(dt:Float) {
		if (sprite != null && playing) {
			final currentFrameDuration = (currentFrame.duration / 1000);

			while (frameTime > currentFrameDuration) {
				frameTime -= currentFrameDuration;
				currentFrameIndex += animDirection;

				if (animDirection == Forward && currentFrameIndex >= sprite.frames.length) {
					if (loop) {
						currentFrameIndex = 0;
					} else {
						currentFrameIndex = sprite.frames.length - 1;
						playing = false;
						stopped();
					}
				}

				if (animDirection == Backwards && currentFrameIndex < 0) {
					if (loop) {
						currentFrameIndex = sprite.frames.length - 1;
					} else {
						currentFrameIndex = 0;
						playing = false;
						stopped();
					}
				}
			}

			frameTime += dt;
		}

		for (child in children)
			child.update(dt);
	}

	function renderObject(frameBuffer:FrameBuffer, ?tx:Float = 0, ?ty:Float = 0, ?wrap:Bool) {
		if (!visible)
			return;

		final gX = tx + x;
		final gY = ty + y;

		if (wrap == null)
			wrap = this.wrap;

		if (sprite != null) {
			// TODO: If wrap throw away objects that are completely out of the screen

			final frame = currentFrame;

			final lines:Int = sprite.height;
			final cols:Int = sprite.width;

			final fromX:Int = Math.floor(gX);
			final fromY:Int = Math.floor(gY);

			for (scanline in 0...lines) {
				if (!((!wrap && (scanline < 0 || scanline >= frameBuffer.frameHeight)))) {
					for (col in 0...cols) {
						final sampleIndex:Int = frame.data.get(scanline * sprite.width + col);
						if (sampleIndex != 0) {
							final screenX:Int = wrap ? wrapi(fromX + col, frameBuffer.frameWidth) : fromX + col;
							final screenY:Int = wrap ? wrapi(fromY + scanline, frameBuffer.frameHeight) : fromY + scanline;

							if (wrap
								|| (screenX >= 0 && screenY >= 0 && screenX < frameBuffer.frameWidth && screenY < frameBuffer.frameHeight))
								frameBuffer.setIndex(screenX, screenY, paletteIndecies == null ? sampleIndex : paletteIndecies[sampleIndex - 1]);
						}
					}
				}
			}
		}

		for (child in children)
			child.renderObject(frameBuffer, gX, gY, wrap);
	}

	override function render(frameBuffer:FrameBuffer) {
		renderObject(frameBuffer, wrap);
	}
}
