package res.rom;

import format.png.Reader;
import format.png.Tools;
import haxe.Json;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.io.Path;
import res.tiles.Tileset;

typedef TilesetJson = {
	size:Int
};

class TilesetChunk extends RomChunk {
	public function new(name:String, data:Bytes) {
		super(TILESET, name, data);
	}

	public function getTileset():Tileset {
		final bi = new BytesInput(data);

		final tileWidth = bi.readByte();
		final tileHeight = bi.readByte();
		final numTiles = bi.readInt32();

		final tileset = new Tileset(tileWidth, 16, 16);

		for (_ in 0...numTiles) {
			final tileData = Bytes.alloc(tileWidth * tileHeight);
			bi.readBytes(tileData, 0, tileData.length);
			tileset.createTile(tileData);
		}

		return tileset;
	}

	#if macro
	public static function fromJson(filename:String, name:String, palette:Palette):TilesetChunk {
		final meta:TilesetJson = Json.parse(sys.io.File.getContent(filename));
		final pngData = new Reader(new BytesInput(sys.io.File.getBytes(Path.withoutExtension(filename) + '.png'))).read();
		final pngHeader = Tools.getHeader(pngData);

		if (pngHeader.width % meta.size != 0 || pngHeader.height % meta.size != 0)
			throw 'Invalid PNG size: width % ${meta.size} != 0 || height % ${meta.size} != 0';

		final hTiles:Int = Std.int(pngHeader.width / meta.size);
		final vTiles:Int = Std.int(pngHeader.height / meta.size);

		final pixels = Tools.extract32(pngData);

		final empty = Bytes.alloc(meta.size * meta.size);
		empty.fill(0, empty.length, 0);

		final tiles:Array<Bytes> = [];

		for (yTile in 0...vTiles) {
			for (xTile in 0...hTiles) {
				final tileBytes = Bytes.alloc(meta.size * meta.size);

				for (line in 0...meta.size) {
					for (col in 0...meta.size) {
						final srcx = xTile * meta.size + col;
						final srcy = yTile * meta.size + line;
						final pixel:Color = pixels.getInt32((srcy * pngHeader.width + srcx) * 4);

						if (pixel != 0x0) {
							final color = Color.fromRGBA(pixel.g, pixel.b, pixel.a, pixel.r);
							final index = palette.closest(color);

							tileBytes.set(line * meta.size + col, index);
						}
					}
				}

				if (tileBytes.compare(empty) != 0) {
					tiles.push(tileBytes);
				}
			}
		}

		final bytesOutput = new BytesOutput();

		bytesOutput.writeByte(meta.size);
		bytesOutput.writeByte(meta.size);
		bytesOutput.writeInt32(tiles.length);

		for (tile in tiles) {
			bytesOutput.writeBytes(tile, 0, tile.length);
		}

		return new TilesetChunk(name, bytesOutput.getBytes());
	}

	public static function fromAseprite(bytes:Bytes, name:String, ?reuseRepeated:Bool = true):TilesetChunk {
		final ase = ase.Ase.fromBytes(bytes);

		if (ase.header.colorDepth != INDEXED)
			throw 'Only indexed aseprite files are allowed';

		final merged = res.rom.tools.AseTools.merge(ase);

		final tiles:Array<Bytes> = [];

		final tileWidth = ase.header.gridWidth;
		final tileHeight = ase.header.gridHeight;

		if (tileWidth > 256 || tileHeight > 256)
			throw 'Tile cannot be larger than 256px for any dimension';

		final hTiles:Int = Math.floor(ase.width / tileWidth);
		final vTiles:Int = Math.floor(ase.height / tileHeight);

		for (line in 0...vTiles) {
			for (col in 0...hTiles) {
				final tileData = Bytes.alloc(tileWidth * tileHeight);

				for (t_line in 0...tileHeight) {
					final srcPos = ((line * tileHeight) + t_line) * ase.width + (col * tileWidth);
					final dstPos = t_line * tileWidth;

					tileData.blit(dstPos, merged, srcPos, tileWidth);
				}

				var empty:Bool = true;

				for (n in 0...tileData.length) {
					if (tileData.get(n) != 0) {
						empty = false;
						break;
					}
				}

				if (!empty) {
					var exists:Bool = false;

					if (reuseRepeated) {
						for (exTile in tiles) {
							if (exTile.compare(tileData) == 0) {
								exists = true;
								break;
							}
						}

						if (!exists)
							tiles.push(tileData);
					} else
						tiles.push(tileData);
				}
			}
		}

		final bytesOutput = new BytesOutput();

		bytesOutput.writeByte(tileWidth);
		bytesOutput.writeByte(tileHeight);
		bytesOutput.writeInt32(tiles.length);

		for (tileData in tiles) {
			bytesOutput.writeBytes(tileData, 0, tileData.length);
		}

		return new TilesetChunk(name, bytesOutput.getBytes());
	}
	#end
}
