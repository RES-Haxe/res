package res;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Path;
import haxe.zip.Reader;
import res.data.BuiltInData;
import res.devtools.Console;
import res.devtools.PaletteView;
import res.devtools.TilesetView;
import res.input.Controller;
import res.input.Keyboard;
import res.input.Mouse;

using Math;

@:expose('Res') class Res {
	private var _resolution:Resolution;
	private var _palette:Palette;
	private var _tileSize:Int;
	private var _hTiles:Int;
	private var _vTiles:Int;

	public final frameBuffer:FrameBuffer;
	public final keyboard:Keyboard;

	public final mouse:Mouse;

	public final tilesets:Map<String, Tileset> = [];

	private final _controllers:Array<Controller> = [for (_ in 0...4) new Controller()];

	public var controllers(get, never):Array<Controller>;

	function get_controllers() {
		return _controllers;
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

	private final _sceneHistory:Array<Scene> = [];

	private var _scene:Scene;

	public var scene(get, never):Scene;

	function get_scene():Scene {
		return _scene;
	}

	private var console:Console;

	var defaultFont:BuiltInFontData;

	/**
		@param resolution Tiles size and the number of them horizontally and vertically
		@param palette Global palette
		@param pixelFormat
	 */
	public function new(resolution:Resolution, palette:Palette, ?pixelFormat:PixelFormat = RGBA, ?romBytes:Bytes, ?defaultFont:BuiltInFontData) {
		_resolution = resolution;

		switch (resolution) {
			case TILES(tileSize, hTiles, vTiles):
				_tileSize = tileSize;
				_hTiles = hTiles;
				_vTiles = vTiles;
		}

		_palette = palette;

		var frameSize:{w:Int, h:Int} = switch (resolution) {
			case TILES(tileSize, hTiles, vTiles):
				{w: hTiles * tileSize, h: vTiles * tileSize};
		};

		frameBuffer = new FrameBuffer(palette, frameSize.w, frameSize.h, pixelFormat);

		keyboard = new Keyboard();
		mouse = new Mouse(this);

		this.defaultFont = defaultFont == null ? BuiltInData.FONT_8x8 : defaultFont;
		_defaultFontTileset = createTileset('_defaultFont', this.defaultFont.tileSize);
		_defaultFontTileset.fromBytes(this.defaultFont.data, this.defaultFont.width, this.defaultFont.height);

		console = new Console(this);

		#if sys
		console.addCommand('quit', 'Quit program', (_) -> {
			Sys.exit(0);
		});
		#end

		console.addCommand('about', 'About this game', (_) -> {
			console.println('RES      : v0.1.0'); // TODO: Make dynamic
			console.println('Tile size: ${tileSize}');
			console.println('Resol.   : ${frameBuffer.frameWidth}x${frameBuffer.frameHeight}');
			console.println('Palette  : ${palette.colors.length} col.');
		});

		console.addCommand('palette', 'Show palette', (_) -> {
			setScene(new PaletteView(this, palette));
		});

		console.addCommand('tileset', 'View tileset', (args) -> {
			if (args.length == 0) {
				console.println('Tilesets:');
				for (id => set in tilesets) {
					console.println(' $id (${set.numTiles})');
				}
			} else if (args.length == 1) {
				if (tilesets.exists(args[0])) {
					setScene(new TilesetView(this, tilesets[args[0]]));
				} else {
					console.println('`${args[0]}` 404');
				}
			} else
				console.println('Too many arguments');
		});

		keyboard.listen((event) -> {
			switch (event) {
				case KEY_DOWN(_, charCode):
					if (charCode == '`'.code) {
						if (scene != console)
							setScene(console);
						else
							popScene();
					}
				case _:
			}
		});

		if (romBytes != null)
			loadROM(romBytes);
	}

	/**
		Clear the frame buffer filling it with a color

		@param colorIndex color index in the palette
	 */
	public function clear(colorIndex:Int = 1) {
		frameBuffer.fill(colorIndex);
	}

	/**
		Create text map with default font

		@param indecies color indecies
	 */
	public function createDefaultTextmap(?hTiles:Int, ?vTiles:Int, ?indecies:Array<Int>):Textmap {
		if (hTiles == null)
			hTiles = Math.ceil(frameBuffer.frameWidth / _defaultFontTileset.tileSize);

		if (vTiles == null)
			vTiles = Math.ceil(frameBuffer.frameHeight / _defaultFontTileset.tileSize);

		var paletteSample:PaletteSample;

		if (indecies == null)
			paletteSample = new PaletteSample(palette, palette.getIndecies());
		else
			paletteSample = new PaletteSample(palette, indecies);

		return new Textmap(this, _defaultFontTileset, hTiles, vTiles, defaultFont.characters, paletteSample);
	}

	/**
		Create a new text map
	 */
	public function createTextmap(tileset:Tileset, characters:String, ?hTiles:Int, ?vTiles:Int, ?firstTileIndex:Int = 0, ?paletteSample:PaletteSample,
			?indecies:Array<Int>):Textmap {
		if (hTiles == null)
			hTiles = Math.ceil(frameBuffer.frameWidth / tileset.tileSize);

		if (vTiles == null)
			vTiles = Math.ceil(frameBuffer.frameHeight / tileset.tileSize);

		if (paletteSample == null && indecies == null)
			paletteSample = createPaletteSample(palette.getIndecies());

		if (paletteSample == null && indecies != null)
			paletteSample = createPaletteSample(indecies);

		return new Textmap(this, tileset, hTiles, vTiles, characters, firstTileIndex, paletteSample);
	}

	/**
		Create a tileset

		@param name Tileset name
	 */
	public function createTileset(name:String, ?overrideTileSize:Int):Tileset {
		if (tilesets.exists(name))
			throw 'Tileset $name already exists';

		final tileset = new Tileset(overrideTileSize != null ? overrideTileSize : tileSize);

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
			hTiles = Math.ceil(frameBuffer.frameWidth / tileset.tileSize);

		if (vTiles == null)
			vTiles = Math.ceil(frameBuffer.frameHeight / tileset.tileSize);

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

	public function setScene(scene:Scene, ?replace:Bool = false) {
		if (_scene != null && replace == false)
			_sceneHistory.push(_scene);

		_scene = scene;
	}

	public function popScene():Scene {
		var scene = _sceneHistory.pop();

		if (scene != null)
			_scene = scene;

		return scene;
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
				renderable.render(frameBuffer);
			}
		}
	}

	static function main() {}

	var _defaultFontTileset:Tileset;
}
