package res.display;

using Math;
using res.tools.BytesTools;

@:enum abstract ObjectAnimDirection(Int) from Int to Int {
	var Forward = 1;
	var Backwards = -1;
}

class SpriteObject extends Object {
	public var flipX:Bool = false;
	public var flipY:Bool = false;

	public var playing:Bool = false;

	public var animDirection:ObjectAnimDirection = Forward;

	public var loop:Bool = true;

	public var priority:Null<Int> = null;

	public final sprite:Sprite;

	public var wrap:Bool = false;

	public var currentFrame(get, never):SpriteFrame;

	function get_currentFrame():SpriteFrame
		return sprite.frames[currentFrameIndex];

	var frameTime:Float = 0;

	public var currentFrameIndex:Int = 0;

	public function new(sprite:Sprite, ?colorMap:Array<Int>) {
		this.sprite = sprite;
		this.colorMap = colorMap;

		width = sprite.width;
		height = sprite.height;
	}

	public dynamic function stopped() {};

	override public function update(dt:Float) {
		super.update(dt);

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
	}

	override function selfRender(frameBuffer:FrameBuffer, atx:Float, aty:Float)
		Sprite.drawSprite(frameBuffer, sprite, atx.floor(), aty.floor(), width.floor(), height.floor(), currentFrameIndex, flipX, flipY, wrap, colorMap);
}
