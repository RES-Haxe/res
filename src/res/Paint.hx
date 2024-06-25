package res;

import Math.abs;
import res.Mth.max;
import res.Mth.min;
import res.geom.Rect;
import res.geom.Vec;

/**
	Tool class for drawing shapes on a `Bitmap`

	Can be used as a static extension for `Bitmap`/`FrameBuffer`

	e.g.:

	```haxe
	using res.Paint;

	final bitmap:Bitmap = new Bitmap(128, 128);

	// ...

	function render(frameBuffer:FrameBuffer) {

		bitmap.circle(64, 64, 64, 7, 2);

		frameBuffer.line(0, 0, 100, 100, 5);
	}

	```
 */
class Paint {
	/**
		Draw a circle

		@param surface
		@param cx Center x
		@param cy Center y
		@param r radius
		@param strokeIndex Stroke color index
		@param fillIndex Fill color index
	 */
	public static inline function circle(surface:Bitmap, cx:Float, cy:Float, r:Float, strokeIndex:Int, ?fillIndex:Int, ?transparency:Bool = true) {
		return ellipse(surface, cx, cy, r, r, strokeIndex, fillIndex, transparency);
	}

	public static inline function circlev(surface:Bitmap, v:Vec, r:Float, strokeIndex:Int, ?fillIndex:Int, ?transparency:Bool = true) {
		return circle(surface, v.x, v.y, r, strokeIndex, fillIndex, transparency);
	}

	/**
		Draw an ellipse

		@param surface
		@param cx
		@param cy
		@param rx
		@param ry
		@param strokeIndex
		@param fillIndex

		@see https://www.geeksforgeeks.org/midpoint-ellipse-drawing-algorithm/
	 */
	public static function ellipsei(surface:Bitmap, cx:Int, cy:Int, rx:Int, ry:Int, strokeIndex:Int, ?fillIndex:Int, ?transparency:Bool = true) {
		if (rx == 0 || ry == 0)
			return surface;

		fillIndex = fillIndex ?? strokeIndex;

		var dx:Float;
		var dy:Float;
		var d1:Float;
		var d2:Float;
		var x:Float;
		var y:Float;

		x = 0;
		y = ry;

		d1 = (ry * ry) - (rx * rx * ry) + (0.25 * rx * rx);
		dx = 2 * ry * ry * x;
		dy = 2 * rx * rx * y;

		function plot() {
			if (fillIndex != null) {
				final fx = surface.round(-x + cx);
				final tx = surface.round(x + cx);

				for (px in fx...tx + 1) {
					final index = px == fx || px == tx ? strokeIndex : fillIndex;

					surface.set(px, y + cy, index, transparency);
					surface.set(px, -y + cy, index, transparency);
				}
			} else {
				surface.set(x + cx, y + cy, strokeIndex, transparency);
				surface.set(-x + cx, y + cy, strokeIndex, transparency);
				surface.set(x + cx, -y + cy, strokeIndex, transparency);
				surface.set(-x + cx, -y + cy, strokeIndex, transparency);
			}
		}

		while (dx < dy) {
			plot();

			if (d1 < 0) {
				x++;
				dx = dx + (2 * ry * ry);
				d1 = d1 + dx + (ry * ry);
			} else {
				x++;
				y--;
				dx = dx + (2 * ry * ry);
				dy = dy - (2 * rx * rx);
				d1 = d1 + dx - dy + (ry * ry);
			}
		}

		d2 = ((ry * ry) * ((x + 0.5) * (x + 0.5))) + ((rx * rx) * ((y - 1) * (y - 1))) - (rx * rx * ry * ry);

		while (y >= 0) {
			plot();

			if (d2 > 0) {
				y--;
				dy = dy - (2 * rx * rx);
				d2 = d2 + (rx * rx) - dy;
			} else {
				y--;
				x++;
				dx = dx + (2 * ry * ry);
				dy = dy - (2 * rx * rx);
				d2 = d2 + dx - dy + (rx * rx);
			}
		}

		return surface;
	}

	public static inline function ellipse(surface:Bitmap, cx:Float, cy:Float, rx:Float, ry:Float, strokeIndex:Int, ?fillIndex:Int, ?transparency:Bool = true) {
		return ellipsei(surface, surface.round(cx), surface.round(cy), surface.round(rx), surface.round(ry), strokeIndex, fillIndex, transparency);
	}

