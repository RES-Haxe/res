package res.audio;

import res.tools.MathTools.lerp;
import res.tools.MathTools.param;

class Tools {
	public static function quantize(amp:Float, bps:Int):Int {
		final t = param(-1, 1, amp);
		switch (bps) {
			case 8:
				return Std.int(lerp(-128, 127, t));
			case 16:
				return Std.int(lerp(-32768, 32767, t));
			case 32:
				return Std.int(lerp(-2147483648, 2147483647, t));
		}

		throw 'Unknown BPS: $bps';
	}
}
