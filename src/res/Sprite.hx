package res;

import haxe.io.Bytes;

class Sprite {
	public final frames:Array<SpriteFrame>;

	public final width:Int;
	public final height:Int;

	@:allow(res)
	private function new(width:Int, height:Int, ?frames:Array<SpriteFrame>) {
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
}
