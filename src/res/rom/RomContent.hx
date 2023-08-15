package res.rom;

import haxe.io.Bytes;
import res.text.Font;
import res.Sprite;
import res.tiles.Tilemap;
import res.tiles.Tileset;
import res.audio.AudioData;

typedef RomContent = {
	?audio:Map<String, AudioData>,
	?tilesets:Map<String, Tileset>,
	?tilemaps:Map<String, Tilemap>,
	?sprites:Map<String, Sprite>,
	?fonts:Map<String, Font>,
	?data:Map<String, Bytes>
};
