package res;

import res.data.CommodorKernalFontData;
import res.devtools.Console;
import res.extra.Splash;
import res.graphics.Graphics;
import res.input.Controller;
import res.input.Keyboard;
import res.input.KeyboardEvent;
import res.input.Mouse;
import res.input.MouseEvent;
import res.platforms.Platform;
import res.rom.Rom;
import res.text.Font;
import res.text.Textmap;
import res.tiles.Tilemap;
import res.tiles.Tileset;

using Math;
using Type;

class RES {
	public final console:Console;
	public final controllers:Map<Int, Controller> = [for (playerNum in 1...5) playerNum => new Controller(playerNum)];
	public final frameBuffer:FrameBuffer;
	public final hTiles:Int;
	public final keyboard:Keyboard;
	public final mouse:Mouse;
	public final palette:Palette;
	public final resolution:Resolution;
	public final tileSize:Int;
	public final vTiles:Int;
	public final fonts:Map<String, Font> = [];
	public final defaultFont:Font;
	public final mainScene:Class<Scene>;

	public final rom:Rom;

	public var showFps:Bool = false;

	private var frameCount:Int = 0;
	private var fpsMeasureTime:Float = 0;
	private var lastFps:Int = 0;
	private var fpsDisplay:Textmap;
	private var platform:Platform;

	private final _scenes:Map<String, Scene> = [];

	private final _sceneHistory:Array<Scene> = [];

	private var _scene:Scene;
	private var _sceneResultCb:Array<Dynamic->Void> = [];

	public var scene(get, never):Scene;

	/** Shorthand for `frameBuffer.frameWidth` */
	public var width(get, never):Int;

	function get_width():Int
		return frameBuffer.frameWidth;

	/** Shorthand for `frameBuffer.frameHeight` */
	public var height(get, never):Int;

	function get_height():Int
		return frameBuffer.frameHeight;

	function get_scene():Scene {
		return _scene;
	}

