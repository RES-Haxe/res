package res.display;

import haxe.io.Bytes;
import res.tools.MathTools.wrapi;

using res.tools.BytesTools;

class Sprite {
	public final frames:Array<SpriteFrame>;

	public final width:Int;
	public final height:Int;

	public function new(width:Int, height:Int, ?frames:Array<SpriteFrame>) {
		this.width = width;
		this.height = height;
		this.frames = frames != null ? frames : [];

		for (frame in frames)
			if (frame.data.length != width * height)
				throw 'Invalid frame size';
	}

	public function addFrame(data:Bytes, duration:Int) {
		if (data.length != width * height)
			throw 'Invalid frame size';

		frames.push(new SpriteFrame(data, duration));
	}

	public function createObject(?x:Float = 0, ?y:Float = 0, ?colorMap:Array<Int>):SpriteObject
		return new SpriteObject(this, x, y, colorMap);

	public static function drawSprite(sprite:Sprite, frameBuffer:FrameBuffer, ?x:Int = 0, ?y:Int = 0, ?width:Int, ?height:Int, ?frameIndex:Int = 0,
			?wrapping:Bool = true, ?colorMap:Array<Int>) {
		final frame = sprite.frames[frameIndex];

		final lines:Int = height;
		final cols:Int = width;

		final fromX:Int = x;
		final fromY:Int = y;

		for (scanline in 0...lines) {
			if (!((!wrapping && (scanline < 0 || scanline >= frameBuffer.frameHeight)))) {
				for (col in 0...cols) {
					final spriteLine = wrapi(scanline, sprite.height);
					final spriteCol = wrapi(col, sprite.width);
					final sampleIndex:Int = frame.data.getxy(sprite.width, spriteCol, spriteLine);

					if (sampleIndex != 0) {
						final screenX:Int = wrapping ? wrapi(fromX + col, frameBuffer.frameWidth) : fromX + col;
						final screenY:Int = wrapping ? wrapi(fromY + scanline, frameBuffer.frameHeight) : fromY + scanline;

						if (wrapping
							|| (screenX >= 0 && screenY >= 0 && screenX < frameBuffer.frameWidth && screenY < frameBuffer.frameHeight)) {
							frameBuffer.setIndex(screenX, screenY, colorMap == null ? sampleIndex : colorMap[sampleIndex - 1]);
						}
					}
				}
			}
		}
	}
}
