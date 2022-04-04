package res;

import haxe.Rest;
import haxe.Timer;
import res.audio.AudioBufferCache;
import res.bios.BIOS;
import res.chips.Chip;
import res.display.FrameBuffer;
import res.input.Controller;
import res.input.ControllerEvent;
import res.input.Keyboard;
import res.input.Mouse;
import res.rom.Rom;
import res.storage.Storage;
import res.text.Font;
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
	public static final VERSION:String = '0.1.1';

	public final config:RESConfig;

	/** Default controller used by the Player 1 **/
	public final controller:Controller;

	/** All connected controllers */
	public final controllers:Array<Controller> = [];

	public final keyboard:Keyboard;
	public final mouse:Mouse;
	public final resolution:Resolution;
	public final bios:BIOS;
	public final storage:Storage;
	public final renderHooks:RenderHooks = {
		before: [],
		after: []
	};
	public var lastFrameTime:Float = 0;

	public final rom:Rom;

	public var defaultFont:Font;

	@:allow(res)
	private var audioBufferCache:AudioBufferCache;

	private var chips:Map<String, Chip> = [];
	private var prevFrameTime:Null<Float> = null;

	private final _sceneHistory:Array<Scene> = [];

	private var _scene:Scene;
	private var _sceneResultCb:Array<Dynamic->Void> = [];

	public var scene(get, never):Scene;

	public final frameBuffer:FrameBuffer;

	/** Shorthand for `platform.frameBuffer.width` */
	public var width(get, never):Int;

	function get_width():Int
		return frameBuffer.width;

	/** Shorthand for `platform.frameBuffer.height` */
	public var height(get, never):Int;

	function get_height():Int
		return frameBuffer.height;

	function get_scene():Scene
		return _scene;

	private function new(bios:BIOS, config:RESConfig) {
		this.config = config;

		this.resolution = config.resolution;

		controller = new Controller("player1");
		connectController(controller);

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

		this.bios = bios;
		this.bios.connect(this);
		this.frameBuffer = bios.createFrameBuffer(frameSize.width, frameSize.height, rom.palette);
		this.storage = bios.createStorage();
		this.storage.restore();

		audioBufferCache = new AudioBufferCache(this);

		if (rom.fonts.exists('kernal')) {
			defaultFont = rom.fonts['kernal'];
		} else {
			if (rom.fonts.iterator().hasNext()) {
				defaultFont = rom.fonts.iterator().next();
			}
		}

		if (config.chips != null)
			this.install(...config.chips);

		reset();
	}

	/**
		Creates a scene from an object that has `render` and `update` methods.

		If it is already an instance of a `Scene` than just return it

		@param pscene An object with a `render` and an `update` function
	 */
	private function ensureScene(pscene:{
		function render(fb:FrameBuffer):Void;
		function update(dt:Float):Void;
	}):Scene {
		if (Std.isOfType(pscene, Scene))
			return cast pscene;

		final wscene = new Scene();

		wscene.update = pscene.update;
		wscene.render = pscene.render;

		return wscene;
	}

	public function connectController(ctrl:Controller) {
		controllers.push(ctrl);
		ctrl.listen(controllerEvent);
		ctrl.connect();
	}

	public function disconnectController(ctrl:Controller) {
		controllers.remove(ctrl);
		ctrl.disconnect();
		ctrl.disregard(controllerEvent);
	}

	private function controllerEvent(event:ControllerEvent) {
		if (scene != null)
			scene.controllerEvent(event);
	}

	public function reset() {
		#if !skipSplash
		if (rom.sprites.exists('splash')) {
			setScene(new res.extra.Splash(() -> config.main != null ? ensureScene(config.main(this)) : null));
		} else {
			if (config.main != null)
				setScene(ensureScene(config.main(this)));
		}
		#else
		if (config.main != null)
			setScene(ensureScene(config.main(this)));
		#end
	}

	/**
		Install chips
	 */
	public function install(...chips:Class<Chip>) {
		for (chipClass in chips) {
			final className = chipClass.getClassName();
			this.chips[className] = chipClass.createInstance([]);
			this.chips[className].enable(this);
		}
	}

	/**
		Get a chip by it's class name

		@param className Full class name (e.g. `my.package.ClassName`)

		@returns Chip
	 */
	public function getChip(className:String):Chip {
		return chips[className];
	}

	/**
		Access a chip by it's class

		@param chipClass
	 */
	public function chip<T>(chipClass:Class<T>):T {
		return cast getChip(chipClass.getClassName());
	}

	public function hasChip(?chipClass:Class<Chip>, ?chipClassName:String):Bool {
		if (chipClass != null)
			chipClassName = chipClass.getClassName();

		if (chipClassName != null)
			return chips.exists(chipClassName);

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

		@param bios BIOS
		@param config RES Config
		@param config.resolution Screen resolution
		@param config.rom ROM
		@param config.main Entry point function that should return an object that has a `render` and an `update` methods
		@param config.chip An array of initial chips
	 */
	public static function boot(bios:BIOS, config:RESConfig):RES {
		return new RES(bios, config);
	}
}

function main() {}
