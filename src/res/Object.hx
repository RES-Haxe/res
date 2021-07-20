package res;

@:enum abstract ObjectAnimDirection(Int) from Int to Int {
	var Forward = 1;
	var Backwards = -1;
}

class Object implements Updateable {
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

	public var currentFrame(get, never):SpriteFrame;

	function get_currentFrame():SpriteFrame
		return sprite.frames[currentFrameIndex];

	var frameTime:Float = 0;
	var currentFrameIndex:Int = 0;

	public inline function new(sprite:Sprite, ?paletteIndecies:Array<Int>) {
		this.sprite = sprite;
		this.paletteIndecies = paletteIndecies;
	}

	public dynamic function stopped() {};

	public function update(dt:Float) {
		if (playing) {
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
}
