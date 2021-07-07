package res;

class Rom {
	#if macro
	static function asepriteToSprite(path:String):haxe.io.Bytes {
		var spriteData = ase.Ase.fromBytes(sys.io.File.getBytes(path));

		if (spriteData.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are supported';

		if (!(spriteData.width == spriteData.height))
			throw 'Sprite must be square';

		if (spriteData.width > 64)
			throw 'Sprite is too big (>64px)';

		var tileSize:Int = spriteData.width;

		var bytesOutput = new haxe.io.BytesOutput();

		bytesOutput.writeByte(spriteData.width);
		bytesOutput.writeInt32(spriteData.frames.length);

		for (frame in spriteData.frames) {
			bytesOutput.writeInt32(frame.duration); // frame duration

			var frameData = haxe.io.Bytes.alloc(tileSize * tileSize);

			for (layer in 0...spriteData.layers.length) {
				var cel = frame.cel(layer);

				if (cel != null) {
					var lineWidth:Int = Std.int(Math.min(tileSize, cel.xPosition + cel.width));

					for (scanline in 0...cel.height) {
						var frameLine = cel.yPosition + scanline;

						var framePos = frameLine * tileSize + cel.xPosition;
						var celPos = scanline * cel.width;

						frameData.blit(framePos, cel.pixelData, celPos, lineWidth);
					}
				} else
					trace('cel == null');
			}

			bytesOutput.writeBytes(frameData, 0, frameData.length);
		}

		return bytesOutput.getBytes();
	}

	static function convertResource(type:String, fullPath:String):haxe.io.Bytes {
		switch (type) {
			case 'sprites':
				return asepriteToSprite(fullPath);
			case _:
				trace('Warning: No converter for $type');
				return sys.io.File.getBytes(fullPath);
		}
	}
	#end

	public static macro function init(src:String, out:String) {
		final resTypes:Array<String> = ['tilesets', 'tilemaps', 'sprites'];
		final supportedTypes:Map<String, Array<String>> = ['tilesets' => [], 'tilemaps' => [], 'sprites' => ['ase', 'aseprite']];

		haxe.macro.Context.onGenerate((_) -> {
			if (Sys.args().indexOf("--no-output") == -1) {
				trace('Creating ROM');

				if (!sys.FileSystem.exists(src))
					throw 'Error: $src doesn\'t exists';

				var rom = new haxe.zip.Writer(sys.io.File.write(out));

				var files:List<haxe.zip.Entry> = new List<haxe.zip.Entry>();

				for (resourceType in resTypes) {
					final path = haxe.io.Path.join([src, resourceType]);

					if (sys.FileSystem.isDirectory(path)) {
						for (file in sys.FileSystem.readDirectory(path)) {
							var filePath = haxe.io.Path.join([path, file]);
							if (!sys.FileSystem.isDirectory(filePath)) {
								var fileExt = haxe.io.Path.extension(file);

								if (supportedTypes[resourceType].indexOf(fileExt) != -1) {
									var name = haxe.io.Path.withoutExtension(file);
									var fileData = convertResource(resourceType, filePath);

									var entry:haxe.zip.Entry = {
										fileTime: Date.now(),
										fileName: haxe.io.Path.join([resourceType, name]),
										fileSize: fileData.length,
										dataSize: fileData.length,
										data: fileData,
										crc32: haxe.crypto.Crc32.make(fileData),
										compressed: false
									};

									haxe.zip.Tools.compress(entry, 9);

									files.add(entry);
								} else {
									trace('ROM Warning: Unsupported file: ${fileExt}');
								}
							}
						}
					} else
						trace('No $resourceType for this ROM');
				}

				rom.write(files);
			}
		});
		return macro trace('ROM initialized');
	}
}