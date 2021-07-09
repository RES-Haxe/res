package res;

class Object implements Updateable {
	public var x:Float = 0;
	public var y:Float = 0;

	public var flipX:Bool = false;
	public var flipY:Bool = false;

	public var priority:Null<Int> = null;

	public final sprite:Sprite;

	public final paletteIndecies:Array<Int>;

	public var currentFrame(get, never):SpriteFrame;

	var frameTime:Float = 0;
	var currentFrameIndex:Int = 0;

	function get_currentFrame():SpriteFrame
		return sprite.frames[currentFrameIndex];

	public inline function new(sprite:Sprite, paletteIndecies:Array<Int>) {
		this.sprite = sprite;
		this.paletteIndecies = paletteIndecies;
	}

	public function update(dt:Float) {
		final currentFrameDuration = (currentFrame.duration / 1000);

		while (frameTime > currentFrameDuration) {
			frameTime -= currentFrameDuration;
			currentFrameIndex++;
			if (currentFrameIndex >= sprite.frames.length)
				currentFrameIndex = 0;
		}

		frameTime += dt;
	}
}
