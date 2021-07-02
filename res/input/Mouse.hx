package res.input;

class Mouse {
	public var enabled:Bool = true;

	public var x:Int;
	public var y:Int;

	@:allow(res)
	private function new() {}

	public inline function set(x, y) {
		this.x = x;
		this.y = y;
	}
}
