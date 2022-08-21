package res.audio;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import res.audio.osc.Oscillator;
import res.tools.MathTools.lerp;
import res.tools.MathTools.sum;

using res.tools.ReflectTools;

typedef PCMParams = {
	?channels:Int,
	?oscillator:Oscillator,
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
	?freq:Float,
	?sweep:Float
};

/**
	Sound effect generator
 */
class Sfx {
	var pcm:PCMParams;
	var params:SfxParams;

	public var totalTime(get, never):Int;

	function get_totalTime() {
		return Std.int(sum([params.attack, params.decay + params.sustainTime + params.release]));
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

		pcm.oscillator.reset();
		pcm.oscillator.frequency = params.freq;

		/**
			Get current oscilator amplitude quantized
		 */
		inline function amp(vol:Float = 1):Int
			return Tools.quantize(pcm.oscillator.amplitude * vol, pcm.bps);

		final wr:Int->Void = switch (pcm.bps) {
			case 8: (s) -> bo.writeInt8(s);
			case 16: (s) -> bo.writeInt16(s);
			case 32: (s) -> bo.writeInt32(s);
			case _: (s) -> null;
		};

		final chunks:Array<{nSamples:Int, volStart:Float, volEnd:Float}> = [
			{nSamples: samplesPerTime(params.attack), volStart: 0, volEnd: 1},
			{nSamples: samplesPerTime(params.decay), volStart: 1, volEnd: params.sustain},
			{nSamples: samplesPerTime(params.sustainTime), volStart: params.sustain, volEnd: params.sustain},
			{nSamples: samplesPerTime(params.release), volStart: params.sustain, volEnd: 0},
		];

		for (chunk in chunks) {
			for (s in 0...chunk.nSamples) {
				final vol = lerp(chunk.volStart, chunk.volEnd, s / chunk.nSamples);
				wr(amp(vol));

				final msAdvance = 1000 / pcm.sampleRate;

				pcm.oscillator.frequency += params.sweep * (1 / pcm.sampleRate);

				pcm.oscillator.advance(msAdvance);
			}
		}

		return bo.getBytes();
	}

	public function set(params:SfxParams) {
		this.params.setValues(params);
		return this;
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
			oscillator: Oscillator.triangle(),
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
			freq: Note.G3,
			sweep: 0
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

		if (pcm != null)
			pcmParams.setValues(pcm);

		if (params != null)
			createParams.setValues(params);

		return new Sfx(pcmParams, createParams);
	}

	private function new(pcm:PCMParams, params:SfxParams) {
		if ([8, 16, 32].indexOf(pcm.bps) == -1)
			throw 'Unsupported bit depth: ${pcm.bps}';

		this.pcm = pcm;
		this.params = params;
	}
}
