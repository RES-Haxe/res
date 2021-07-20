package res;

import haxe.io.Bytes;

class SpriteFrame {
	public final data:Bytes;
	public final duration:Int;

	public function new(data:Bytes, duration:Int) {
		this.data = data;
		this.duration = duration;
	}
}
