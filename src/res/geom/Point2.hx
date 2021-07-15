package res.geom;

class Point2<T> {
	public var x:T;
	public var y:T;

	public inline function new(x:T, y:T) {
		this.set(x, y);
	}

	public function set(x:T, y:T) {
		this.x = x;
		this.y = y;
		return this;
	}
}
