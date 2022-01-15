package res.rom.converters.audio.wav;

import format.wav.Reader;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import sys.io.File;

using haxe.io.Path;

class Converter extends res.rom.converters.Converter {
	var audioChunk:AudioChunk;

	override function process(fileName:String, palette:Palette):res.rom.converters.Converter {
		final fileBytes = File.getBytes(fileName);

		final name = fileName.withoutDirectory().withoutExtension();

		final input = new BytesInput(fileBytes);
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

		audioChunk = new AudioChunk(name, output.getBytes());

		return super.process(fileName, palette);
	}

	override function getChunks():Array<RomChunk> {
		return [audioChunk];
	}
}
