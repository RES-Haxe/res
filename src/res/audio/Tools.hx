package res.audio;

import res.tools.MathTools.lerp;
import res.tools.MathTools.param;

class Tools {
	public static function quantize(amp:Float, bps:BPS):Int {
		final t = param(-1, 1, amp);

		switch (bps) {
			case BPS8:
				return Std.int(lerp(-128, 127, t));
			case BPS16:
				return Std.int(lerp(-32768, 32767, t));
			case BPS24:
				return Std.int(lerp(-8388608, 8388607, t));
			case BPS32:
				return Std.int(lerp(-2147483648, 2147483647, t));
		}

		throw 'Unknown BPS: $bps';
	}
}
