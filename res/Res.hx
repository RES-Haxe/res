package res;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.zip.Reader;
import haxe.zip.Tools;
import res.data.BuiltInData;
import res.devtools.Console;
import res.devtools.PaletteView;
import res.devtools.TilesetView;
import res.devtools.sprites.SpritesMenu;
import res.input.Controller;
import res.input.Keyboard;
import res.input.KeyboardEvent;
import res.input.Mouse;

using Math;
using Type;

@:expose('Res') class Res {
	public final console:Console;
	public final controllers:Array<Controller> = [for (_ in 0...4) new Controller()];
	public final frameBuffer:FrameBuffer;
	public final hTiles:Int;
	public final keyboard:Keyboard;
	public final mouse:Mouse;
	public final palette:Palette;
	public final resolution:Resolution;
	public final sprites:Map<String, Sprite> = [];
	public final tileSize:Int;
	public final tilesets:Map<String, Tileset> = [];
	public final vTiles:Int;

	private var _defaultFontTileset:Tileset;
	private var defaultFont:BuiltInFontData;

	private var frameCount:Int = 0;
	private var fpsMeasureTime:Float = 0;
	private var lastFps:Int = 0;
	private var showFps:Bool = false;
	private var fpsDisplay:Textmap;

	private final _scenes:Map<String, Scene> = [];

	private final _sceneHistory:Array<Scene> = [];

	private var _scene:Scene;

	public var scene(get, never):Scene;

	function get_scene():Scene {
		return _scene;
	}

	/**
		@param resolution Tiles size and the number of them horizontally and vertically
		@param palette Global palette
		@param pixelFormat
	 */
	public function new(resolution:Resolution, palette:Array<Int>, ?pixelFormat:PixelFormat = RGBA, ?romBytes:Bytes, ?defaultFont:BuiltInFontData) {
		if (palette.length < 2)
			throw 'Too few colors. I mean.. how you\'r gonna display anything if you have only one color?!';

		if (palette.length > 32)
			throw 'Too many color. Trust me, you don\'t need THAT many';

		this.resolution = resolution;

		switch (resolution) {
			case TILES(tileSize, hTiles, vTiles):
				this.tileSize = tileSize;
				this.hTiles = hTiles;
				this.vTiles = vTiles;
		}

		this.palette = new Palette(palette);

		var frameSize:{w:Int, h:Int} = switch (resolution) {
			case TILES(tileSize, hTiles, vTiles):
				{w: hTiles * tileSize, h: vTiles * tileSize};
		};

		frameBuffer = new FrameBuffer(this.palette, frameSize.w, frameSize.h, pixelFormat);

		keyboard = new Keyboard();
		mouse = new Mouse(this);

		this.defaultFont = defaultFont == null ? BuiltInData.FONT_8x8 : defaultFont;
		_defaultFontTileset = createTileset('_defaultFont', this.defaultFont.tileSize);
		_defaultFontTileset.fromBytes(this.defaultFont.data, this.defaultFont.width, this.defaultFont.height);

		fpsDisplay = createDefaultTextmap([this.palette.brightestIndex]);

		console = new Console(this);

		console.addCommand('fps', 'Show/hide fps', (args) -> {
			showFps = (args[0].toLowerCase() == 'true' || args[0] == '1');
			console.println('Show fps: $showFps');
		});

		#if sys
		console.addCommand('quit', 'Quit program', (_) -> {
			Sys.exit(0);
		});
		#end

		console.addCommand('about', 'About this game', (_) -> {
			console.println('RES      : v0.1.0'); // TODO: Make dynamic
			console.println('Tile size: ${tileSize}');
			console.println('Resol.   : ${frameBuffer.frameWidth}x${frameBuffer.frameHeight}');
			console.println('Palette  : ${this.palette.colors.length} col.');
		});

		console.addCommand('palette', 'Show palette', (_) -> {
			setScene(PaletteView);
		});

		console.addCommand('tileset', 'View tileset', (args) -> {
			if (args.length == 0) {
				console.println('Tilesets:');
				for (id => set in tilesets) {
					console.println(' $id (${set.numTiles})');
				}
			} else if (args.length == 1) {
				if (tilesets.exists(args[0])) {
					setScene(TilesetView, [tilesets[args[0]]]);
				} else {
					console.println('`${args[0]}` 404');
				}
			} else
				console.println('Too many arguments');
		});

		console.addCommand('sprites', 'Sprites', (_) -> {
			setScene(SpritesMenu);
		});

		keyboard.listen(keyboardListener);

		if (romBytes != null)
			loadROM(romBytes);
	}

	function keyboardListener(event:KeyboardEvent) {
		switch (event) {
			case KEY_DOWN(keyCode):
				if (scene != null)
					scene.keyDown(keyCode);

			case KEY_PRESS(charCode):
				if (charCode == '`'.code) {
					if (scene != console)
						setScene(console);
				} else {
					if (scene != null)
						scene.keyPress(charCode);
				}

			case KEY_UP(keyCode):
				if (scene != null)
					scene.keyUp(keyCode);
		}
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
	public function createSprite(name:String, tileset:Tileset, hTiles:Int = 1, vTiles:Int = 1):Sprite {
		var sprite = new Sprite(this, tileset, hTiles, vTiles);
		sprites[name] = sprite;
		return sprite;
	}

	public function loadROM(romBytes:Bytes) {
		trace('Loading ROM...');

		var files = Reader.readZip(new BytesInput(romBytes));

		for (file in files) {
			var path = file.fileName.split('/');

			switch (path[0]) {
				case 'tilesets':
				// TODD
				case 'sprites':
					Tools.uncompress(file);
					var rawData = new BytesInput(file.data);

					final tileSet = createTileset('sprite_${path[1]}', rawData.readByte());
					final numFrames:Int = rawData.readInt32();

					final sprite = createSprite(path[1], tileSet, 1, 1);

					for (nFrame in 0...numFrames) {
						sprite.addFrame([nFrame + 1], rawData.readInt32());

						final tileData = Bytes.alloc(tileSet.tileSize * tileSet.tileSize);

						rawData.readBytes(tileData, 0, tileData.length);
						tileSet.pushTile(tileData);
					}
			}
		}
	}

	/**
		Set current scene

		@param sceneClass Class of the scene to create
		@param sceneInstance Scene instance to set. sceneClass will be ignored is set
		@param args Scene class constructor arguments
		@param forceCreate Force create a new instance, instead of using a cached one
		@param historyReplace Replace the current scene in history, instead of adding a new entry
	 */
	public function setScene(?sceneClass:Class<Scene>, ?sceneInstance:Scene = null, ?args:Array<Dynamic>, ?forceCreate:Bool = false,
			?historyReplace:Bool = false):Scene {
		if (_scene != null && historyReplace == false)
			_sceneHistory.push(_scene);

		var scene:Scene = sceneInstance;

		if (sceneInstance != null)
			sceneClass = scene.getClass();

		var sceneClassName:String = sceneClass.getClassName();

		if (!forceCreate && sceneInstance == null) {
			if (_scenes.exists(sceneClassName))
				scene = _scenes[sceneClassName];
		}

		if (scene == null) {
			if (args == null)
				args = [];

			args.unshift(this);

			scene = sceneClass.createInstance(args);
		}

		_scenes[sceneClassName] = scene;

		return _scene = scene;
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

		if (fpsMeasureTime >= 1) {
			lastFps = frameCount;
			if (showFps)
				fpsDisplay.textAt(0, 0, 'FPS: $lastFps');
			frameCount = 0;
			fpsMeasureTime -= 1;
		} else
			fpsMeasureTime += dt;
	}

	public function render() {
		if (scene != null) {
			scene.render(frameBuffer);
		}

		if (showFps) {
			fpsDisplay.render(frameBuffer);
		}

		frameCount++;
	}

	static function main() {}
}