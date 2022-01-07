package res.rom.converters.tilesets.png;

import format.png.Reader;
import format.png.Tools;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import sys.io.File;

class Converter extends res.rom.converters.Converter {
	var tilesetChunk:TilesetChunk;

	public static function createChunk(filename:String, name:String, tileSize:Int, palette:Palette, ?keepEmpty:Bool = false) {
		final pngData = new Reader(File.read(filename)).read();
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

				if (keepEmpty || tileBytes.compare(empty) != 0) {
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

	override function process(fileName:String, palette:Palette):res.rom.converters.Converter {
		tilesetChunk = createChunk(fileName, makeName(fileName), 8, palette);
		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [tilesetChunk];
	}
}
