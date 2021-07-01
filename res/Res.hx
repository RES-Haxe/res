package res;

import haxe.io.Bytes;

using Math;

class Res {
	private var _resolution:Resolution;
	private var _frameBuffer:Bytes;
	private var _palette:Palette;
	private var _pixelFormat:PixelFormat;
	private var _pixelSize:Int; // bytes
	private var _tileSize:Int;
	private var _hTiles:Int;
	private var _vTiles:Int;

	public var frameBuffer(get, never):Bytes;

	inline function get_frameBuffer():Bytes
		return _frameBuffer;

	public var frameWidth(get, never):Int;

	inline function get_frameWidth():Int {
		switch (_resolution) {
			case TILES(tileSize, hTiles, _):
				return tileSize * hTiles;
		}
	}

	public var frameHeight(get, never):Int;

	function get_frameHeight():Int {
		switch (_resolution) {
			case TILES(tileSize, _, vTiles):
				return tileSize * vTiles;
		}
	}

	public var palette(get, never):Palette;

	inline function get_palette():Palette
		return _palette;

	public var tileSize(get, never):Int;

	inline function get_tileSize():Int {
		return _tileSize;
	}

	public var hTiles(get, never):Int;

	inline function get_hTiles():Int
		return _hTiles;

	public var vTiles(get, never):Int;

	function get_vTiles():Int
		return _vTiles;

	public var pixelFormat(get, never):PixelFormat;

	inline function get_pixelFormat():PixelFormat
		return _pixelFormat;

	public var pixelSize(get, never):Int;

	inline function get_pixelSize():Int
		return _pixelSize;

	public var scene:Scene;

	/**
		@param resolution Tiles size and the number of them horizontally and vertically
		@param palette Global palette
		@param pixelFormat
	 */
	public function new(resolution:Resolution, palette:Palette, pixelFormat:PixelFormat = RGBA) {
		_resolution = resolution;

		switch (resolution) {
			case TILES(tileSize, hTiles, vTiles):
				_tileSize = tileSize;
				_hTiles = hTiles;
				_vTiles = vTiles;
		}

		_palette = palette;
		_pixelFormat = pixelFormat;

		_pixelSize = switch (pixelFormat) {
			case(ARGB | RGBA):
				4;
			case RGB:
				3;
		};

		_frameBuffer = Bytes.alloc(frameWidth * frameHeight * _pixelSize);
	}

	/**
		Clear the frame buffer filling it with a color

		@param colorIndex color index in the palette
	 */
	public function clear(colorIndex:Int = 1) {
		for (pos in 0...frameWidth * frameHeight) {
			_frameBuffer.setInt32(pos * _pixelSize, _palette.get(colorIndex).format(_pixelFormat));
		}
	}

	/**
		Create a tileset
	 */
	public function createTileset():Tileset {
		return new Tileset(this);
	}

	/**
		Create a tile map

		@param tileset Tileset to use
		@param hTiles Number of horizontal tiles (default - number of tiles per screen)
		@param vTiles Number of vertical tiles (default - number of tiles per screen)
		@param paletteSample Palette sample to use
		@param indecies If `paletteSample` isn't set these indecies will be used to create a new palette sample
	 */
	public function createTilemap(tileset:Tileset, ?hTiles:Int, ?vTiles:Int, ?paletteSample:PaletteSample, ?indecies:Array<Int>):Tilemap {
		if (hTiles == null)
			hTiles = this.hTiles;

		if (vTiles == null)
			vTiles = this.vTiles;

		if (paletteSample == null && indecies != null)
			paletteSample = createPaletteSample(indecies);

		return new Tilemap(this, tileset, hTiles, vTiles, paletteSample);
	}

	/**
		Create a text tile map
	 */
	public function createTextmap(fontData:Bytes, srcWidth:Int, srcHeight:Int, characters:String, ?paletteSample:PaletteSample, ?indecies:Array<Int>):Textmap {
		if (paletteSample == null && indecies != null)
			paletteSample = createPaletteSample(indecies);

		return new Textmap(this, hTiles, vTiles, fontData, srcWidth, srcHeight, characters, paletteSample);
	}

	/**
		Create a text tile map using a font
	 */
	public function createTextmapFromFont(font:Font, ?hTiles:Int, ?vTiles:Int, ?paletteSample:PaletteSample, ?indecies:Array<Int>):Textmap {
		return createTextmap(font.data, font.srcWidth, font.srcHeight, font.characters, paletteSample, indecies);
	}

	/**
		Create a palette sample with given color indecies
	 */
	public function createPaletteSample(indecies:Array<Int>):PaletteSample {
		return new PaletteSample(palette, indecies);
	}

	/**
		Create a sprite
	 */
	public function createSprite(tileset:Tileset, xPow:Int = 1, yPow:Int = 1, ?paletteSample:PaletteSample, ?indecies:Array<Int>):Sprite {
		if (paletteSample == null && indecies != null)
			paletteSample = createPaletteSample(indecies);

		return new Sprite(this, tileset, xPow, yPow, paletteSample);
	}

	/**
		Create a sprite list
	 */
	public function createSpriteList(?initialList:Array<Sprite>):SpriteList {
		return new SpriteList(this, initialList);
	}

	/**
		Perform an update

		@param dt Time delta in seconds
	 */
	public function update(dt:Float) {
		if (scene != null)
			scene.update(dt);
	}

	public function render() {
		if (scene != null) {
			for (renderable in scene.renderList) {
				renderable.render(_frameBuffer, frameWidth, frameHeight);
			}
		}
	}
}
