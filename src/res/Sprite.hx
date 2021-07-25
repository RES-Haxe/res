package res;

import res.tiles.Tileset;
import haxe.io.Bytes;

class Sprite {
	public final frames:Array<SpriteFrame>;

	public final width:Int;
	public final height:Int;

	public static function fromTiles(tileset:Tileset, useTiles:Array<Array<Array<Int>>>):Sprite {
		var spriteWidth:Null<Int> = null;
		var spriteHeight:Null<Int> = null;

		final frames:Array<SpriteFrame> = [];

		for (frameTiles in useTiles) {
			final vTiles = frameTiles.length;
			final hTiles = frameTiles[0].length;

			if (spriteWidth == null && spriteHeight == null) {
				spriteWidth = hTiles * tileset.tileSize;
				spriteHeight = vTiles * tileset.tileSize;
			} else {
				if (hTiles * tileset.tileSize != spriteWidth || vTiles * tileset.tileSize != spriteHeight) {
					throw 'Invalid frame size';
				}
			}

			final frameData = Bytes.alloc(spriteWidth * spriteHeight);

			for (row in 0...frameTiles.length) {
				for (col in 0...frameTiles[row].length) {
					final tileIndex = frameTiles[row][col];

					for (line in 0...tileset.tileSize) {
						final dstX = col * tileset.tileSize;
						final dstY = row * tileset.tileSize + line;

						frameData.blit(dstY * spriteWidth + dstX, tileset.get(tileIndex).indecies, line * tileset.tileSize, tileset.tileSize);
					}

					frames.push(new SpriteFrame(frameData, 100));
				}
			}
		}

		return new Sprite(spriteWidth, spriteHeight, frames);
	}

	@:allow(res)
	private function new(width:Int, height:Int, ?frames:Array<SpriteFrame>) {
		this.width = width;
		this.height = height;
		this.frames = frames != null ? frames : [];

		for (frame in frames)
			if (frame.data.length != width * height)
				throw 'Invalid frame size';
	}

	public function addFrame(data:Bytes, duration:Int) {
		if (data.length != width * height)
			throw 'Invalid frame size';

		frames.push(new SpriteFrame(data, duration));
	}
}
