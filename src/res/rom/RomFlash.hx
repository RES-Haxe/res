package res.rom;

import haxe.Exception;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.InflateImpl;
import res.Rom.RomContent;
import res.audio.AudioData;

using StringTools;

inline function et<T>(a:Map<String, T>):Map<String, T>
	return a == null ? [] : a;

/**
	ROM "Flashing" tool

	Used to create ROM data from different sources
 */
class RomFlash {
	public static inline var MAGIC_NUMBER:Int32 = 0x52524f4d; // RROM

	/**
		Load rom from bytes

		@param bytes
		@param compressed Whether the data is gzip compressed or not
	 */
	public static function fromBytes(bytes:Bytes, ?compressed:Bool = true, ?add:RomContent):Rom {
		final bytesInput = new BytesInput(compressed ? InflateImpl.run(new BytesInput(bytes)) : bytes);

		if (bytesInput.readInt32() != MAGIC_NUMBER)
			throw new Exception('Invalid magic number');

		final audio:Map<String, AudioData> = add != null ? et(add.audio) : [];
		final sprites:Map<String, Sprite> = add != null ? et(add.sprites) : [];
		final tilesets:Map<String, Tileset> = add != null ? et(add.tilesets) : [];
		final tilemaps:Map<String, Tilemap> = add != null ? et(add.tilemaps) : [];
		final fonts:Map<String, Font> = add != null ? et(add.fonts) : [];
		final data:Map<String, Bytes> = add != null ? et(add.data) : [];

		final firstRomChunkId = bytesInput.readByte();

		if (firstRomChunkId != 0x0)
			throw new Exception('First chunk in the ROM must be Palette (0x00). Got: 0x${firstRomChunkId.hex(2)}');

		bytesInput.position -= 1;

		final paletteChunk:PaletteChunk = cast RomChunk.read(bytesInput);

		final palette = paletteChunk.getPalette();

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
					tilemaps[chunk.name] = cast(chunk, TilemapChunk).getTilemap(tilesets);
				case FONT:
					fonts[chunk.name] = cast(chunk, FontChunk).getFont(sprites['font:${chunk.name}']);
				case DATA:
					data[chunk.name] = cast(chunk, DataChunk).getBytes();
				case PALETTE: // Ignore PALETTE chunk
			}
		}

		return new Rom(palette, {
			audio: audio,
			tilesets: tilesets,
			tilemaps: tilemaps,
			sprites: sprites,
			fonts: fonts,
			data: data
		});
	}

	/**
		Create a rom

		@param palette Palette to use
		@param content
		@param content.audio Audio data
		@param content.tilesets Tilsets
		@param content.tilemaps Tilemaps
		@param content.sprites Sprites
		@param content.fonts Fonts
		@param content.data Data
	 */
	public static function create(?palette:Palette, content:RomContent) {
		return new Rom(palette == null ? Palette.createDefault() : palette, content);
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

	/**
		Macro that  creates a rom file but store it in the code as a Baas64 string.

		Generates a line of code that looks like this:


		```haxe
		res.rom.RomFlash.fromBytes(haxe.crypto.Base64.decode('eNrtWTdvFUEQHgtsIdAUdAgBIuc<...>'), true);
		```

		@param src Source directory that contains the files for the ROM
		@param compressed Whether the rom data should be compressed or not
		@param add Additional content
	 */
	public static macro function embed(src:String = 'rom', ?compressed:Bool = true, ?add:haxe.macro.Expr.ExprOf<RomContent>) {
		final romBytes = RomCreator.create(src);
		final romBytesFinal = compressed ? haxe.zip.Compress.run(romBytes, 9) : romBytes;
		final romBase64 = haxe.crypto.Base64.encode(romBytesFinal);
		return macro res.rom.RomFlash.fromBytes(haxe.crypto.Base64.decode($v{romBase64}), $v{compressed}, ${add});
	}

	/**
		Create and embed a ROM only containing firmware data
	 */
	public static macro function firmware(?compressed:Bool = true) {
		final romBytes = RomCreator.create(RomCreator.getFirmwarePath(), false);
		final romBytesFinal = compressed ? haxe.zip.Compress.run(romBytes, 9) : romBytes;
		final romBase64 = haxe.crypto.Base64.encode(romBytesFinal);
		return macro res.rom.Rom.fromBytes(haxe.crypto.Base64.decode($v{romBase64}), $v{compressed});
	}

	/**
		Create an empy rom

		@param palette optional palette
	 */
	public static inline function empty(?palette:Palette) {
		return new Rom(palette == null ? Palette.createDefault() : palette, {});
	}
}
