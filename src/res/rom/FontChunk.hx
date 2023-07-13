package res.rom;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import res.display.Sprite;
import res.text.Font;

enum abstract FontType(Int) from Int to Int {
	var VARIABLE = 0;
	var FIXED = 1;
}

class FontChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(FONT, name, data);
	}

	public function getFont(sprite:Sprite):Font {
		final bi = new BytesInput(data);

		final fontType:FontType = bi.readByte();

		switch fontType {
			case VARIABLE:
				final base = bi.readByte();
				final lineHeight = bi.readByte();

				final numChars = bi.readUInt16();

				final chars:Map<Int, Char> = [];

				for (n in 0...numChars) {
					final charId = bi.readUInt16();

					chars[charId] = {
						x: bi.readUInt16(),
						y: bi.readUInt16(),
						xoffset: bi.readInt8(),
						yoffset: bi.readInt8(),
						xadvance: bi.readByte(),
						width: bi.readByte(),
						height: bi.readByte()
					};
				}

				return new Font(sprite, base, lineHeight, chars);
			case FIXED:
				final chars:Map<Int, Char> = [];
				final tileWidth:Int = bi.readByte();
				final tileHeight:Int = bi.readByte();
				final spacing:Int = bi.readByte();
				final utf8Len:Int = bi.readUInt16();
				final charactersBytes = Bytes.alloc(utf8Len);
				bi.readBytes(charactersBytes, 0, utf8Len);
				final characters:String = charactersBytes.toString();

				var nchar:Int = 0;

				for (line in 0...Std.int(sprite.height / tileHeight)) {
					for (col in 0...Std.int(sprite.width / tileWidth)) {
						final charCode:Int = characters.charCodeAt(nchar);

						chars[charCode] = {
							x: col * tileWidth,
							y: line * tileHeight,
							xoffset: 0,
							yoffset: 0,
							xadvance: tileWidth + spacing,
							width: tileWidth,
							height: tileHeight
						};

						nchar++;
					}
				}

				return new Font(sprite, tileHeight, tileHeight, chars);
		}
	}

	public static function fromBytes(bytes:Bytes, name:String):FontChunk {
		return new FontChunk(name, bytes);
	}
}
