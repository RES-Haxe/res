package res.input;

class Mouse {
	public var enabled:Bool = true;

	public var x:Int;
	public var y:Int;

	var res:Res;

	@:allow(res)
	private inline function new(res:Res) {
		this.res = res;
	}

	public inline function set(x, y) {
		this.x = x;
		this.y = y;
	}
}
