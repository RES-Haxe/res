package res.audio;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import res.audio.WaveFunc.sawtooth;
import res.tools.MathTools.lerp;
import res.tools.MathTools.sum;
import res.tools.MathTools.wrap;

typedef PCMParams = {
	?channels:Int,
	?wave:WaveFunc,
	?bps:Int,
	?sampleRate:Int
};

typedef SfxParams = {
	/** Envelope */
	?attack:Int,
	?decay:Int,
	?sustain:Float,
	?release:Int,
	?sustainTime:Int,
	/** frequency **/
	?freqStart:Float,
};

/**
	Sound effect generator
 */
class Sfx {
	var pcm:PCMParams;
	var params:SfxParams;

	public var totalTime(get, never):Int;

	function get_totalTime() {
		return Std.int(sum(params.attack, params.decay + params.sustainTime + params.release));
	}

	public var totalSamples(get, never):Int;

	function get_totalSamples() {
		return samplesPerTime(totalTime);
	}

	function samplesPerTime(ms:Int):Int {
		return Math.floor(pcm.sampleRate * (ms / 1000));
	}

	function createPCM():Bytes {
		final bo = new BytesOutput();

		final samplesPerCycle = Std.int(pcm.sampleRate / params.freqStart);

		var sample:Int = 0;

		function amp(vol:Float = 1):Int {
			return Tools.quantize(((pcm.wave(wrap(sample, samplesPerCycle) / samplesPerCycle)) * vol), pcm.bps);
		}

		final wr:Int->Void = switch (pcm.bps) {
			case 8: (s) -> bo.writeInt8(s);
			case 16: (s) -> bo.writeInt16(s);
			case 32: (s) -> bo.writeInt32(s);
			case _: (s) -> null;
		};

		final attackSamples = samplesPerTime(params.attack);

		for (a in 0...attackSamples) {
			final vol = a / attackSamples;
			wr(amp(vol));
			sample++;
		}

		final decaySamples = samplesPerTime(params.decay);

		for (a in 0...decaySamples) {
			final vol = lerp(1, params.sustain, a / decaySamples);
			wr(amp(vol));
			sample++;
		}

		final sustainSamples = samplesPerTime(params.sustainTime);

		for (_ in 0...sustainSamples) {
			wr(amp(params.sustain));
			sample++;
		}

		final releaseSamples = samplesPerTime(params.release);

		for (a in 0...releaseSamples) {
			final vol = lerp(params.sustain, 0, a / releaseSamples);
			wr(amp(vol));
			sample++;
		}

		return bo.getBytes();
	}

	/**
		Generate `AudioData`
	 */
	public function data():AudioData {
		return new AudioData(pcm.channels, pcm.sampleRate, pcm.bps, createPCM());
	}

	static function defaultPCM():PCMParams {
		return {
			channels: 1,
			wave: sawtooth,
			sampleRate: 22050,
			bps: 16
		};
	}

	static function defaultParams():SfxParams {
		return {
			attack: 200,
			decay: 100,
			sustain: 0.8,
			sustainTime: 500,
			release: 1000,
			freqStart: Note.G3
		};
	}

	/**
		Create a new sound effect generator

		@param pcm PCM parameters
		@param params Sound effect params
	 */
	public static function create(?pcm:PCMParams, ?params:SfxParams) {
		final pcmParams = defaultPCM();
		final createParams = defaultParams();

		if (pcm != null) {
			for (f in Reflect.fields(pcm)) {
				Reflect.setField(pcmParams, f, Reflect.field(pcm, f));
			}
		}

		if (params != null) {
			for (f in Reflect.fields(params)) {
				Reflect.setField(createParams, f, Reflect.field(params, f));
			}
		}

		return new Sfx(pcmParams, createParams);
	}

	private function new(pcm:PCMParams, params:SfxParams) {
		if ([8, 16, 32].indexOf(pcm.bps) == -1)
			throw 'Unsupported bit depth: ${pcm.bps}';

		this.pcm = pcm;
		this.params = params;
	}
}
