package res.rom.converters.fonts.fnt;

import Std.parseInt;
import haxe.io.BytesOutput;
import haxe.io.Path;
import res.rom.FontChunk.FontType;
import res.Font.Char;
import sys.io.File;

using StringTools;

typedef FNTTag = {
	name:String,
	params:Map<String, String>
};

/**
	@see https://www.angelcode.com/products/bmfont/doc/file_format.html
 */
class Converter extends res.rom.converters.Converter {
	var spriteChunk:SpriteChunk;
	var fontChunk:FontChunk;

	function parseString(str:String):FNTTag {
		// TODO: Take into account situation when there is a space in quotes
		final parts = str.split(' ').filter(s -> s != '').map(s -> s.trim());

		final name = parts.shift();

		final params:Map<String, String> = [];

		for (param in parts) {
			final p = param.split('=');

			params[p[0]] = p[1].replace('"', '');
		}

		return {
			name: name,
			params: params
		};
	}

	override function process(fileName:String, palette:Palette):res.rom.converters.Converter {
		final tags = File.getContent(fileName).split('\n').map(l -> parseString(l));
		final dir = Path.directory(fileName);
		final name = makeName(fileName);
		final chars:Array<{id:Int, char:Char}> = [];

		final bytesOutput = new BytesOutput();

		var lineHeight:Int;
		var base:Int;

		for (tag in tags) {
			switch tag.name {
				case 'char':
					chars.push({
						id: parseInt(tag.params['id']),
						char: {
							x: parseInt(tag.params['x']),
							y: parseInt(tag.params['y']),
							xoffset: parseInt(tag.params['xoffset']),
							yoffset: parseInt(tag.params['yoffset']),
							xadvance: parseInt(tag.params['xadvance']),
							width: parseInt(tag.params['width']),
							height: parseInt(tag.params['height']),
						}
					});
				case 'chars':
				case 'common':
					lineHeight = parseInt(tag.params['lineHeight']);
					base = parseInt(tag.params['base']);
				case 'info':
				case 'page':
					final bitmapFile = Path.join([dir, tag.params['file']]);
					spriteChunk = res.rom.converters.sprites.png.Converter.createChunk('font:$name', File.getBytes(bitmapFile), palette);
			}
		}

		bytesOutput.writeByte(FontType.VARIABLE);

		bytesOutput.writeByte(base);
		bytesOutput.writeByte(lineHeight);

		bytesOutput.writeUInt16(chars.length);

		for (char in chars) {
			bytesOutput.writeUInt16(char.id);
			bytesOutput.writeUInt16(char.char.x);
			bytesOutput.writeUInt16(char.char.y);
			bytesOutput.writeInt8(char.char.xoffset);
			bytesOutput.writeInt8(char.char.yoffset);
			bytesOutput.writeByte(char.char.xadvance);
			bytesOutput.writeByte(char.char.width);
			bytesOutput.writeByte(char.char.height);
		}

		fontChunk = new FontChunk(name, bytesOutput.getBytes());

		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [spriteChunk, fontChunk];
	}
}
