package res;

import format.tools.Inflate;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Path;
import haxe.zip.Reader;
import res.input.Controller;

using Math;

@:expose('Res')
class Res {
	private var _resolution:Resolution;
	private var _frameBuffer:Bytes;
	private var _palette:Palette;
	private var _pixelFormat:PixelFormat;
	private var _pixelSize:Int; // bytes
	private var _tileSize:Int;
	private var _hTiles:Int;
	private var _vTiles:Int;

	public final tilesets:Map<String, Tileset> = [];

	private final _controllers:Array<Controller> = [for (_ in 0...4) new Controller()];

	public var controllers(get, never):Array<Controller>;

	function get_controllers() {
		return _controllers;
	}

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
	public function new(resolution:Resolution, palette:Palette, ?pixelFormat:PixelFormat = RGBA, ?romBytes:Bytes) {
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

		_defaultFontTileset = createTileset('_defaultFont8x8');
		_defaultFontTileset.fromBytes(Inflate.run(Bytes.ofHex('78DACD58018EC3200C8BFFFFE993D695268E0D74DB69ABD4DDD18606B0931822C6059CBFF92EBF8F1BC783F1A698BD7119FF381CF671D11FEABF35A06252FAE3796593D340BB77EF77DD8B1620FDC17CE4E832C68D62C9EDC500C7772EEC919D38FF37E63F7F7F618DE19EF0A7EF38FCD98F1B9E59FFF337321FA189BB35CF0F85CBBDB09A234DFCAA3866625DCFB91D8D5ED9836810AE3EFF0432E62A17685EACD7FF8AF53A4A6614F3309BB97CD9B3540F8C3396881125D0FBDC2778610F7E0EEBE29F26C879C0E165A966E7AFE395717698AFEAD532FE89FF40C259D5B9C6731F2FC1302BFEFF7706D8FD3CCD07349F422F99077A9D5231791AB3BD6B97F834A86ADC8BAB648F74F7F877B944CE43F2D4D1A514D4B48EC3775957CE33B90E56BAD57EC23F8F13D1FD2F626C3EFFF9FA8B6804E47AC73CA7DFC23FD9F77E1D7BC1BB15FF43D7AF64D8F40B3CFFBF7DA9F942E645A9CDC5F39E3F63A20FD6F55CE7798B67D5AB42A96A9DE7B5C4DC7FD731D372DAD6010BFE4DFC8384F96C5B144EBEBA3CC313D13863C3AFDE2EAA2AC9712B75C645AF92CBC3A8282BC87A9984CA0B6E7D5B3C47CD13563FC4B7C33ED1E01AE10F0C69A957CD7EC26D8495F56245041F2D7E5C0FEC98453D107C677D5FC6313D0FA975A79C61B0AE33F95AF95179614F77731E59FABFA53FD4FA6BFF2D1D43D72B5EE726B4E0E257E70BAF2F3E59FFE1FAFF88AEB0072DEB0DFB8B1B99D6EF99D60693EAA6FBF8A7E2CDF8E32DFDE34E49858478497F60A63FA0F675558ACEFD2EF5479DA83F47A8F12F365FB4DEFAA44CE96CD38E725EAD7449C15F9DF995F86AC238A2634FFA4A1CF778FCDF65FAEAF84D1F2B3FEE3FA62107B0')),
			128, 48);

		if (romBytes != null)
			loadROM(romBytes);
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
		Create text map with default font
	 */
	public function createDefaultTextmap(?indecies:Array<Int>):Textmap {
		var paletteSample:PaletteSample;

		if (indecies == null)
			paletteSample = new PaletteSample(palette, palette.indecies);
		else
			paletteSample = new PaletteSample(palette, indecies);

		return new Textmap(this, _defaultFontTileset, hTiles, vTiles,
			' !"#$%&`()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_~abcdefghijklmnopqrstuvwxyz£|←▒▓', paletteSample);
	}

	/**
		Create a tileset
	 */
	public function createTileset(name:String):Tileset {
		if (tilesets.exists(name))
			throw 'Tileset $name already exists';

		final tileset = new Tileset(this);

		tilesets[name] = tileset;

		return tileset;
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

	public function loadROM(romBytes:Bytes) {
		trace('Loading ROM...');

		var files = Reader.readZip(new BytesInput(romBytes));

		for (file in files) {
			var path = file.fileName.split('/');

			if (path[0] == 'tilesets') {
				var newTileset = createTileset(Path.withoutExtension(path[1]));
				newTileset.loadPNG(file.data);
			}
		}
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

	static function main() {}

	var _defaultFontTileset:Tileset;
}
