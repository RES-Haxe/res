package res.rom;

import haxe.io.Bytes;
import res.text.Font;
import res.tiles.Tileset;

class FontChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(FONT, name, data);
	}

	public function getFont(tileset:Tileset):Font {
		return new Font(name, tileset, data.getString(0, data.length, UTF8));
	}

	public static function fromBytes(bytes:Bytes, name:String):FontChunk {
		return new FontChunk(name, bytes);
	}
}
