package res;

import ase.Ase;
import haxe.io.Bytes;

class Tileset {
	var res:Res;

	public final tiles:Array<Tile> = [];

	public var numTiles(get, never):Int;

	function get_numTiles():Int
		return tiles.length;

    @:allow(res)
	private function new(res:Res) {
		this.res = res;
	}

	public inline function get(index:Int):Tile
		return tiles[index];

	/**
		Line by line

		Each byte is an index in a palette sample
	 */
	public function fromBytes(bytes:Bytes, srcWidth:Int, srcHeight:Int) {
		if (bytes.length != srcWidth * srcHeight)
			throw 'Invalid data size: expecting ${srcWidth * srcHeight}, got: ${bytes.length}';

		for (tileY in 0...Std.int(srcHeight / res.tileSize)) {
			for (tileX in 0...Std.int(srcWidth / res.tileSize)) {
				final tile = new Tile(res);
				tile.yank(bytes, srcWidth, srcHeight, tileX * res.tileSize, tileY * res.tileSize);
				tiles.push(tile);
			}
		}
	}

	public function loadAseprite(bytes:Bytes) {
		final ase = Ase.fromBytes(bytes);

		// TODO: Check if the ase file has correct format

		fromBytes(ase.frames[0].cel(0).pixelData, ase.width, ase.height);
	}

	public function createAsepriteTemplate(hTiles:Int, vTiles:Int, paletteSample:PaletteSample):Ase {
		final palette:Array<Int> = paletteSample.colors;
		palette.unshift(0x00000000);

		final spriteWidth:Int = hTiles * res.tileSize;
		final spriteHeight:Int = vTiles * res.tileSize;

		final tpl:Ase = Ase.create(spriteWidth, spriteHeight, INDEXED, palette);
		tpl.header.gridWidth = tpl.header.gridHeight = res.tileSize;
		tpl.addLayer('Tiles');
		return tpl;
	}
}
