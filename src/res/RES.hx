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

typedef RenderHookFunction = RES->FrameBuffer->Void;

typedef RenderHooks = {
	before:Array<RenderHookFunction>,
	after:Array<RenderHookFunction>
};

class PseudoState extends State {
	final pstate:{
		function render(fb:FrameBuffer):Void;
		function update(dt:Float):Void;
	};

	public function new(pstate:{
		function render(fb:FrameBuffer):Void;
		function update(dt:Float):Void;
	}) {
		super();

		this.pstate = pstate;
	}

	override function update(dt:Float) {
		pstate.update(dt);
	}

	override function render(fb:FrameBuffer) {
		pstate.render(fb);
	}
}

class RES {
	public static final VERSION:String = '0.1.1';

	public final config:RESConfig;

	/** Default controller used by the Player 1 **/
	public final controller:Controller;

	/** All connected controllers */
	public final controllers:Array<Controller> = [];

	public final keyboard:Keyboard;
	public final mouse:Mouse;
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

	private final _stateHistory:Array<State> = [];

	private var _state:State;
	private var _stateResultCb:Array<Dynamic->Void> = [];

	public var state(get, never):State;

	public final frameBuffer:FrameBuffer;

	private var _width:Int;

	/** Shorthand for `platform.frameBuffer.width` */
	public var width(get, never):Int;

	function get_width():Int
		return _width;

	private var _height:Int;

	/** Shorthand for `platform.frameBuffer.height` */
	public var height(get, never):Int;

	function get_height():Int
		return _height;

	function get_state():State
		return _state;

	private function new(bios:BIOS, config:RESConfig) {
		this.config = config;

		if (config.resolution.length != 2)
			throw 'Resolution must have exactly two elements for width and height';

		controller = new Controller("player1");
		connectController(controller);

		keyboard = new Keyboard(this);
		keyboard.listen((event) -> {
			if (state != null)
				state.keyboardEvent(event);
		});

		mouse = new Mouse(this);
		mouse.listen((event) -> {
			if (state != null)
				state.mouseEvent(event);
		});

		this.rom = config.rom;

		_width = config.resolution[0];
		_height = config.resolution[1];

		this.bios = bios;
		this.bios.connect(this);
		this.frameBuffer = bios.createFrameBuffer(_width, _height, rom.palette);
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
		Creates a state from an object that has `render` and `update` methods.

		If it is already an instance of a `State` than just return it

		@param pstate An object with a `render` and an `update` function
	 */
	private function ensureState(pstate:{
		function render(fb:FrameBuffer):Void;
		function update(dt:Float):Void;
	}):State {
		if (Std.isOfType(pstate, State))
			return cast pstate;

		final wstate = new PseudoState(pstate);

		return wstate;
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
		if (state != null)
			state.controllerEvent(event);
	}

	public function reset() {
		for (chip in chips)
			chip.reset();

		#if !skipSplash
		if (rom.sprites.exists('splash')) {
			setState(new res.extra.Splash(() -> config.main != null ? ensureState(config.main(this)) : null));
		} else {
			if (config.main != null)
				setState(ensureState(config.main(this)));
		}
		#else
		if (config.main != null)
			setState(ensureState(config.main(this)));
		#end
	}

	/**
		Install chips
	 */
	public function install(...chips:Chip) {
		for (chip in chips) {
			final className = chip.getClass().getClassName();
			this.chips[className] = chip;
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
		Set current state

		@param newState State to set
		@param historyReplace Replace the current state in history, instead of adding a new entry
		@param onResult 
	 */
	public function setState(newState:State = null, ?historyReplace:Bool = false, ?onResult:Dynamic->Void):State {
		if (_state != null) {
			_state.leave();
			_state.audioMixer.pause();
			if (historyReplace == false)
				_stateHistory.push(_state);
		}

		_state = newState;

		if (_state.res == null) {
			_state.res = this;
			_state.init();
		}

		_state.enter();
		_state.audioMixer.resume();

		_stateResultCb.push(onResult);

		return _state;
	}

	/**
		Get back to the previous state

		@param result optional payload that will be passed to a callback (if any) given in the `setState method
	 */
	public function popState(?result:Dynamic) {
		var state = _stateHistory.pop();

		if (state != null) {
			_state = state;
			_state.enter();
			_state.audioMixer.resume();

			var cb = _stateResultCb.pop();

			if (cb != null)
				cb(result);
		}
	}

	/**
		Perform an update

		@param dt Time delta in seconds
	 */
	public function update(dt:Float) {
		if (state != null)
			state.update(dt);
	}

	/**
		Produce a frame
	 */
	public function render() {
		frameBuffer.beginFrame();

		for (func in renderHooks.before)
			func(this, frameBuffer);

		if (state != null)
			state.render(frameBuffer);

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
		@param onBooted will be called after the boot
	 */
	public static function boot(bios:BIOS, config:RESConfig, ?onBooted:RES->Void) {
		bios.ready(() -> {
			final res = new RES(bios, config);
			if (onBooted != null)
				onBooted(res);
		});
	}
}

function main() {}
