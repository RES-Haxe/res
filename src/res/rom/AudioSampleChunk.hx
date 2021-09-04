package res.rom;

import format.wav.Reader;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import res.audio.AudioSample;

class AudioSampleChunk extends RomChunk {
	public function new(name, data) {
		super(AUDIO_SAMPLE, name, data);
	}

	public function getAudioSample():AudioSample {
		final input = new BytesInput(data);

		final channels = input.readByte();
		final rate = input.readUInt24();
		final bps = input.readByte();
		final dataLen = input.readUInt24();
		final data = Bytes.alloc(dataLen);
		input.readBytes(data, 0, dataLen);

		return new AudioSample(channels, rate, bps, data);
	}

	public static function fromWav(wavData:Bytes, name:String):AudioSampleChunk {
		final input = new BytesInput(wavData);
		final wavReader = new Reader(input);
		final wave = wavReader.read();

		final output = new BytesOutput();

		switch (wave.header.bitsPerSample) {
			case 8, 16, 24, 32:
			default:
				throw 'Unsupported bits per sample: ${wave.header.bitsPerSample}';
		}

		output.writeByte(wave.header.channels);
		output.writeUInt24(wave.header.samplingRate);
		output.writeByte(wave.header.bitsPerSample);

		final numChannels:Int = wave.header.channels;
		final numBytesPerSample:Int = Std.int(wave.header.bitsPerSample / 8);
		final numFrames:Int = Std.int(wave.data.length / numBytesPerSample / numChannels);

		final wavInput = new BytesInput(wave.data);
		final wavOutput = new BytesOutput();

		for (_ in 0...numFrames) {
			for (_ in 0...numChannels) {
				switch (wave.header.bitsPerSample) {
					case 8:
						wavOutput.writeInt8(wavInput.readByte() - 128); // convert from unsigned to signed
					case 16:
						wavOutput.writeInt16(wavInput.readInt16());
					case 24:
						wavOutput.writeInt24(wavInput.readInt24());
					case 32:
						wavOutput.writeInt32(wavInput.readInt32());
					case _:
						throw 'Huh?';
				}
			}
		}

		final convertedData = wavOutput.getBytes();

		// Data length
		output.writeUInt24(convertedData.length);

		// Data
		output.writeBytes(convertedData, 0, convertedData.length);

		return new AudioSampleChunk(name, output.getBytes());
	}
}
