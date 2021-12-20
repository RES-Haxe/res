package res.rom;

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
import res.audio.AudioData;
import res.audio.IAudioBuffer;
import res.display.Sprite;
import res.rom.converters.Converter;
import res.rom.converters.palette.PaletteConverter;
import res.text.Font;
import res.tiles.Tilemap;
import res.tiles.Tileset;
#if macro
import haxe.io.BytesOutput;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
#end

final CONVERTERS:Map<String, Map<String, Converter>> = [
	'palette' => [
		'' => new res.rom.converters.palette.text.Converter(),
		'png' => new res.rom.converters.palette.png.Converter()
	],
	'fonts' => [
		'json' => new res.rom.converters.fonts.json.Converter()
	],
	'sprites' => [
		'aseprite' => new res.rom.converters.sprites.aseprite.Converter()
	]
];

class Rom {
	static inline var MAGIC_NUMBER:Int32 = 0x52524f4d; // RROM

	public final palette:Palette;
	public final audioData:Map<String, AudioData>;
	public final audioBuffers:Map<String, IAudioBuffer> = [];
	public final data:Map<String, Bytes>;
	public final fonts:Map<String, Font>;
	public final sprites:Map<String, Sprite>;
	public final tilemaps:Map<String, Tilemap>;
	public final tilesets:Map<String, Tileset>;

	private function new(palette:Palette, audioData:Map<String, AudioData>, tilesets:Map<String, Tileset>, tilemaps:Map<String, Tilemap>,
			sprites:Map<String, Sprite>, fonts:Map<String, Font>, data:Map<String, Bytes>) {
		this.palette = palette;
		this.audioData = audioData;
		this.tilesets = tilesets;
		this.tilemaps = tilemaps;
		this.sprites = sprites;
		this.fonts = fonts;
		this.data = data;
	}

	#if macro
	public static function create(src:String):Bytes {
		trace('Generating ROM Data');

		if (!FileSystem.exists(src))
			FileSystem.createDirectory(src);

		var paletteConverter:PaletteConverter = null;

		for (ext => converter in CONVERTERS['palette']) {
			final paletteFile = Path.withExtension(Path.join([src, 'palette']), ext);

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
			]);

		final palette = new res.Palette(paletteConverter.colors);

		final resTypes:Array<String> = ['audio', 'tilesets', 'tilemaps', 'sprites', 'fonts', 'data'];
		final supportedTypes:Map<String, Array<String>> = [
			'tilesets' => ['aseprite', 'json'],
			'tilemaps' => ['aseprite'],
			'sprites' => ['aseprite', 'png'],
			'fonts' => ['txt'],
			'data' => [],
			'audio' => ['wav']
		];

		final byteOutput = new BytesOutput();

		// Write magic number
		byteOutput.writeInt32(MAGIC_NUMBER);

		final paletteBytes = paletteConverter.getBytes();
		byteOutput.writeBytes(paletteBytes, 0, paletteBytes.length);

		for (resourceType => converters in CONVERTERS) {
			final path = Path.join([src, resourceType]);

			if (FileSystem.isDirectory(path)) {
				for (file in FileSystem.readDirectory(path)) {
					final filePath = Path.join([path, file]);
					if (!FileSystem.isDirectory(filePath)) {
						final fileExt = Path.extension(file).toLowerCase();
						final fileConverter = converters[fileExt];

						if (fileConverter != null) {
							final chunks = fileConverter.process(filePath, palette).getChunks();

							for (chunk in chunks)
								chunk.write(byteOutput);
						}
					}
				}
			}
		}

		for (resourceType in resTypes) {
			final path = Path.join([src, resourceType]);

			if (FileSystem.isDirectory(path)) {
				for (file in FileSystem.readDirectory(path)) {
					var filePath = Path.join([path, file]);
					if (!FileSystem.isDirectory(filePath)) {
						var fileExt = Path.extension(file).toLowerCase();

						if (supportedTypes[resourceType].length == 0 || supportedTypes[resourceType].indexOf(fileExt) != -1) {
							var name = Path.withoutExtension(file);
							var fileBytes = File.getBytes(Path.join([path, file]));

							switch (resourceType) {
								case 'audio':
									switch (fileExt) {
										case 'wav':
											AudioSampleChunk.fromWav(fileBytes, name).write(byteOutput);
									}
								case 'sprites':
									switch (fileExt) {
										/*
											case 'aseprite':
												SpriteChunk.fromAseprite(fileBytes, name).write(byteOutput);
										 */
										case 'png':
											SpriteChunk.fromPNG(fileBytes, palette, name).write(byteOutput);
									}
								case 'tilesets':
									switch (fileExt) {
										case 'aseprite':
											TilesetChunk.fromAseprite(fileBytes, name).write(byteOutput);
											/*
												case 'json':
													TilesetChunk.fromJson(filePath, name, palette).write(byteOutput);
											 */
									}
								case 'tilemaps':
									switch (fileExt) {
										case 'aseprite':
											var result = TilemapChunk.fromAseprite(fileBytes, name);
											result.tilesetChunk.write(byteOutput);
											result.tilemapChunk.write(byteOutput);
									}
								case 'fonts':
									final aseFile = Path.join([path, '$name.aseprite']);
									if (FileSystem.exists(aseFile)) {
										final tileset = TilesetChunk.fromAseprite(File.getBytes(aseFile), 'font:$name', false);
										tileset.write(byteOutput);
										final font = FontChunk.fromBytes(fileBytes, name);
										font.write(byteOutput);
									} else {
										trace('No Aseprite file for the font');
									}
								case 'data':
									DataChunk.fromBytes(fileBytes, file).write(byteOutput);
							}
						}
					}
				}
			}
		}

		return byteOutput.getBytes();
	}
	#end

	public static function fromBytes(bytes:Bytes, ?compressed:Bool):Rom {
		final bytesInput = new BytesInput(compressed ? InflateImpl.run(new BytesInput(bytes)) : bytes);

		if (bytesInput.readInt32() != MAGIC_NUMBER)
			throw 'Invalid magic number';

		// Read number of colors
		final numColors = bytesInput.readByte();
		final palette:Palette = new Palette([for (_ in 0...numColors) bytesInput.readUInt24()]);
		final audioData:Map<String, AudioData> = [];
		final sprites:Map<String, Sprite> = [];
		final tilesets:Map<String, Tileset> = [];
		final tilemaps:Map<String, Tilemap> = [];
		final fonts:Map<String, Font> = [];
		final data:Map<String, Bytes> = [];

		while (bytesInput.position < bytesInput.length) {
			final chunk = RomChunk.read(bytesInput);

			switch (chunk.chunkType) {
				case AUDIO_SAMPLE:
					audioData[chunk.name] = cast(chunk, AudioSampleChunk).getAudio();
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

		return new Rom(palette, audioData, tilesets, tilemaps, sprites, fonts, data);
	}

	public static macro function embed(src:String, ?compressed:Bool = true) {
		final romBytes = create(src);
		final romHex = compressed ? haxe.zip.Compress.run(romBytes, 9).toHex() : romBytes.toHex();

		return macro res.rom.Rom.fromBytes(haxe.io.Bytes.ofHex($v{romHex}), $v{compressed});
	}
}
