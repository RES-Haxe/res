package res.tools;

import res.types.Shape;

class ShapeTools {
	public static function pos(shape:Shape):{x:Float, y:Float} {
		switch shape {
			case CIRCLE(cx, cy, r):
				return {x: cx, y: cy};
			case RECT(cx, cy, w, h):
				return {x: cx, y: cy};
		}
	}

	public static function moveTo(shape:Shape, newcx:Float, newcy:Float):Shape {
		switch shape {
			case CIRCLE(cx, cy, r):
				return CIRCLE(newcx, newcy, r);
			case RECT(cx, cy, w, h):
				return RECT(newcx, newcy, w, h);
		}
	}
}
