package res.geom;

class Vector2 {
	public var x:Float;
	public var y:Float;

	public var xi(get, never):Int;

	function get_xi()
		return Std.int(x);

	public var yi(get, never):Int;

	function get_yi()
		return Std.int(y);

	public var len2(get, never):Float;

	function get_len2():Float
		return x * x + y * y;

	public var len(get, set):Float;

	function get_len():Float
		return Math.sqrt(len2);

	function set_len(val:Float) {
		final l = len;

		x = x / l * val;
		y = y / l * val;

		return len;
	}

	public inline function new(?x:Float = 0, ?y:Float) {
		set(x, y);
	}

	public function set(x:Float, ?y:Float):Vector2 {
		this.x = x;
		this.y = y == null ? x : y;
		return this;
	}
}
