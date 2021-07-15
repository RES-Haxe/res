package res;

class Rom {
	public static var romSourcePath:String;

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

	static function asepriteToTileset(path:String):haxe.io.Bytes {
		final aseData = ase.Ase.fromBytes(sys.io.File.getBytes(path));

		if (!(aseData.header.gridHeight == aseData.header.gridWidth))
			throw 'Only square grid is allowed';

		if (aseData.colorDepth != INDEXED)
			throw('Only Indexed Aseprite files please');

		if ((aseData.width % aseData.header.gridHeight != 0) || (aseData.height % aseData.header.gridHeight != 0))
			throw('Invalid size');

		if (aseData.frames.length > 1)
			trace("Warning: aseprite file contains more than 1 frame. The rest will be ignored");

		final bo = new haxe.io.BytesOutput();

		final tileSize:Int = aseData.header.gridWidth;
		bo.writeByte(tileSize);

		final hTiles:Int = Std.int(aseData.width / tileSize);
		bo.writeByte(hTiles);

		final vTiles:Int = Std.int(aseData.height / tileSize);
		bo.writeByte(vTiles);

		final merged = haxe.io.Bytes.alloc(aseData.width * aseData.height);

		merged.fill(0, merged.length, 0);

		for (l in 0...aseData.layers.length) {
			final cel = aseData.firstFrame.cel(l);

			if (cel != null) {
				for (srcY in 0...cel.height) {
					final srcPos:Int = srcY * cel.width;
					final dstX:Int = cel.xPosition;
					final dstY:Int = cel.yPosition + srcY;
					final cpyLen:Int = cel.width;

					merged.blit(dstY * aseData.width + dstX, cel.pixelData, srcPos, cel.width);
				}
			}
		}

		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				final tileBytes = haxe.io.Bytes.alloc(tileSize * tileSize);

				final srcPosX:Int = col * tileSize;

				for (t_line in 0...tileSize) {
					final srcPosY:Int = line * tileSize + t_line;

					tileBytes.blit(t_line * tileSize, merged, srcPosY * aseData.width + srcPosX, tileSize);
				}

				bo.writeBytes(tileBytes, 0, tileBytes.length);
			}
		}

		return bo.getBytes();
	}

	static function convertResource(type:String, fullPath:String):haxe.io.Bytes {
		switch (type) {
			case 'tilesets':
				return asepriteToTileset(fullPath);
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
		final supportedTypes:Map<String, Array<String>> = [
			'tilesets' => ['ase', 'aseprite'],
			'tilemaps' => [],
			'sprites' => ['ase', 'aseprite']
		];

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

									// haxe.zip.Tools.compress(entry, 9);

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
		return macro Rom.romSourcePath = $v{haxe.io.Path.join([Sys.getCwd(), src])};
	}
}
