package res.rom;

import haxe.PosInfos;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Path;
import res.rom.converters.Converter;
import res.rom.converters.palette.PaletteConverter;
import sys.FileSystem;

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
		'json' => new res.rom.converters.fonts.json.Converter(),
		'fnt' => new res.rom.converters.fonts.fnt.Converter()
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

class RomCreator {
	public static function create(src:String, ?posInfos:PosInfos):Bytes {
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
		byteOutput.writeInt32(Rom.MAGIC_NUMBER);

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
}
