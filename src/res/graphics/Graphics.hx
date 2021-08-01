package res.graphics;

import haxe.io.Bytes;
import res.geom.Recti;
import res.tools.MathTools.maxi;
import res.tools.MathTools.mini;

using res.tools.BytesTools;

class Graphics extends Renderable {
	public final width:Int;
	public final height:Int;
	public final indecies:Array<Int>;

	public var x:Float = 0;
	public var y:Float = 0;

	var buffer:Bytes;

	public function new(width:Int, height:Int, indecies:Array<Int>) {
		this.width = width;
		this.height = height;
		this.indecies = indecies;

		buffer = Bytes.alloc(width * height);
	}

	public function clear() {
		buffer.fill(0, buffer.length, 0);
	}

	public dynamic function draw(g:Graphics) {}

	public function drawImage(data:Bytes, x:Int, y:Int, width:Int, height:Int) {
		if (data.length != width * height)
			throw 'Invalid data size';

		for (line in 0...height) {
			for (col in 0...width) {
				final srcPos:Int = line * width + col;
				final dstPos:Int = (line + y) * this.width + (col + x);

				buffer.set(dstPos, data.get(srcPos));
			}
		}
	}

	public function drawLine(x0:Int, y0:Int, x1:Int, y1:Int, index:Int) {
		// TODO
	}

	/**
		Draw a rectangle
	 */
	public function drawRect(rx:Int, ry:Int, rwidth:Int, rheight:Int, index:Int) {
		if (Recti.intersect(0, 0, width, height, rx, ry, rwidth, rheight)) {
			final fx = maxi(0, rx);
			final fy = maxi(0, ry);

			final tx = mini(width, rx + rwidth);
			final ty = mini(height, ry + rheight);

			if (tx - fx > 0 && ty - fy > 0) {
				for (line in fy...ty) {
					final len = tx - fx;
					buffer.fill(line * width + fx, len, index);
				}
			}
		}
	}

	public function setPixel(x:Int, y:Int, index:Int = 1) {
		if (x >= 0 && x < width && y >= 0 && y < height)
			buffer.setxy(width, x, y, index);
	}

	override public function render(frameBuffer:FrameBuffer) {
		draw(this);

		for (py in 0...height) {
			for (px in 0...width) {
				final pixel = buffer.get(py * width + px);
				if (pixel != 0) {
					frameBuffer.setIndex(Math.floor(x + px), Math.floor(y + py), indecies[pixel - 1]);
				}
			}
		}
	}
}
