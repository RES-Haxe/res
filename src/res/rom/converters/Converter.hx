package res.rom.converters;

import haxe.io.Path;
import haxe.io.Bytes;

class Converter {
	public function new() {}

	inline function getName(fileName:String) {
		return Path.withoutExtension(fileName);
	}

	public function process(fileName:String):Converter {
		return this;
	}

	public function getChunks():Array<RomChunk> {
		return [];
	}
}
