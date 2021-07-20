package res.graphics;

import haxe.io.Bytes;

class Graphics implements Renderable {
	public final width:Int;
	public final height:Int;
	public final indecies:Array<Int>;

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

	public function drawRect(x:Int, y:Int, width:Int, height:Int, index:Int) {
		for (line in y...y + height) {
			if (y < this.height) {
				final len = x + width >= this.width ? this.width - x : width;
				buffer.fill(line * this.width + x, len, index);
			} else
				break;
		}
	}

	public function setPixel(x:Int, y:Int, index:Int = 1) {
		buffer.set(y * width + x, index);
	}

	public function render(frameBuffer:FrameBuffer) {
		for (y in 0...height) {
			for (x in 0...width) {
				final px = buffer.get(y * width + x);
				if (px != 0) {
					frameBuffer.setIndex(x, y, indecies[px - 1]);
				}
			}
		}
	}
}
