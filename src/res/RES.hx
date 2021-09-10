package res;

import haxe.Rest;
import haxe.Timer;
import res.FrameBuffer;
import res.features.Feature;
import res.graphics.Graphics;
import res.input.Controller;
import res.input.Keyboard;
import res.input.Mouse;
import res.platforms.Platform;
import res.rom.Rom;
import res.text.Font;
import res.text.Textmap;
import res.tiles.Tilemap;
import res.tiles.Tileset;
import res.types.RESConfig;

using Math;
using Type;

typedef RenderHookFunction = RES->FrameBuffer->Void;

typedef RenderHooks = {
	before:Array<RenderHookFunction>,
	after:Array<RenderHookFunction>
};

@:build(res.Macros.ver())
class RES {
	public final controllers:Map<Int, Controller> = [for (playerNum in 1...5) playerNum => new Controller(playerNum)];
	public final frameBuffer:FrameBuffer;
	public final keyboard:Keyboard;
	public final mouse:Mouse;
	public final resolution:Resolution;
	public final fonts:Map<String, Font> = [];
	public final mainScene:Class<Scene>;
	public final renderHooks:RenderHooks = {
		before: [],
		after: []
	};
	public var lastFrameTime:Float = 0;

	public final rom:Rom;

	public var defaultFont:Font;

	private var features:Map<String, Feature> = [];
	private var platform:Platform;
	private var prevFrameTime:Null<Float> = null;

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

	function get_scene():Scene
		return _scene;

	/**
	 */
	private function new(platform:Platform, resolution:Resolution, mainScene:Class<Scene>, rom:Rom, ?features:Array<Class<Feature>>) {
		this.resolution = resolution;
		this.mainScene = mainScene;

		for (controller in controllers)
			controller.listen((ev) -> if (scene != null) scene.controllerEvent(ev));

		keyboard = new Keyboard(this);
		keyboard.listen((event) -> {
			if (scene != null)
				scene.keyboardEvent(event);
		});

		mouse = new Mouse(this);
		mouse.listen((event) -> {
			if (scene != null)
				scene.mouseEvent(event);
		});

		var frameSize:{w:Int, h:Int} = switch (resolution) {
			case TILES(tileSize, hTiles, vTiles):
				{w: hTiles * tileSize, h: vTiles * tileSize};
			case PIXELS(width, height):
				{w: width, h: height}
		};

		frameBuffer = new FrameBuffer(rom.palette, frameSize.w, frameSize.h, platform.pixelFormat);

		this.rom = rom;

		connect(platform);

		if (features != null)
			this.enable(...features);

		#if !skipSplash
		setScene(res.extra.Splash);
		#else
		if (mainScene != null)
			setScene(mainScene);
		#end
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
		return new Graphics(width == null ? this.width : width, height == null ? this.height : height,
			colorMap == null ? rom.palette.getIndecies() : colorMap);
	}

	/**
		Create a new text map

		@param font
		@param hTiles
		@param vTiles
		@param indecies
	 */
	public function createTextmap(?font:Font, ?hTiles:Int, ?vTiles:Int, ?indecies:Array<Int>):Textmap {
		if (font == null)
			if (defaultFont != null)
				font = defaultFont;
			else
				throw 'No default font';

		if (hTiles == null)
			hTiles = Math.ceil(frameBuffer.frameWidth / font.tileset.tileSize);

		if (vTiles == null)
			vTiles = Math.ceil(frameBuffer.frameHeight / font.tileset.tileSize);

		if (indecies == null)
			indecies = rom.palette.getIndecies();

		return new Textmap(font.tileset, hTiles, vTiles, font.characters, font.firstTileIndex, indecies);
	}

	/**
		Create a tileset

		@param name Tileset name
		@param hTiles
		@param vTiles
		@param overrideTileSize
	 */
	public function createTileset(?name:String, hTiles:Int, vTiles:Int, tileSize:Int):Tileset {
		final tileset = new Tileset(tileSize, hTiles, vTiles);

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

	/**
		Enable features
	 */
	public function enable(...features:Class<Feature>) {
		for (featureClass in features) {
			final className = featureClass.getClassName();
			this.features[className] = featureClass.createInstance([]);
			this.features[className].enable(this);
		}
	}

	public function feature<T>(featureClass:Class<T>):T
		return cast features[featureClass.getClassName()];

	public function hasFeature(?featureClass:Class<Feature>, ?featureClassName:String):Bool {
		if (featureClass != null)
			featureClassName = featureClass.getClassName();

		if (featureClassName != null)
			return features.exists(featureClassName);

		return false;
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

		if (cb != null)
			cb(result);
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
		for (func in renderHooks.before)
			func(this, frameBuffer);

		if (scene != null)
			scene.render(frameBuffer);

		for (func in renderHooks.after)
			func(this, frameBuffer);

		platform.render(this);

		final currentStamp = Timer.stamp();

		if (prevFrameTime != null)
			lastFrameTime = currentStamp - prevFrameTime;

		prevFrameTime = currentStamp;
	}

	public function playAudio(id:String) {
		platform.playAudio(id);
	}

	public static function boot(config:RESConfig):RES {
		return new RES(config.platform, config.resolution, config.mainScene, config.rom, config.features);
	}
}

function main() {}
