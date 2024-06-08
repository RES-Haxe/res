package res;

import haxe.io.Bytes;
import res.Font;
import res.Sprite;
import res.Tilemap;
import res.Tileset;
import res.audio.AudioData;

typedef RomContent = {
	?audio:Map<String, AudioData>,
	?tilesets:Map<String, Tileset>,
	?tilemaps:Map<String, Tilemap<Any>>,
	?sprites:Map<String, Sprite>,
	?fonts:Map<String, Font>,
	?data:Map<String, Bytes>
};

/**
	Where all the data is
**/
class Rom {
	public final palette:Palette;
	public final audio:Map<String, AudioData>;
	public final data:Map<String, Bytes>;
	public final fonts:Map<String, Font>;
	public final sprites:Map<String, Sprite>;
	public final tilemaps:Map<String, Tilemap<Any>>;
	public final tilesets:Map<String, Tileset>;

	public function new(palette:Palette, content:RomContent) {
		this.palette = palette;
		this.audio = content.audio ?? [];
		this.tilesets = content.tilesets ?? [];
		this.tilemaps = content.tilemaps ?? [];
		this.sprites = content.sprites ?? [];
		this.fonts = content.fonts ?? [];
		this.data = content.data ?? [];
	}
}
