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
		'aseprite' => new res.rom.converters.tilesets.aseprite.Converter(),
		'json' => new res.rom.converters.tilesets.json.Converter()
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

		final palette:Palette = if (paletteConverter == null) {
			final p = Palette.createDefault();
			paletteConverter = new PaletteConverter(p.colors);
			p;
		} else new Palette(paletteConverter.colors);

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
