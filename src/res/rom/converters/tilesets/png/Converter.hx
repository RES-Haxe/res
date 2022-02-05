package res.rom.converters.tilesets.png;

import format.png.Reader;
import format.png.Tools;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import sys.io.File;

class Converter extends res.rom.converters.Converter {
	var tilesetChunk:TilesetChunk;

	public static function createChunk(filename:String, name:String, tileWidth:Int, tileHeight:Int, palette:Palette, ?keepEmpty:Bool = false) {
		final pngData = new Reader(File.read(filename)).read();
		final pngHeader = Tools.getHeader(pngData);

		if (pngHeader.width % tileWidth != 0 || pngHeader.height % tileHeight != 0)
			throw 'Invalid PNG size: width % ${tileWidth} != 0 || height % ${tileHeight} != 0';

		final hTiles:Int = Std.int(pngHeader.width / tileWidth);
		final vTiles:Int = Std.int(pngHeader.height / tileHeight);

		final pixels = Tools.extract32(pngData);

		final empty = Bytes.alloc(tileWidth * tileHeight);
		empty.fill(0, empty.length, 0);

		final tiles:Array<Bytes> = [];

		for (yTile in 0...vTiles) {
			for (xTile in 0...hTiles) {
				final tileBytes = Bytes.alloc(tileWidth * tileHeight);

				for (line in 0...tileHeight) {
					for (col in 0...tileWidth) {
						final srcx = xTile * tileWidth + col;
						final srcy = yTile * tileHeight + line;

						final color = pixels.getInt32((srcy * pngHeader.width + srcx) * 4);

						if (color != 0x0) {
							final pixel:Color32 = new Color32(color, [B, G, R, A]);

							final index = palette.closest(pixel);

							tileBytes.set(line * tileWidth + col, index);
						} else {
							tileBytes.set(line * tileWidth + col, 0);
						}
					}
				}

				if (keepEmpty || tileBytes.compare(empty) != 0) {
					tiles.push(tileBytes);
				}
			}
		}

		final bytesOutput = new BytesOutput();

		bytesOutput.writeByte(tileWidth);
		bytesOutput.writeByte(tileHeight);
		bytesOutput.writeInt32(tiles.length);

		for (tile in tiles) {
			bytesOutput.writeBytes(tile, 0, tile.length);
		}

		return new TilesetChunk(name, bytesOutput.getBytes());
	}

	override function process(fileName:String, palette:Palette):res.rom.converters.Converter {
		tilesetChunk = createChunk(fileName, makeName(fileName), 8, 8, palette);
		return this;
	}

	override function getChunks():Array<RomChunk> {
		return [tilesetChunk];
	}
}
