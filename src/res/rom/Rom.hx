package res.rom;

import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
import res.audio.AudioData;
import res.audio.IAudioBuffer;
import res.display.Sprite;
import res.text.Font;
import res.tiles.Tilemap;
import res.tiles.Tileset;
#if macro
import haxe.io.BytesOutput;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
#end

class Rom {
	static inline var MAGIC_NUMBER:Int32 = 0x52524f4d;

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

		if (!FileSystem.exists('$src/palette')) {
			// Default palette
			final defaultPaletteContent = [
				'-- SWEETIE 16 PALETTE: https://lospec.com/palette-list/sweetie-16',
				'#000000',
				'#1a1c2c',
				'#5d275d',
				'#b13e53',
				'#ef7d57',
				'#ffcd75',
				'#a7f070',
				'#38b764',
				'#257179',
				'#29366f',
				'#3b5dc9',
				'#41a6f6',
				'#73eff7',
				'#f4f4f4',
				'#94b0c2',
				'#566c86',
				'#333c57'
			];

			File.saveContent('$src/palette', defaultPaletteContent.join('\n'));
		}

		final paletteFile = Path.join([src, 'palette']);

		if (!FileSystem.exists(paletteFile) || FileSystem.isDirectory(paletteFile))
			throw 'Error: palette file is required ($paletteFile not found)';

		final paletteColors:Array<Int> = [];

		final file = File.read(paletteFile, false);

		while (paletteColors.length < 256 && !file.eof()) {
			var colStr:String = file.readLine();

			if (colStr.substr(0, 2) == '--') // comment
				continue;

			/** TODO: Parse some other formats like rgb(r, g, b) or maybe simple
				"r,g,b" string or somethign like that */

			if (colStr.charAt(0) == '#')
				colStr = colStr.substr(1);

			if (colStr.substr(0, 2) == '0x')
				colStr = colStr.substr(2);

			paletteColors.push(Std.parseInt('0x$colStr'));
		}

		final palette = new res.Palette(paletteColors);

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

		// Write number of colors in the pallet
		byteOutput.writeByte(paletteColors.length);

		for (col in paletteColors)
			byteOutput.writeUInt24(col);

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
										case 'aseprite':
											SpriteChunk.fromAseprite(fileBytes, name).write(byteOutput);
										case 'png':
											SpriteChunk.fromPNG(fileBytes, palette, name).write(byteOutput);
									}
								case 'tilesets':
									switch (fileExt) {
										case 'aseprite':
											TilesetChunk.fromAseprite(fileBytes, name).write(byteOutput);
										case 'json':
											TilesetChunk.fromJson(filePath, name, palette).write(byteOutput);
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
