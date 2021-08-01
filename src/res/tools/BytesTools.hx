package res.tools;

import haxe.io.Bytes;

class BytesTools {
	public static inline function getxy(bytes:Bytes, width:Int, x:Int, y:Int):Int {
		return bytes.get(y * width + x);
	}

	public static inline function setxy(bytes:Bytes, width:Int, x:Int, y:Int, val:Int) {
		bytes.set(y * width + x, val);
	}
}