	/**
		Draw a Line 

		@param surface
		@param x0 Origin X
		@param y0 Origin Y
		@param x1 Destination X
		@param y1 Destination Y
		@param colorIndex
	 */
	public static function linei(surface:Bitmap, x0:Int, y0:Int, x1:Int, y1:Int, colorIndex:Int) {
		final dx:Int = surface.round(abs(x1 - x0));
		final dy:Int = surface.round(abs(y1 - y0));

		if (dx == 0 && dy == 0)
			return surface;

		var x:Int = x0;
		var y:Int = y0;

		var ox:Int = x1 > x0 ? 1 : -1;
		var oy:Int = y1 > y0 ? 1 : -1;

		var error:Float = 0;

		do {
			surface.set(x, y, colorIndex, false);

			if (dx > dy) {
				x += ox;
				error += dy / dx;

				if (error > 0.5) {
					y += oy;
					error -= 1;
				}
			} else {
				y += oy;
				error += dx / dy;

				if (error > 0.5) {
					x += ox;
					error -= 1;
				}
			}
		} while (!(x == x1 && y == y1));

		return surface;
	}

	/**
		Draw a Line 

		@param surface
		@param x0 Origin X
		@param y0 Origin Y
		@param x1 Destination X
		@param y1 Destination Y
		@param colorIndex
	 */
	public static inline function line(surface:Bitmap, x0:Float, y0:Float, x1:Float, y1:Float, colorIndex:Int) {
		return linei(surface, surface.round(x0), surface.round(y0), surface.round(x1), surface.round(y1), colorIndex);
	}

	/**
		Draw a Rectangle

		@param surface
		@param x X screen coordinate
		@param y Y screen coordinate
		@param w Width
		@param h Height
		@param strokeIndex Stroke color index 
		@param fillIndex Fill color index
	 */
	public static function recti(surface:Bitmap, x:Int, y:Int, w:Int, h:Int, strokeIndex:Int, ?fillIndex:Int, ?transparency:Bool = true) {
		if (fillIndex == null)
			fillIndex = strokeIndex;

		final fx = min(x, x + w);
		final fy = min(y, y + h);

		final tx = max(x, x + w);
		final ty = max(y, y + h);

		if (tx - fx > 0 && ty - fy > 0) {
			for (line in fy...ty) {
				for (col in fx...tx) {
					if (line == fy || line == ty - 1 || col == fx || col == tx - 1)
						surface.set(col, line, strokeIndex, transparency);
					else if (fillIndex != null)
						surface.set(col, line, fillIndex, transparency);
				}
			}
		}

		return surface;
	}

	/**
		Draw a Rectangle

		@param surface
		@param x X screen coordinate
		@param y Y screen coordinate
		@param w Width
		@param h Height
		@param strokeIndex Stroke color index 
		@param fillIndex Fill color index
	 */
	public static inline function rect(surface:Bitmap, x:Float, y:Float, w:Float, h:Float, strokeIndex:Int, ?fillIndex:Int, ?transparency:Bool = true) {
		return recti(surface, surface.round(x), surface.round(y), surface.round(w), surface.round(h), strokeIndex, fillIndex, transparency);
	}

	public static inline function rect_v(surface:Bitmap, v:Vec, w:Float, h:Float, strokeIndex:Int, ?fillIndex:Int, ?transparency:Bool = true) {
		return rect(surface, v.x, v.y, w, h, strokeIndex, fillIndex, transparency);
	}

	public static inline function rect_c(surface:Bitmap, x:Float, y:Float, w:Float, h:Float, strokeIndex:Int, ?fillIndex:Int, ?transparency:Bool = true) {
		return rect(surface, x - w / 2, y - h / 2, w, h, strokeIndex, fillIndex, transparency);
	}

	public static inline function rect_cv(surface:Bitmap, v:Vec, w:Float, h:Float, strokeIndex:Int, ?fillIndex:Int, ?transparency:Bool = true) {
		return rect(surface, v.x - w / 2, v.y - h / 2, w, h, strokeIndex, fillIndex, transparency);
	}

	public static inline function rect_r(surface:Bitmap, rect:Rect, strokeIndex:Int, ?fillIndex:Int, ?transparency:Bool = true) {
		return Paint.rect(surface, rect.x, rect.y, rect.width, rect.height, strokeIndex, fillIndex, transparency);
	}

	/**
		Draw a shape

		@param surface
		@param shape
		@param colorIndex
		@param fillIndex
	 */
	public static function shape(surface:Bitmap, shape:Shape, strokeIndex:Int, ?fillIndex:Int) {
		switch (shape) {
			case CIRCLE(cx, cy, r):
				circle(surface, cx, cy, r, strokeIndex, fillIndex);
			case RECT(cx, cy, w, h):
				rect(surface, cx - w / 2, cy - h / 2, w, h, strokeIndex, fillIndex);
		}

		return surface;
	}
}
