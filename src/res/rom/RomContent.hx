package res.rom;

import haxe.io.Bytes;
import res.Sprite;
import res.Tilemap;
import res.Tileset;
import res.audio.AudioData;
import res.Font;

typedef RomContent = {
	?audio:Map<String, AudioData>,
	?tilesets:Map<String, Tileset>,
	?tilemaps:Map<String, Tilemap>,
	?sprites:Map<String, Sprite>,
	?fonts:Map<String, Font>,
	?data:Map<String, Bytes>
};
