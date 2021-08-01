package res.geom;

class Recti {
	public static function intersect(x1:Int, y1:Int, w1:Int, h1:Int, x2:Int, y2:Int, w2:Int, h2:Int):Bool {
		final cx1 = x1 + w1 / 2;
		final cy1 = y1 + h1 / 2;

		final cx2 = x2 + w2 / 2;
		final cy2 = y2 + h2 / 2;

		return Math.abs(cx1 - cx2) < (w1 / 2 + w2 / 2) && Math.abs(cy1 - cy2) < (h1 / 2 + h2 / 2);
	}
}
