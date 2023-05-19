package res.audio;

import haxe.io.Bytes;
import haxe.io.BytesInput;

class AudioData {
	/** Number of channels */
	public final channels:Int;

	/** Sample rate */
	public final rate:Int;

	/** Bits per sample */
	public final bps:BPS;

	/** Number of frames */
	public final length:Int;

	public final data:Bytes;

	private final _bytesPerSample:Int;

	private final _input:BytesInput;

	public function new(channels:Int, rate:Int, bps:BPS, data:Bytes) {
		this.channels = channels;
		this.rate = rate;
		this.bps = bps;
		this.data = data;

		_bytesPerSample = Std.int(cast(bps, Int) / 8);

		this.length = Std.int(data.length / channels / _bytesPerSample);

		_input = new BytesInput(data);
	}

	/**
		Get signed integer value of a sample

		@param channel Number of the channel
		@param num Number of the sample
	 */
	public function getSampleInt(channel:Int, num:Int):Int {
		final pos:Int = num * (_bytesPerSample * channels)
			+ _bytesPerSample * channel;

		_input.position = pos;

		return switch (bps) {
			case BPS8:
				_input.readInt8();
			case BPS16:
				_input.readInt16();
			case BPS24:
				_input.readInt24();
			case BPS32:
				_input.readInt32();
			case _:
				0;
		};
	}

	/**
		Get Float value of a sample [-1; 1]

		@param channel Number of the channel
		@param num Number of the sample
	 */
	public function getSampleFloat(channel:Int, num:Int):Float {
		final intSample = getSampleInt(channel, num);

		return switch (bps) {
			case BPS8:
				intSample / 128;
			case BPS16:
				intSample / 32768;
			case BPS24:
				intSample / 8388608;
			case BPS32:
				intSample / 2147483648;
			case _:
				0;
		};
	}

	public function iterator():AudioDataStream {
		return new AudioDataStream(this);
	}
}
