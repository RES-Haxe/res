package res.graphics;

import Math.*;
import res.collisions.Shape;
import res.geom.Rect;
import res.tools.MathTools.*;

using Std;

/**
	Can be used as a static extension for IFrameBuffer

	e.g.:

	```haxe
	using res.graphics.Painter;

	// ...

	function render(frameBuffer:IFrameBuffer) {
		frameBuffer.line(0, 0, 100, 100, 5);
	}

	```
 */
class Painter {
	/**
		Draw a circle

		Midpoint circle algorithm

		@param frameBuffer
		@param cx Center x
		@param cy Center y
		@param r radius
		@param colorIndex Color index
	 */
	public static function circle(frameBuffer:IFrameBuffer, cx:Int, cy:Int, r:Int, colorIndex:Int) {
		final plot = (dx:Int, dy:Int) -> {
			for (p in [
				[cx + dx, cy + dy],
				[cx - dx, cy + dy],
				[cx + dx, cy - dy],
				[cx - dx, cy - dy],
				[cx + dy, cy + dx],
				[cx - dy, cy + dx],
				[cx + dy, cy - dx],
				[cx - dy, cy - dx]
			]) {
				frameBuffer.setIndex(p[0], p[1], colorIndex);
			}
		};

		var x = 0;
		var y = r;
		var d = 3 - 2 * r;

		plot(x, y);

		while (y >= x) {
			x++;

			if (d > 0) {
				y--;
				d = d + 4 * (x - y) + 10;
			} else {
				d = d + 4 * x + 6;
			}

			plot(x, y);
		}
	}

	/**
		Draw a Line 

		@param frameBuffer
		@param x0 Origin X
		@param y0 Origin Y
		@param x1 Destination X
		@param y1 Destination Y
		@param colorIndex
	 */
	public static function line(frameBuffer:IFrameBuffer, x0:Int, y0:Int, x1:Int, y1:Int, colorIndex:Int) {
		final dx:Int = abs(x1 - x0).int();
		final dy:Int = abs(y1 - y0).int();

		if (dx == 0 && dy == 0)
			return;

		var x:Int = x0;
		var y:Int = y0;

		var ox:Int = x1 > x0 ? 1 : -1;
		var oy:Int = y1 > y0 ? 1 : -1;

		var error:Float = 0;

		do {
			frameBuffer.setIndex(x, y, colorIndex);

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
	}

	/**
		Draw a Rectangle

		@param frameBuffer
		@param x X screen coordinate
		@param y Y screen coordinate
		@param w Width
		@param h Height
		@param colorIndex Index of the color to fill the rectangle
	 */
	public static function rect(frameBuffer:IFrameBuffer, x:Int, y:Int, w:Int, h:Int, colorIndex:Int) {
		if (Rect.intersect(0, 0, frameBuffer.frameWidth, frameBuffer.frameHeight, x, y, w, h)) {
			final fx = mini(x, x + w);
			final fy = mini(y, y + h);

			final tx = maxi(x, x + w) + 1;
			final ty = maxi(y, y + h) + 1;

			if (tx - fx > 0 && ty - fy > 0) {
				for (line in fy...ty) {
					if (line == fy || line == ty - 1) {
						for (col in fx...tx) {
							frameBuffer.setIndex(col, line, colorIndex);
						}
					} else {
						frameBuffer.setIndex(fx, line, colorIndex);
						frameBuffer.setIndex(tx - 1, line, colorIndex);
					}
				}
			}
		}
	}

	/**
		Draw a shape

		@param frameBuffer
		@param shape
		@param colorIndex
	 */
	public static function shape(frameBuffer:IFrameBuffer, shape:Shape, colorIndex:Int) {
		switch (shape) {
			case CIRCLE(cx, cy, r):
				circle(frameBuffer, cx.int(), cy.int(), r.int(), colorIndex);
			case RECT(cx, cy, w, h):
				rect(frameBuffer, (cx - w / 2).int(), (cy - h / 2).int(), w.int(), h.int(), colorIndex);
		}
	}
}
