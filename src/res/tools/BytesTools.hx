package res.tools;

import haxe.io.Bytes;

class BytesTools {
	public static inline function getxy(bytes:Bytes, width:Int, x:Int, y:Int):Int {
		return bytes.get(y * width + x);
	}

	public static inline function setxy(bytes:Bytes, width:Int, x:Int, y:Int, val:Int) {
		bytes.set(y * width + x, val);
	}

	/**
		Copy a rectangle (of pixels) from bytes

		@param bytes Source bytes
		@param srcLineWidth The width of the source rectangle
		@param srcX X of the rectangle in the source rect
		@param srcY Y of the rectangle in the source rect
		@param width Width of the resulting rectangle
		@param height Height of the resulting rectangle
	 */
	public static function copyRect(bytes:Bytes, srcLineWidth:Int, srcX:Int, srcY:Int, width:Int, height:Int, pxSize:Int = 1) {
		final result = Bytes.alloc(width * height * pxSize);

		for (line in 0...height) {
			final srcPos = ((srcY + line) * srcLineWidth + srcX) * pxSize;
			final dstPos = line * width * pxSize;

			result.blit(dstPos, bytes, srcPos, width * pxSize);
		}

		return result;
	}
}
