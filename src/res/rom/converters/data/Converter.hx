package res.rom.converters.data;

import sys.io.File;

class Converter extends res.rom.converters.Converter {
	var chunk:DataChunk;

	override function process(fileName:String, palette:Palette) {
		chunk = new DataChunk(makeName(fileName), File.getBytes(fileName));
		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [chunk];
	}
}
