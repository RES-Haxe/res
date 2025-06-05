package res.algo;

using Std;
using Math;

/**
 * Class representing an iterator for Bresenham's line algorithm.
 */
class BresenhamLineIterator {
	var dx:Int; // Difference in x coordinates
	var dy:Int; // Difference in y coordinates
	var sx:Int; // Step direction in x
	var sy:Int; // Step direction in y
	var err:Int; // Error term

	var x:Int; // Current x position
	var y:Int; // Current y position

	var tx:Int; // Target x position
	var ty:Int; // Target y position

	private var _hasNext:Bool = true; // Flag to indicate if there are more points to iterate

	/**
	 * Constructor to initialize the iterator with start and end points.
	 * @param x1 Starting x coordinate
	 * @param y1 Starting y coordinate
	 * @param x2 Ending x coordinate
	 * @param y2 Ending y coordinate
	 */
	inline public function new(x1:Int, y1:Int, x2:Int, y2:Int) {
		dx = (x2 - x1).abs().int();
		dy = (y2 - y1).abs().int();

		sx = x1 < x2 ? 1 : -1;
		sy = y1 < y2 ? 1 : -1;

		err = dx - dy;

		x = x1;
		y = y1;

		tx = x2;
		ty = y2;
	}

	/**
	 * Get the next point in the line.
	 * @return An object containing the x and y coordinates of the next point.
	 */
	public inline function next():{x:Int, y:Int} {
		final point = {
			x: x,
			y: y
		};

		if (x == tx && y == ty) {
			_hasNext = false;
			return point;
		}

		final e2 = 2 * err;

		if (e2 > -dy) {
			err -= dy;
			x += sx;
		}

		if (e2 < dx) {
			err += dx;
			y += sy;
		}

		return point;
	}

	/**
	 * Check if there are more points to iterate.
	 * @return True if there are more points, false otherwise.
	 */
	public inline function hasNext():Bool {
		return _hasNext;
	}
}

/**
 * Class containing a static method to create a BresenhamLineIterator.
 */
class Bresenham {
	/**
	 * Create a BresenhamLineIterator for the given start and end points.
	 * @param x1 Starting x coordinate
	 * @param y1 Starting y coordinate
	 * @param x2 Ending x coordinate
	 * @param y2 Ending y coordinate
	 * @return A new BresenhamLineIterator instance.
	 */
	public static inline function line(x1:Int, y1:Int, x2:Int, y2:Int) {
		return new BresenhamLineIterator(x1, y1, x2, y2);
	}
}
