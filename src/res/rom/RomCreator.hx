package res.rom;

import haxe.PosInfos;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Path;
import res.rom.converters.Converter;
import res.rom.converters.palette.PaletteConverter;
import sys.FileSystem.*;

final CONVERTERS:Map<String, Map<String, Converter>> = [
	'audio' => [
		'wav' => new res.rom.converters.audio.wav.Converter()
	],
	'data' => [
		'' => new res.rom.converters.data.Converter()
	],
	'palette' => [
		'' => new res.rom.converters.palette.text.Converter(),
		'txt' => new res.rom.converters.palette.text.Converter(),
		'aseprite' => new res.rom.converters.palette.aseprite.Converter(),
		'png' => new res.rom.converters.palette.png.Converter()
	],
	'fonts' => [
		'json' => new res.rom.converters.fonts.json.Converter(),
		'fnt' => new res.rom.converters.fonts.fnt.Converter()
	],
	'sprites' => [
		'aseprite' => new res.rom.converters.sprites.aseprite.Converter(),
		'png' => new res.rom.converters.sprites.png.Converter()
	],
	'tilesets' => [
		'aseprite' => new res.rom.converters.tilesets.aseprite.Converter(),
		'json' => new res.rom.converters.tilesets.json.Converter()
	],
	'tilemaps' => [
		'aseprite' => new res.rom.converters.tilemaps.aseprite.Converter()
	]
];

class RomCreator {
	/**
		Returns the path of the firmware directory
	 */
	public static function getFirmwarePath(?posInfos:PosInfos) {
		return Path.normalize('${Path.join([Path.directory(posInfos.fileName), '..', 'firmware'])}');
	}

	/**
		Find a supported Palette file in the given directory and return
		a `PaletteChunk` after parsing it or `null` otherwise.

		@param src Path to the directory containing Palette file
	**/
	static function createPalette(src:String):Null<PaletteChunk> {
		for (ext => converter in CONVERTERS['palette']) {
			final fileNameParts = [Path.join([src, 'palette'])];

			if (ext != '')
				fileNameParts.push(ext);

			final paletteFile = fileNameParts.join('.');

			if (exists(paletteFile)) {
				Sys.println('Palette file: $paletteFile');
				var paletteConverter:PaletteConverter = cast converter;
				paletteConverter.process(paletteFile, null);
				return cast paletteConverter.getChunks()[0];
			}
		}

		return null;
	}

	/**
		Convert a directory to an array of chunks

		@param  src
				Directory to scan for chunks
		@param  palette
				Palette to use
	 */
	static function createChunks(src:String, palette:Palette):Array<RomChunk> {
		final result = [];

		if (!exists(src))
			return result;

		for (resourceType => converters in CONVERTERS) {
			final path = Path.join([src, resourceType]);

			if (isDirectory(path)) {
				for (file in readDirectory(path)) {
					final filePath = Path.join([path, file]);
					if (!isDirectory(filePath)) {
						final fileExt = Path.extension(file).toLowerCase();
						final fileConverter = (converters[''] != null) ? converters[''] : converters[fileExt];

						if (fileConverter != null) {
							final chunks = fileConverter.process(filePath, palette).getChunks();

							for (chunk in chunks) {
								if (chunk != null)
									result.push(chunk);
							}
						}
					}
				}
			}
		}

		return result;
	}

	/**
		Create a RES ROM Bytes

		@param  src
				Directory to use as the source of the ROM data
		@param  firmware
				Whether the firmware data should be included to the ROM data
	 */
	public static function create(src:String, firmware:Bool = true):Bytes {
		final byteOutput = new BytesOutput();

		// Write magic number
		byteOutput.writeInt32(RomFlash.MAGIC_NUMBER);

		final sourceDirs = [Path.normalize(src)];

		if (firmware) {
			final firmwarePath = getFirmwarePath();
			sourceDirs.unshift(firmwarePath);
		}

		var paletteChunk:Null<PaletteChunk> = null;

		var i = sourceDirs.length - 1;

		while (i >= 0) {
			paletteChunk = createPalette(sourceDirs[i]);
			if (paletteChunk != null)
				break;
			i--;
		}

		if (paletteChunk == null) {
			throw "Missing Palette in the ROM data";
		}

		paletteChunk.write(byteOutput);

		final palette = paletteChunk.getPalette();

		for (dir in sourceDirs) {
			final chunks = createChunks(dir, palette);

			for (chunk in chunks) {
				chunk.write(byteOutput);
			}
		}

		final resultBytes = byteOutput.getBytes();

		Sys.println('ROM has been generated. Size: ${resultBytes.length} bytes (uncompressed)');

		return resultBytes;
	}
}
