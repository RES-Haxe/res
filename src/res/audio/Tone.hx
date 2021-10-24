package res.audio;

import res.tools.MathTools.clampf;
import res.tools.MathTools.wrapi;

class Tone implements IAudioStream {
	public var numChannels:Int;
	public var sampleRate:Int;
	public var numSamples:Int;

	var sample:Int = 0;
	var volume:Float;
	var samplesPerCycle:Int;
	var func:WaveFunc;

	public function new(waveFunc:WaveFunc, frequency:Float, length:Float = 1, volume:Float = 1, channels:Int = 1, sampleRate:Int = 22050) {
		this.sampleRate = sampleRate;
		this.volume = clampf(volume, -1, 1);
		this.numSamples = Std.int(sampleRate * length);
		this.numChannels = channels;

		func = waveFunc;

		samplesPerCycle = Std.int(sampleRate / frequency);
	}

	public function hasNext():Bool {
		return sample < numSamples;
	}

	public function next():{key:Int, value:Array<Float>} {
		final period:Float = wrapi(sample, samplesPerCycle) / samplesPerCycle;
		final amp = func(period) * volume;

		return {
			key: sample++,
			value: [for (_ in 0...numChannels) amp]
		};
	}
}
