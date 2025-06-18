package res.geom;

import res.geom.Vec.TVec;

typedef TRect = {
	x:Float,
	y:Float,
	width:Float,
	height:Float
}

class Rect {
	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;

	public var right(get, never):Float;

	inline function get_right() {
		return x + width;
	}

	public var bottom(get, never):Float;

	inline function get_bottom() {
		return y + height;
	}

	public inline function new(x:Float, y:Float, width:Float, height:Float) {
		set(x, y, width, height);
	}

	public inline function set(x:Float, y:Float, width:Float, height:Float) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	/**
		Define a rectangle by its center point and size.

		Center point defined by x and y coordinates
	**/
	public static inline function center(x:Float, y:Float, width:Float, height:Float) {
		return new Rect(x - width / 2, y - height / 2, width, height);
	}

	/**
		Define a rectangle by its center point and size.

		Center point defined by a 2d vector
	**/
	public static inline function center_v(center:TVec, width:Float, height:Float) {
		return Rect.center(center.x, center.y, width, height);
	}

	/**
		Define a rectangle by its center point and size.

		Center point defined by a 2d vector, size defined 
		by an object having `width` and `height` properties
	**/
	public static inline function center_vs(center:TVec, size:{width:Float, height:Float}) {
		return Rect.center_v(center, size.width, size.height);
	}

	/**
		Define a rectangle by its center point and size.

		Center point and the size are defined by an
		object having x, y, width and height properties
	**/
	public static inline function center_r(r:TRect) {
		return new Rect(r.x - r.width / 2, r.y - r.height / 2, r.width, r.height);
	}

	public static inline function of(rect:TRect) {
		return new Rect(rect.x, rect.y, rect.width, rect.height);
	}

	/**
		Determines if a point is inside this rectangle
	**/
	public function point_inside(point:TVec):Bool {
		return inside(x, y, width, height, point.x, point.y);
	}

	/**
		Does another rectangle intersect this one?
	**/
	public function instersects(rect:TRect) {
		return intersect(x, y, width, height, rect.x, rect.y, rect.width, rect.height);
	}

	/**
		Check for intersection between two rectangles
		defined by their position (x,y) and size (width/height)
	**/
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
	/**
	 * Computes the smallest rectangle that fully contains all rectangles in the given array.
	 *
	 * @param rects An array of `TRect` rectangles to compute the union of.
	 * @return A new `TRect` representing the bounding rectangle that covers all input rectangles.
	 *         If the array is empty, returns a rectangle at (0, 0) with zero width and height.
	 *
	 * The union is the minimal bounding box that encloses all rectangles in the array.
	 */
	public static function union(rects:Array<TRect>):TRect {
		if (rects.length == 0)
			return {
				x: 0,
				y: 0,
				width: 0,
				height: 0
			};

		var x1 = rects[0].x;
		var y1 = rects[0].y;
		var x2 = rects[0].x + rects[0].width;
		var y2 = rects[0].y + rects[0].height;

		for (r in rects) {
			x1 = Math.min(x1, r.x);
			y1 = Math.min(y1, r.y);
			x2 = Math.max(x2, r.x + r.width);
			y2 = Math.max(y2, r.y + r.height);
		}

		return {
			x: x1,
			y: y1,
			width: x2 - x1,
			height: y2 - y1
		};
	}
}