	/**
		@param resolution Tiles size and the number of them horizontally and vertically
		@param palette Global palette
		@param pixelFormat
	 */
	public function new(?platform:Platform, resolution:Resolution, palette:Array<Int>, mainScene:Class<Scene>, ?pixelFormat:PixelFormat = RGBA, ?rom:Rom) {
		if (palette.length < 2)
			throw 'Too few colors. I mean.. how you\'r gonna display anything if you have only one color?!';

		if (palette.length > 256)
			throw 'Too many colors (>=256)';

		this.resolution = resolution;

		switch (resolution) {
			case TILES(tileSize, hTiles, vTiles):
				this.tileSize = tileSize;
				this.hTiles = hTiles;
				this.vTiles = vTiles;
			case PIXELS(width, height, defaultTIleSize):
				this.tileSize = defaultTIleSize;
				this.hTiles = Math.floor(width / defaultTIleSize);
				this.vTiles = Math.floor(height / defaultTIleSize);
		}

		this.palette = new Palette(palette);

		this.mainScene = mainScene;

		for (controller in controllers) {
			controller.listen((ev) -> if (scene != null) scene.controllerEvent(ev));
		}

		keyboard = new Keyboard(this);
		keyboard.listen(keyboardListener);

		mouse = new Mouse(this);
		mouse.listen(mouseListener);

		var usePixelFormat:PixelFormat = pixelFormat;

		if (platform != null) {
			usePixelFormat = platform.pixelFormat;
		}

		var frameSize:{w:Int, h:Int} = switch (resolution) {
			case TILES(tileSize, hTiles, vTiles):
				{w: hTiles * tileSize, h: vTiles * tileSize};
			case PIXELS(width, height, defaultTIleSize):
				{w: width, h: height}
		};

		frameBuffer = new FrameBuffer(this.palette, frameSize.w, frameSize.h, usePixelFormat);

		this.rom = rom != null ? rom : Rom.empty();

		var _defaultFontTileset = createTileset('font:default', CommodorKernalFontData.H_TILES, CommodorKernalFontData.V_TILES,
			CommodorKernalFontData.TILE_SIZE);
		_defaultFontTileset.fromBytes(CommodorKernalFontData.DATA, CommodorKernalFontData.WIDTH, CommodorKernalFontData.HEIGHT);

		defaultFont = createFont('font:default', _defaultFontTileset,
			' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]↑_✓abcdefghijklmnopqrstuvwxyz£|←▒▓');

		fpsDisplay = createDefaultTextmap([this.palette.brightestIndex]);

		console = new Console(this);
		console.initDefaultCommands();

		if (platform != null)
			connect(platform);

		setScene(Splash);
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

	function mouseListener(event:MouseEvent) {
		if (scene != null) {
			scene.mouseEvent(event);
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
			hTiles = Math.ceil(frameBuffer.frameWidth / defaultFont.tileset.tileSize);

		if (vTiles == null)
			vTiles = Math.ceil(frameBuffer.frameHeight / defaultFont.tileset.tileSize);

		if (indecies == null)
			indecies = [palette.brightestIndex];

		return createTextmap(defaultFont, hTiles, vTiles, indecies);
	}

	/**
		Create a font

		@param name Font name
		@param tileset Tileset to use
		@param characters Supported characters
		@param firstTileIndex Index of the first tile in the tileset
	 */
	public function createFont(?name:String, tileset:Tileset, characters:String, ?firstTileIndex:Int = 0):Font {
		final font = new Font(name, tileset, characters, firstTileIndex);

		if (name != null)
			fonts[name] = font;

		return font;
	}

	/**
		Create graphics

		@param width
		@param height
		@param colorMap
	 */
	public function createGraphics(?width:Int, ?height:Int, ?colorMap:Array<Int>):Graphics {
		return new Graphics(width == null ? this.width : width, height == null ? this.height : height, colorMap == null ? palette.getIndecies() : colorMap);
	}

	/**
		Create a new text map

		@param font
		@param hTiles
		@param vTiles
		@param indecies
	 */
	public function createTextmap(font:Font, ?hTiles:Int, ?vTiles:Int, ?indecies:Array<Int>):Textmap {
		if (hTiles == null)
			hTiles = Math.ceil(frameBuffer.frameWidth / font.tileset.tileSize);

		if (vTiles == null)
			vTiles = Math.ceil(frameBuffer.frameHeight / font.tileset.tileSize);

		if (indecies == null)
			indecies = palette.getIndecies();

		return new Textmap(font.tileset, hTiles, vTiles, font.characters, font.firstTileIndex, indecies);
	}

	/**
		Create a tileset

		@param name Tileset name
		@param hTiles
		@param vTiles
		@param overrideTileSize
	 */
	public function createTileset(?name:String, hTiles:Int, vTiles:Int, ?overrideTileSize:Int):Tileset {
		final tileset = new Tileset(overrideTileSize != null ? overrideTileSize : tileSize, hTiles, vTiles);

		if (name != null)
			rom.tilesets[name] = tileset;

		return tileset;
	}

	/**
		Create a tile map

		@param name Tilemap name
		@param tileset Tileset to use
		@param hTiles Number of horizontal tiles (default - number of tiles per screen)
		@param vTiles Number of vertical tiles (default - number of tiles per screen)
		@param indecies If `paletteSample` isn't set these indecies will be used to create a new palette sample
	 */
	public function createTilemap(?name:String, tileset:Tileset, ?hTiles:Int, ?vTiles:Int, ?indecies:Array<Int>):Tilemap {
		if (hTiles == null)
			hTiles = Math.ceil(frameBuffer.frameWidth / tileset.tileSize);

		if (vTiles == null)
			vTiles = Math.ceil(frameBuffer.frameHeight / tileset.tileSize);

		var tilemap = new Tilemap(tileset, hTiles, vTiles, indecies);

		if (name != null)
			rom.tilemaps[name] = tilemap;

		return tilemap;
	}

	/**
		Connect the platform

		@param platform
	 */
	public function connect(platform:Platform) {
		this.platform = platform;
		platform.connect(this);
	}

	public function poweroff() {
		#if sys
		Sys.exit(0);
		#end
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

	public function pushScene(?sceneClass:Class<Scene>, ?sceneInstance:Scene = null, ?args:Array<Dynamic>, ?forceCreate:Bool = false,
			?historyReplace:Bool = false, onResult:Dynamic->Void):Scene {
		var scene = setScene(sceneClass, sceneInstance, args, forceCreate, historyReplace);
		_sceneResultCb.push(onResult);
		return scene;
	}

	public function popScene(?result:Dynamic) {
		var scene = _sceneHistory.pop();

		if (scene != null)
			_scene = scene;

		var cb = _sceneResultCb.pop();

		if (cb != null) {
			cb(result);
		}
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

		if (platform != null)
			platform.render(this);

		frameCount++;
	}
}

function main() {}
