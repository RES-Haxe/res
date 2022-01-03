package res.rom.converters;

using haxe.io.Path;

class Converter {
	public function new() {}

	function makeName(fileName:String) {
		return fileName.withoutDirectory().withoutExtension();
	}

	public function process(fileName:String, palette:Palette):Converter {
		return this;
	}

	public function getChunks():Array<RomChunk> {
		return [];
	}
}
