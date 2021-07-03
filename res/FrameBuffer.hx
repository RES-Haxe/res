package res;

import haxe.io.Bytes;
#if js
import js.html.ImageData;
#end

class FrameBuffer {
	public final indexBuffer:Bytes;
	public final pixelsBuffer:Bytes;
	public final pixelByteSize:Int;
	public final frameWidth:Int;
	public final frameHeight:Int;
	public final pixelFormat:PixelFormat;

	#if js
	public final imageData:ImageData;
	#end

	var palette:Palette;

	public function new(palette:Palette, frameWidth:Int, frameHeight:Int, pixelFormat:PixelFormat) {
		this.palette = palette;

		this.frameWidth = frameWidth;
		this.frameHeight = frameHeight;

		this.pixelFormat = pixelFormat;

		pixelByteSize = switch (pixelFormat) {
			case ARGB | RGBA: 4;
			case RGB: 3;
		};

		indexBuffer = Bytes.alloc(frameWidth * frameHeight);
		pixelsBuffer = Bytes.alloc(frameWidth * frameHeight * pixelByteSize);

		#if js
		imageData = new ImageData(frameWidth, frameHeight);
		#end
	}

	#if js
	public function getImageData():ImageData {
		for (n in 0...indexBuffer.length) {
			var col = palette.get(indexBuffer.get(n));

			imageData.data[n * 4] = col.r;
			imageData.data[n * 4 + 1] = col.g;
			imageData.data[n * 4 + 2] = col.b;
			imageData.data[n * 4 + 3] = col.a;
		}

		return imageData;
	}
	#end

	public function getFrame():Bytes {
		for (n in 0...indexBuffer.length) {
			pixelsBuffer.setInt32(n * pixelByteSize, palette.get(indexBuffer.get(n)).format(pixelFormat));
		}

		return pixelsBuffer;
	}

	public function fill(index:Int) {
		for (fx in 0...frameWidth)
			for (fy in 0...frameHeight)
				setIndex(fx, fy, index);
	}

	public inline function setIndex(atx:Int, aty:Int, index:Int) {
		final pos = aty * frameWidth + atx;
		indexBuffer.set(pos, index);
	}
}
