package res.rom.converters.audio.wav;

import sys.io.File;

using haxe.io.Path;

class Converter extends res.rom.converters.Converter {
	var audioChunk:AudioSampleChunk;

	override function process(fileName:String, palette:Palette):res.rom.converters.Converter {
		final fileBytes = File.getBytes(fileName);

		audioChunk = AudioSampleChunk.fromWav(fileBytes, fileName.withoutDirectory().withoutExtension());

		return super.process(fileName, palette);
	}

	override function getChunks():Array<RomChunk> {
		return [audioChunk];
	}
}
