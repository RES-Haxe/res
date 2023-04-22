package res.display;

import Math.abs;
import res.geom.Rect;
import res.tools.MathTools.*;
import res.types.Shape;

using Std;

/**
	Tool class for drawing shapes on a `Bitmap`

	Can be used as a static extension for `Bitmap`/`FrameBuffer`

	e.g.:

	```haxe
	using res.display.Painter;

	final bitmap:Bitmap = new Bitmap(128, 128);

	// ...

	function render(frameBuffer:FrameBuffer) {

		bitmap.circle(64, 64, 64, 7, 2);

		frameBuffer.line(0, 0, 100, 100, 5);
	}

	```
 */
class Painter {
	/**
		Draw a circle

		@param surface
		@param cx Center x
		@param cy Center y
		@param r radius
		@param strokeIndex Stroke color index
		@param fillIndex Fill color index
	 */
	public static function circle(surface:Bitmap, cx:Int, cy:Int, r:Int, strokeIndex:Int, ?fillIndex:Int)
		return ellipse(surface, cx, cy, r, r, strokeIndex, fillIndex);

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
	public static function ellipse(surface:Bitmap, cx:Int, cy:Int, rx:Int, ry:Int, strokeIndex:Int, ?fillIndex:Int) {
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

		final plot = () -> {
			if (fillIndex != null) {
				final fx = (-x + cx).int();
				final tx = (x + cx).int();

				for (px in fx...tx + 1) {
					final index = px == fx || px == tx ? strokeIndex : fillIndex;

					surface.set(px, (y + cy).int(), index);
					surface.set(px, (-y + cy).int(), index);
				}
			} else {
				surface.set((x + cx).int(), (y + cy).int(), strokeIndex);
				surface.set((-x + cx).int(), (y + cy).int(), strokeIndex);
				surface.set((x + cx).int(), (-y + cy).int(), strokeIndex);
				surface.set((-x + cx).int(), (-y + cy).int(), strokeIndex);
			}
		};

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

	/**
		Draw a Line 

		@param surface
		@param x0 Origin X
		@param y0 Origin Y
		@param x1 Destination X
		@param y1 Destination Y
		@param colorIndex
	 */
	public static function line(surface:Bitmap, x0:Int, y0:Int, x1:Int, y1:Int, colorIndex:Int) {
		final dx:Int = abs(x1 - x0).int();
		final dy:Int = abs(y1 - y0).int();

		if (dx == 0 && dy == 0)
			return surface;

		var x:Int = x0;
		var y:Int = y0;

		var ox:Int = x1 > x0 ? 1 : -1;
		var oy:Int = y1 > y0 ? 1 : -1;

		var error:Float = 0;

		do {
			surface.set(x, y, colorIndex);

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
		Draw a Rectangle

		@param surface
		@param x X screen coordinate
		@param y Y screen coordinate
		@param w Width
		@param h Height
		@param strokeIndex Stroke color index 
		@param fillIndex Fill color index
	 */
	public static function rect(surface:Bitmap, x:Int, y:Int, w:Int, h:Int, strokeIndex:Int, ?fillIndex:Int) {
		if (Rect.intersect(0, 0, surface.width, surface.height, x, y, w, h)) {
			final fx = min(x, x + w);
			final fy = min(y, y + h);

			final tx = max(x, x + w) + 1;
			final ty = max(y, y + h) + 1;

			if (tx - fx > 0 && ty - fy > 0) {
				for (line in fy...ty) {
					for (col in fx...tx) {
						if (line == fy || line == ty - 1 || col == fx || col == tx - 1)
							surface.set(col, line, strokeIndex);
						else if (fillIndex != null)
							surface.set(col, line, fillIndex);
					}
				}
			}
		}

		return surface;
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
				circle(surface, cx.int(), cy.int(), r.int(), strokeIndex, fillIndex);
			case RECT(cx, cy, w, h):
				rect(surface, (cx - w / 2).int(), (cy - h / 2).int(), w.int(), h.int(), strokeIndex, fillIndex);
		}
		return surface;
	}
}
