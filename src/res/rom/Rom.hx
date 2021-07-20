package res.rom;

import haxe.zip.InflateImpl;
import haxe.Int32;
import haxe.io.Bytes;
import haxe.io.BytesInput;
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

	public final tilesets:Map<String, Tileset>;
	public final tilemaps:Map<String, Tilemap>;
	public final sprites:Map<String, Sprite>;

	private function new(tilesets:Map<String, Tileset>, tilemaps:Map<String, Tilemap>, sprites:Map<String, Sprite>) {
		this.tilesets = tilesets;
		this.tilemaps = tilemaps;
		this.sprites = sprites;
	}

	#if macro
	static function asepriteToSprite(path:String):Bytes {
		var spriteData = ase.Ase.fromBytes(File.getBytes(path));

		if (spriteData.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are supported';

		var tileSize:Int = spriteData.width;

		var bytesOutput = new BytesOutput();

		bytesOutput.writeByte(spriteData.width);
		bytesOutput.writeInt32(spriteData.frames.length);

		for (frame in spriteData.frames) {
			bytesOutput.writeInt32(frame.duration); // frame duration

			var frameData = Bytes.alloc(tileSize * tileSize);

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

	static function asepriteToTileset(path:String):Bytes {
		final aseData = ase.Ase.fromBytes(File.getBytes(path));

		if (!(aseData.header.gridHeight == aseData.header.gridWidth))
			throw 'Only square grid is allowed';

		if (aseData.colorDepth != INDEXED)
			throw('Only Indexed Aseprite files please');

		if ((aseData.width % aseData.header.gridHeight != 0) || (aseData.height % aseData.header.gridHeight != 0))
			throw('Invalid size');

		if (aseData.frames.length > 1)
			trace("Warning: aseprite file contains more than 1 frame. The rest will be ignored");

		final bo = new BytesOutput();

		final tileSize:Int = aseData.header.gridWidth;
		bo.writeByte(tileSize);

		final hTiles:Int = Std.int(aseData.width / tileSize);
		bo.writeByte(hTiles);

		final vTiles:Int = Std.int(aseData.height / tileSize);
		bo.writeByte(vTiles);

		final merged = Bytes.alloc(aseData.width * aseData.height);

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
				final tileBytes = Bytes.alloc(tileSize * tileSize);

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

	static function convertResource(type:String, fullPath:String):Bytes {
		switch (type) {
			case 'tilesets':
				return asepriteToTileset(fullPath);
			case 'sprites':
				trace('Adding Sprite to the ROM $fullPath');
				return asepriteToSprite(fullPath);
			case _:
				trace('Warning: No converter for $type');
				return File.getBytes(fullPath);
		}
	}

	public static function create(src:String):Bytes {
		trace('Creating ROM');

		if (!FileSystem.exists(src))
			throw 'Error: $src doesn\'t exists';

		final resTypes:Array<String> = ['tilesets', 'tilemaps', 'sprites'];
		final supportedTypes:Map<String, Array<String>> = [
			'tilesets' => ['aseprite'],
			'tilemaps' => ['aseprite'],
			'sprites' => ['aseprite']
		];

		final byteOutput = new BytesOutput();

		byteOutput.writeInt32(MAGIC_NUMBER);

		for (resourceType in resTypes) {
			final path = Path.join([src, resourceType]);

			if (FileSystem.isDirectory(path)) {
				for (file in FileSystem.readDirectory(path)) {
					var filePath = Path.join([path, file]);
					if (!FileSystem.isDirectory(filePath)) {
						var fileExt = Path.extension(file).toLowerCase();

						if (supportedTypes[resourceType].indexOf(fileExt) != -1) {
							var name = Path.withoutExtension(file);
							var fileBytes = File.getBytes(Path.join([path, file]));

							switch (resourceType) {
								case 'sprites':
									switch (fileExt) {
										case 'aseprite':
											SpriteChunk.fromAseprite(fileBytes, name).write(byteOutput);
									}
								case 'tilesets':
									switch (fileExt) {
										case 'aseprite':
											TilesetChunk.fromAseprite(fileBytes, name).write(byteOutput);
									}
								case 'tilemaps':
									switch (fileExt) {
										case 'aseprite':
											var result = TilemapChunk.fromAseprite(fileBytes, name);
											result.tilesetChunk.write(byteOutput);
											result.tilemapChunk.write(byteOutput);
									}
							}
						} else {
							trace('ROM Warning: Unsupported file format: ${fileExt}');
						}
					}
				}
			} else
				trace('No $resourceType for this ROM');
		}

		return byteOutput.getBytes();
	}
	#end

	public static function empty():Rom {
		return new Rom([], [], []);
	}

	public static function fromBytes(bytes:Bytes, ?compressed:Bool):Rom {
		trace('Loading ROM: ${bytes.length} bytes' + (compressed ? ' (compressed)' : ''));

		var sprites:Map<String, Sprite> = [];
		var tilesets:Map<String, Tileset> = [];
		var tilemaps:Map<String, Tilemap> = [];

		var bytesInput = new BytesInput(compressed ? InflateImpl.run(new BytesInput(bytes)) : bytes);

		if (bytesInput.readInt32() != MAGIC_NUMBER)
			throw 'Invalid magic number';

		while (bytesInput.position < bytesInput.length) {
			final chunk = RomChunk.read(bytesInput);

			switch (chunk.chunkType) {
				case SPRITE:
					sprites[chunk.name] = cast(chunk, SpriteChunk).getSprite();
				case TILESET:
					tilesets[chunk.name] = cast(chunk, TilesetChunk).getTileset();
				case TILEMAP:
					tilemaps[chunk.name] = cast(chunk, TilemapChunk).getTilemap(tilesets[chunk.name]);
				case _:
					trace('TODO');
			}
		}

		return new Rom(tilesets, tilemaps, sprites);
	}

	public static macro function embed(src:String, ?compressed:Bool = true) {
		final romBytes = create(src);
		final romHex = compressed ? haxe.zip.Compress.run(romBytes, 9).toHex() : romBytes.toHex();

		return macro res.rom.Rom.fromBytes(haxe.io.Bytes.ofHex($v{romHex}), $v{compressed});
	}
}
