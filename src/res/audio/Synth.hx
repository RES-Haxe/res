package res.audio;

import haxe.io.BytesOutput;
import res.audio.osc.Oscillator;
import res.tools.MathTools.*;

enum EEnvelope {
	ATTACK;
	SUSTAIN;
	DECAY;
}

class Synth {
	static final envelopeChain:Map<EEnvelope, EEnvelope> = [
		ATTACK => SUSTAIN,
		SUSTAIN => DECAY,
		DECAY => null
	];

	var _envPhaseTime:Map<EEnvelope, Float> = [];

	var _amp:Float = 0;

	/** Oscillator **/
	public var osc:Oscillator;

	/** Synth start frequency **/
	public var frequency:Float;

	/** Frequency sweep (octaves per second) **/
	public var frequencySweep:Float;

	/** Min. frequency cutoff **/
	public var frequencyCutoff:Float;

	/** Attack time (ms) **/
	public var attack(get, set):Float;

	function set_attack(val:Float)
		return _envPhaseTime[ATTACK] = val;

	function get_attack()
		return _envPhaseTime[ATTACK];

	/** Decay (ms) **/
	public var decay(get, set):Float;

	function set_decay(val:Float)
		return _envPhaseTime[DECAY] = val;

	function get_decay()
		return _envPhaseTime[DECAY];

	/** Sustain volume (0...1) **/
	public var susVolume:Float;

	/** Sustain time (ms) **/
	public var susTime(get, set):Float;

	function set_susTime(val:Float)
		return _envPhaseTime[SUSTAIN] = val;

	function get_susTime()
		return _envPhaseTime[SUSTAIN];

	/** Current envelope phase **/
	private var envelopePhase:EEnvelope = ATTACK;

	/** Time of the current envelope phase **/
	private var envelopeTime:Float = 0;

	/** Total passed time **/
	private var totalTime:Float = 0;

	/**
		@param osc Oscillator to synth the sound
	**/
	public function new(osc:Oscillator, params:{
		?frequency:Float,
		?frequencySweep:Float,
		?frequencyCutoff:Float,
		?attack:Float,
		?decay:Float,
		?susVolume:Float,
		?susTime:Float
	}) {
		this.osc = osc;

		this.osc.frequency = frequency = params.frequency ?? Note.G3;
		frequencySweep = params.frequencySweep ?? 0.0;
		frequencyCutoff = params.frequencyCutoff ?? 20.0;
		attack = params.attack ?? 0.0;
		decay = params.decay ?? 100.0;
		susVolume = params.susVolume ?? 0.8;
		susTime = params.susTime ?? 500.0;
	}

	/**
		Get the current amplitude (-1...1)
	**/
	public function amp():Float
		return _amp;

	/**
		Advance time by amount of milliseconds

		@param ms the amount of milliseconds to advance

		@returns the amplitued after advancing the time
	 */
	public function advance(ms:Float):Null<Float> {
		totalTime += ms;
		envelopeTime += ms;

		if (envelopeTime > _envPhaseTime[envelopePhase]) {
			envelopeTime -= _envPhaseTime[envelopePhase];
			envelopePhase = envelopeChain[envelopePhase];
		}

		if (envelopePhase == null)
			return null; // Finished

		final t = param(0, _envPhaseTime[envelopePhase], envelopeTime);

		final volume = switch (envelopePhase) {
			case ATTACK:
				lerp(0, susVolume, t);
			case SUSTAIN:
				susVolume;
			case DECAY:
				lerp(susVolume, 0, t);
		}

		if (frequencySweep != 0) {
			osc.frequency *= Math.pow(2, frequencySweep * (ms / 1000));

			if (osc.frequency < frequencyCutoff)
				return null;
		}

		final osc_amp = osc.advance(ms);

		return _amp = osc_amp * volume;
	}

	public function audioData(sampleRate:Int, bps:BPS):AudioData
		return new AudioData(1, sampleRate, bps, PCM(sampleRate, bps));

	public function buffer(sampleRate:Int = 22500, bps:BPS = BPS8, res:RES)
		return res.bios.createAudioBuffer(audioData(sampleRate,
			bps).iterator());

	public function PCM(sampleRate:Int, bps:BPS) {
		final adv = 1000 / sampleRate;
		final bo = new BytesOutput();

		while (true) {
			final a = amp();

			final sample = Tools.quantize(a, bps);

			switch bps {
				case BPS8:
					bo.writeInt8(sample);
				case BPS16:
					bo.writeInt16(sample);
				case BPS24:
					bo.writeInt24(sample);
				case BPS32:
					bo.writeInt32(sample);
			}

			if (advance(adv) == null)
				break;
		}

		return bo.getBytes();
	}

	public function reset() {
		osc.frequency = frequency;
		osc.reset();
		totalTime = 0;
		envelopeTime = 0;
		envelopePhase = ATTACK;
	}
}
