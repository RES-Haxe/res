package res.geom;

class Rect {
	public static function intersect(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float):Bool {
		final cx1 = x1 + w1 / 2;
		final cy1 = y1 + h1 / 2;

		final cx2 = x2 + w2 / 2;
		final cy2 = y2 + h2 / 2;

		return Math.abs(cx1 - cx2) < (w1 / 2 + w2 / 2) && Math.abs(cy1 - cy2) < (h1 / 2 + h2 / 2);
	}
}
