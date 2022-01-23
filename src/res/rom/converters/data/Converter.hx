package res.rom.converters.data;

import haxe.io.Path;
import sys.io.File;

class Converter extends res.rom.converters.Converter {
	var chunk:DataChunk;

	override function process(fileName:String, palette:Palette) {
		chunk = new DataChunk(Path.withoutDirectory(fileName), File.getBytes(fileName));
		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [chunk];
	}
}
