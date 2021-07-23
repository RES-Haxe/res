package res.input;

import res.tools.MathTools.wrapi;

class Mouse {
	public var enabled:Bool = true;

	public var x:Int;
	public var y:Int;

	var res:RES;

	@:allow(res)
	private inline function new(res:RES) {
		this.res = res;
	}

	public function push(button:MouseButton) {}

	public function release(button:MouseButton) {}

	public inline function moveTo(x:Int, y:Int) {
		this.x = wrapi(x, res.frameBuffer.frameWidth);
		this.y = wrapi(y, res.frameBuffer.frameHeight);
	}
}
