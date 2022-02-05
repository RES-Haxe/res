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
#if macro
import haxe.PosInfos;
import haxe.io.BytesOutput;
import haxe.io.Path;
import haxe.zip.Compress;
import res.rom.converters.Converter;
import res.rom.converters.palette.PaletteConverter;
import sys.FileSystem;
import sys.io.File;

final CONVERTERS:Map<String, Map<String, Converter>> = [
	'audio' => [
		'wav' => new res.rom.converters.audio.wav.Converter()
	],
	'data' => [
		'' => new res.rom.converters.data.Converter()
	],
	'palette' => [
		'' => new res.rom.converters.palette.text.Converter(),
		'png' => new res.rom.converters.palette.png.Converter()
	],
	'fonts' => [
		'json' => new res.rom.converters.fonts.json.Converter()
	],
	'sprites' => [
		'aseprite' => new res.rom.converters.sprites.aseprite.Converter(),
		'png' => new res.rom.converters.sprites.png.Converter()
	],
	'tilesets' => [
		'aseprite' => new res.rom.converters.tilesets.aseprite.Converter()
	],
	'tilemaps' => [
		'aseprite' => new res.rom.converters.tilemaps.aseprite.Converter()
	]
];
#end

class Rom {
	static inline var MAGIC_NUMBER:Int32 = 0x52524f4d; // RROM

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

	#if macro
	static function create(src:String, ?posInfos:PosInfos):Bytes {
		if (!FileSystem.exists(src))
			FileSystem.createDirectory(src);

		var paletteConverter:PaletteConverter = null;

		for (ext => converter in CONVERTERS['palette']) {
			final fileName = Path.join([src, 'palette']);
			final paletteFile = ext == '' ? fileName : Path.withExtension(fileName, ext);

			if (FileSystem.exists(paletteFile)) {
				paletteConverter = cast converter;
				paletteConverter.process(paletteFile, null);
			}
		}

		if (paletteConverter == null)
			// SWEETIE 16 PALETTE: https://lospec.com/palette-list/sweetie-16
			paletteConverter = new PaletteConverter([
				0x000000,
				0x1a1c2c,
				0x5d275d,
				0xb13e53,
				0xef7d57,
				0xffcd75,
				0xa7f070,
				0x38b764,
				0x257179,
				0x29366f,
				0x3b5dc9,
				0x41a6f6,
				0x73eff7,
				0xf4f4f4,
				0x94b0c2,
				0x566c86,
				0x333c57
			].map(c -> Color32.ofRGB8(c)));

		final palette = new res.Palette(paletteConverter.colors);

		final byteOutput = new BytesOutput();

		// Write magic number
		byteOutput.writeInt32(MAGIC_NUMBER);

		final paletteBytes = paletteConverter.getBytes();
		byteOutput.writeBytes(paletteBytes, 0, paletteBytes.length);

		final firmware = Path.normalize('${Path.join([Path.directory(posInfos.fileName), '..', 'firmware'])}');

		for (dir in [src, firmware]) {
			for (resourceType => converters in CONVERTERS) {
				final path = Path.join([dir, resourceType]);

				if (FileSystem.isDirectory(path)) {
					for (file in FileSystem.readDirectory(path)) {
						final filePath = Path.join([path, file]);
						if (!FileSystem.isDirectory(filePath)) {
							final fileExt = Path.extension(file).toLowerCase();
							final fileConverter = (converters[''] != null) ? converters[''] : converters[fileExt];

							if (fileConverter != null) {
								final chunks = fileConverter.process(filePath, palette).getChunks();

								for (chunk in chunks) {
									if (chunk != null)
										chunk.write(byteOutput);
								}
							}
						}
					}
				}
			}
		}

		final resultBytes = byteOutput.getBytes();

		Sys.println('ROM has been generated. Size: ${resultBytes.length} bytes (uncompressed)');

		return resultBytes;
	}
	#end

	/**
		Load rom from bytes

		@param bytes
		@param compressed Whether the data is gzip compressed or not
	 */
	public static function fromBytes(bytes:Bytes, ?compressed:Bool = false):Rom {
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
		final romBytes = compressed ? Compress.run(create(src), 9) : create(src);

		File.saveBytes(filePath, romBytes);

		return macro final ROM_FILE = true;
	}

	public static macro function embed(src:String = 'rom', ?compressed:Bool = true) {
		final romBytes = create(src);
		final romHex = compressed ? haxe.zip.Compress.run(romBytes, 9).toHex() : romBytes.toHex();

		return macro res.rom.Rom.fromBytes(haxe.io.Bytes.ofHex($v{romHex}), $v{compressed});
	}
}
