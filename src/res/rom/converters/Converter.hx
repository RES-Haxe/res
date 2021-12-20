package res.rom.converters;

import haxe.io.Path;
import haxe.io.Bytes;

class Converter {
	public function new() {}

	public function process(fileName:String, palette:Palette):Converter {
		return this;
	}

	public function getChunks():Array<RomChunk> {
		return [];
	}
}
