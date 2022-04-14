package res.audio.osc;

class Square extends Oscillator {
	override function get_amplitude():Float
		return period() < 0.5 ? -1 : 1;

	@:allow(res.audio.osc)
	private function new() {}
}
