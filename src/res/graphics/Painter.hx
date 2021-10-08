package res.graphics;

import Math.*;
import res.geom.Rect;
import res.tools.MathTools.maxi;
import res.tools.MathTools.mini;

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
	public static function ellipse(frameBuffer:IFrameBuffer, cx:Int, cy:Int, rx:Int, ry:Int, colorIndex:Int) {
		// TODO
	}

	public static function circle(frameBuffer:IFrameBuffer, cx:Int, cy:Int, r:Int, colorIndex:Int) {
		ellipse(frameBuffer, cx, cy, r, r, colorIndex);
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
			final fx = maxi(0, x);
			final fy = maxi(0, y);

			final tx = mini(frameBuffer.frameWidth - 1, x + w);
			final ty = mini(frameBuffer.frameHeight - 1, y + h);

			if (tx - fx > 0 && ty - fy > 0) {
				for (line in fy...ty + 1) {
					for (col in fx...tx) {
						frameBuffer.setIndex(col, line, colorIndex);
					}
				}
			}
		}
	}
}
