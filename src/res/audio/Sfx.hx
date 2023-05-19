package res.audio;

import res.audio.osc.Oscillator;

class Sfx {
	public static function bang(freq:Float = Note.G5, time:Float = 2000)
		return new Synth(Oscillator.noise(), {
			frequency: freq,
			frequencySweep: -10,
			attack: 0,
			susTime: 0,
			decay: time
		});
}
