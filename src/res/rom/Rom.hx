package res.rom;

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
import res.audio.AudioData;
import res.display.Sprite;
import res.text.Font;
import res.tiles.Tilemap;
import res.tiles.Tileset;

class Rom {
	public static inline var MAGIC_NUMBER:Int32 = 0x52524f4d; // RROM

	public final palette:Palette;
	public final audio:Map<String, AudioData>;
	public final data:Map<String, Bytes>;
	public final fonts:Map<String, Font>;
	public final sprites:Map<String, Sprite>;
	public final tilemaps:Map<String, Tilemap>;
	public final tilesets:Map<String, Tileset>;

	private function new(palette:Palette, audio:Map<String, AudioData>, tilesets:Map<String, Tileset>, tilemaps:Map<String, Tilemap>,
			sprites:Map<String, Sprite>, fonts:Map<String, Font>, data:Map<String, Bytes>) {
		this.palette = palette;
		this.audio = audio;
		this.tilesets = tilesets;
		this.tilemaps = tilemaps;
		this.sprites = sprites;
		this.fonts = fonts;
		this.data = data;
	}

	/**
		Load rom from bytes

		@param bytes
		@param compressed Whether the data is gzip compressed or not
	 */
	public static function fromBytes(bytes:Bytes, ?compressed:Bool = true):Rom {
		final bytesInput = new BytesInput(compressed ? InflateImpl.run(new BytesInput(bytes)) : bytes);

		if (bytesInput.readInt32() != MAGIC_NUMBER)
			throw 'Invalid magic number';

		// Read number of colors
		final numColors = bytesInput.readByte();
		final palette:Palette = new Palette([for (_ in 0...numColors) Color32.ofRGB8(bytesInput.readUInt24())]);
		final audio:Map<String, AudioData> = [];
		final sprites:Map<String, Sprite> = [];
		final tilesets:Map<String, Tileset> = [];
		final tilemaps:Map<String, Tilemap> = [];
		final fonts:Map<String, Font> = [];
		final data:Map<String, Bytes> = [];

		while (bytesInput.position < bytesInput.length) {
			final chunk = RomChunk.read(bytesInput);

			switch (chunk.chunkType) {
				case AUDIO:
					audio[chunk.name] = cast(chunk, AudioChunk).getAudio();
				case SPRITE:
					sprites[chunk.name] = cast(chunk, SpriteChunk).getSprite();
				case TILESET:
					tilesets[chunk.name] = cast(chunk, TilesetChunk).getTileset();
				case TILEMAP:
					tilemaps[chunk.name] = cast(chunk, TilemapChunk).getTilemap(tilesets[chunk.name]);
				case FONT:
					fonts[chunk.name] = cast(chunk, FontChunk).getFont(tilesets['font:${chunk.name}']);
				case DATA:
					data[chunk.name] = cast(chunk, DataChunk).getBytes();
			}
		}

		return new Rom(palette, audio, tilesets, tilemaps, sprites, fonts, data);
	}

	/**
		Create a file containing ROM data

		@param src Directory containing source rom data
		@param filePath File to store rom data to
		@param compress Whether the data should be compressed
	 */
	public static macro function file(src:String = 'rom', filePath:String = 'rom.bin', ?compressed:Bool = true) {
		final romBytes = compressed ? haxe.zip.Compress.run(RomCreator.create(src), 9) : RomCreator.create(src);

		sys.io.File.saveBytes(filePath, romBytes);

		return macro final ROM_FILE = true;
	}

	public static macro function embed(src:String = 'rom', ?compressed:Bool = true) {
		final romBytes = RomCreator.create(src);
		final romHex = compressed ? haxe.zip.Compress.run(romBytes, 9).toHex() : romBytes.toHex();

		return macro res.rom.Rom.fromBytes(haxe.io.Bytes.ofHex($v{romHex}), $v{compressed});
	}
}
