package res.geom;

class Rect {
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;

	public function new(x:Float, y:Float, width:Float, height:Float) {
		set(x, y, width, height);
	}

	public function set(x:Float, y:Float, width:Float, height:Float) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public function isPointInside(point:{x:Float, y:Float}):Bool
		return inside(x, y, width, height, point.x, point.y);

	public function isRectIntersects(rect:{
		x:Float,
		y:Float,
		width:Float,
		height:Float
	})
		return intersect(x, y, width, height, rect.x, rect.y, rect.width, rect.height);

	public static function intersect(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Bool {
		final cx1 = x1 + w1 / 2;
		final cy1 = y1 + h1 / 2;

		final cx2 = x2 + w2 / 2;
		final cy2 = y2 + h2 / 2;

		return Math.abs(cx1 - cx2) < (w1 / 2 + w2 / 2) && Math.abs(cy1 - cy2) < (h1 / 2 + h2 / 2);
	}

	public static inline function inside(rx:Float, ry:Float, rw:Float, rh:Float, x:Float, y:Float):Bool {
		return x >= rx && x <= rx + rw && y >= ry && y <= ry + rh;
	}
}
