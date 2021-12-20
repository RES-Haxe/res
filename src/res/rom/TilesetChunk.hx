package res.rom;

import sys.io.File;
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

	public static function fromPNG(pngFileName:String, name:String, tileSize:Int, palette:Palette):TilesetChunk {
		final pngData = new Reader(File.read(pngFileName)).read();
		final pngHeader = Tools.getHeader(pngData);

		if (pngHeader.width % tileSize != 0 || pngHeader.height % tileSize != 0)
			throw 'Invalid PNG size: width % ${tileSize} != 0 || height % ${tileSize} != 0';

		final hTiles:Int = Std.int(pngHeader.width / tileSize);
		final vTiles:Int = Std.int(pngHeader.height / tileSize);

		final pixels = Tools.extract32(pngData);

		final empty = Bytes.alloc(tileSize * tileSize);
		empty.fill(0, empty.length, 0);

		final tiles:Array<Bytes> = [];

		for (yTile in 0...vTiles) {
			for (xTile in 0...hTiles) {
				final tileBytes = Bytes.alloc(tileSize * tileSize);

				for (line in 0...tileSize) {
					for (col in 0...tileSize) {
						final srcx = xTile * tileSize + col;
						final srcy = yTile * tileSize + line;
						final pixel:Color = pixels.getInt32((srcy * pngHeader.width + srcx) * 4);

						if (pixel != 0x0) {
							final color = Color.fromRGBA(pixel.g, pixel.b, pixel.a, pixel.r);
							final index = palette.closest(color);

							tileBytes.set(line * tileSize + col, index);
						}
					}
				}

				if (tileBytes.compare(empty) != 0) {
					tiles.push(tileBytes);
				}
			}
		}

		final bytesOutput = new BytesOutput();

		bytesOutput.writeByte(tileSize);
		bytesOutput.writeByte(tileSize);
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
}
