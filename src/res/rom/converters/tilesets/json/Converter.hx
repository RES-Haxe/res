package res.rom.converters.tilesets.json;

import haxe.Json;
import haxe.io.Path;
import sys.io.File;

class Converter extends res.rom.converters.Converter {
	var chunk:TilesetChunk;

	override function process(fileName:String, palette:Palette):res.rom.converters.Converter {
		final json:{tileWidth:Int, tileHeight:Int} = Json.parse(File.getContent(fileName));

		final bmpFileName = Path.withExtension(Path.withoutExtension(fileName), 'png');

		chunk = res.rom.converters.tilesets.png.Converter.createChunk(bmpFileName, makeName(fileName), json.tileWidth, json.tileHeight, palette);

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [chunk];
	}
}
