package res;

import haxe.Rest;
import haxe.Timer;
import res.audio.IAudioBuffer;
import res.audio.IAudioStream;
import res.display.FrameBuffer;
import res.features.Feature;
import res.input.Controller;
import res.input.Keyboard;
import res.input.Mouse;
import res.platform.IPlatform;
import res.rom.Rom;
import res.storage.IStorage;
import res.text.Font;
import res.text.Textmap;
import res.tiles.Tilemap;
import res.tiles.Tileset;
import res.types.RESConfig;

using Math;
using Type;
using res.tools.ResolutionTools;

typedef RenderHookFunction = RES->FrameBuffer->Void;

typedef RenderHooks = {
	before:Array<RenderHookFunction>,
	after:Array<RenderHookFunction>
};

class RES {
	public static final VERSION:String = '0.1.0';

	public final config:RESConfig;
	public final controllers:Map<Int, Controller> = [for (playerNum in 1...5) playerNum => new Controller(playerNum)];
	public final keyboard:Keyboard;
	public final mouse:Mouse;
	public final resolution:Resolution;
	public final fonts:Map<String, Font> = [];
	public final platform:IPlatform;
	public final storage:IStorage;
	public final renderHooks:RenderHooks = {
		before: [],
		after: []
	};
	public var lastFrameTime:Float = 0;

	public final rom:Rom;

	public var defaultFont:Font;

	private var features:Map<String, Feature> = [];
	private var prevFrameTime:Null<Float> = null;

	private final _sceneHistory:Array<Scene> = [];

	private var _scene:Scene;
	private var _sceneResultCb:Array<Dynamic->Void> = [];

	public var scene(get, never):Scene;

	public final frameBuffer:FrameBuffer;

	/** Shorthand for `platform.frameBuffer.frameWidth` */
	public var width(get, never):Int;

	function get_width():Int
		return frameBuffer.frameWidth;

	/** Shorthand for `platform.frameBuffer.frameHeight` */
	public var height(get, never):Int;

	function get_height():Int
		return frameBuffer.frameHeight;

	function get_scene():Scene
		return _scene;

	private function new(platform:IPlatform, config:RESConfig) {
		this.config = config;

		this.resolution = config.resolution;

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

		this.rom = config.rom;

		final frameSize = config.resolution.pixelSize();

		this.platform = platform;
		this.platform.connect(this);
		this.frameBuffer = platform.createFrameBuffer(frameSize.width, frameSize.height, rom.palette);
		this.storage = platform.createStorage();

		for (id => audioData in rom.audioData) {
			createAudioBuffer(id, audioData.iterator());
		}

		if (rom.fonts.exists('kernal')) {
			defaultFont = rom.fonts['kernal'];
		} else {
			if (rom.fonts.iterator().hasNext()) {
				defaultFont = rom.fonts.iterator().next();
			}
		}

		if (config.features != null)
			this.enable(...config.features);

		reset();
	}

	public function reset() {
		#if !skipSplash
		if (rom.sprites.exists('res_logo')) {
			setScene(new res.extra.Splash(config.main()));
		} else {
			if (config.main != null)
				setScene(config.main());
		}
		#else
		if (config.scene != null)
			setScene(config.scene);
		#end
	}

	public function createAudioBuffer(?name:String, audioStream:IAudioStream):IAudioBuffer {
		final buffer = platform.createAudioBuffer(audioStream);

		if (name != null) {
			rom.audioBuffers[name] = buffer;
		}

		return buffer;
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
		Create a new text map

		@param font
		@param hTiles
		@param vTiles
		@param colorMap
	 */
	public function createTextmap(?font:Font, ?hTiles:Int, ?vTiles:Int, ?colorMap:ColorMap):Textmap {
		if (font == null)
			if (defaultFont != null)
				font = defaultFont;
			else
				throw 'No default font';

		if (hTiles == null)
			hTiles = Math.ceil(width / font.tileset.tileSize);

		if (vTiles == null)
			vTiles = Math.ceil(height / font.tileset.tileSize);

		return new Textmap(font.tileset, hTiles, vTiles, font.characters, font.firstTileIndex, colorMap);
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
		@param colorMap
	 */
	public function createTilemap(?name:String, tileset:Tileset, ?hTiles:Int, ?vTiles:Int, ?colorMap:ColorMap):Tilemap {
		if (hTiles == null)
			hTiles = Math.ceil(width / tileset.tileSize);

		if (vTiles == null)
			vTiles = Math.ceil(height / tileset.tileSize);

		var tilemap = new Tilemap(tileset, hTiles, vTiles, colorMap);

		if (name != null)
			rom.tilemaps[name] = tilemap;

		return tilemap;
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

	/**
		Get a feature by it's class name

		@param className Full class name (e.g. `my.package.ClassName`)

		@returns Feature
	 */
	public function getFeature(className:String):Feature {
		return features[className];
	}

	/**
		Access a feature with it's class

		@param featureClass
	 */
	public function feature<T>(featureClass:Class<T>):T {
		return cast getFeature(featureClass.getClassName());
	}

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

		@param newScene Scene to set
		@param historyReplace Replace the current scene in history, instead of adding a new entry
		@param onResult 
	 */
	public function setScene(newScene:Scene = null, ?historyReplace:Bool = false, ?onResult:Dynamic->Void):Scene {
		if (_scene != null) {
			_scene.leave();
			_scene.audioMixer.pause();
			if (historyReplace == false)
				_sceneHistory.push(_scene);
		}

		_scene = newScene;

		if (_scene.res == null) {
			_scene.res = this;
			_scene.init();
		}

		_scene.enter();
		_scene.audioMixer.resume();

		_sceneResultCb.push(onResult);

		return _scene;
	}

	/**
		Get pack to the previous scene

		@param result optional payload that will be passed to a callback (if any) given in the `setScene` method
	 */
	public function popScene(?result:Dynamic) {
		var scene = _sceneHistory.pop();

		if (scene != null) {
			_scene = scene;
			_scene.enter();
			_scene.audioMixer.resume();

			var cb = _sceneResultCb.pop();

			if (cb != null)
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
	}

	/**
		Produce a frame
	 */
	public function render() {
		frameBuffer.beginFrame();

		for (func in renderHooks.before)
			func(this, frameBuffer);

		if (scene != null)
			scene.render(frameBuffer);

		for (func in renderHooks.after)
			func(this, frameBuffer);

		frameBuffer.endFrame();

		final currentStamp = Timer.stamp();

		if (prevFrameTime != null)
			lastFrameTime = currentStamp - prevFrameTime;

		prevFrameTime = currentStamp;
	}

	/**
		Boot an RES instance

		@param platform Platform
		@param config RES Config
	 */
	public static function boot(platform:IPlatform, config:RESConfig):RES {
		return new RES(platform, config);
	}
}

function main() {}
