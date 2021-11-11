package res.platforms.js;

import js.Browser.document;
import js.Browser.navigator;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Gamepad;
import js.html.KeyboardEvent;
import js.html.PointerEvent;
import js.html.audio.AudioContext;
import res.audio.IAudioBuffer;
import res.audio.IAudioMixer;
import res.audio.IAudioStream;

using Math;
using res.tools.ResolutionTools;

class Html5Platform implements IPlatform {
	public final name:String;

	var canvas:CanvasElement;
	var ctx:CanvasRenderingContext2D;
	var scale:Int;

	var res:RES;

	var lastTime:Float = 0;

	var gamepads:Map<Int, Gamepad> = [];

	var audioContext:AudioContext;

	/**
		@param canvas Canvas element. Will create and add a new one if not set
		@param scale Scale of the image
		@param injectCSS Inject CSS to make the canvas look crisp
	 */
	public function new(?canvas:CanvasElement, ?scale:Int = 4, ?injectCSS:Bool = true) {
		name = 'HTML5';

		if (canvas == null) {
			canvas = document.createCanvasElement();
			document.body.appendChild(canvas);
		}

		this.scale = scale;

		this.canvas = canvas;

		if (injectCSS) {
			final canvasStyle = document.createStyleElement();
			canvasStyle.type = 'text/css';
			canvasStyle.innerHTML = 'html, body {margin: 0; padding: 0;} canvas { image-rendering: pixelated; image-rendering: crisp-edges; }';

			document.getElementsByTagName('head').item(0).appendChild(canvasStyle);
		}

		this.ctx = this.canvas.getContext2d();

		this.audioContext = new AudioContext();
	}

	function animationFrame(time:Float) {
		final dt:Float = (time - lastTime) / 1000;

		lastTime = time;

		for (index => gamepad in navigator.getGamepads()) {
			if (gamepad != null) {
				final controller = res.controllers[index + 1];

				controller.buttonState(A, gamepad.buttons[0].pressed);
				controller.buttonState(B, gamepad.buttons[1].pressed);
				controller.buttonState(X, gamepad.buttons[2].pressed);
				controller.buttonState(Y, gamepad.buttons[2].pressed);

				controller.buttonState(SELECT, gamepad.buttons[8].pressed);
				controller.buttonState(START, gamepad.buttons[9].pressed);

				controller.buttonState(DOWN, gamepad.buttons[13].pressed);
				controller.buttonState(LEFT, gamepad.buttons[14].pressed);
				controller.buttonState(UP, gamepad.buttons[12].pressed);
				controller.buttonState(RIGTH, gamepad.buttons[15].pressed);
			}
		}

		res.update(dt);
		res.render();

		window.requestAnimationFrame(animationFrame);
	}

	public function connect(res:RES) {
		this.res = res;

		final frameSize = res.config.resolution.pixelSize();

		canvas.width = frameSize.width;
		canvas.height = frameSize.height;

		canvas.style.width = '${frameSize.width * scale}px';
		canvas.style.height = '${frameSize.height * scale}px';

		canvas.addEventListener('pointermove', (event:PointerEvent) -> {
			res.mouse.moveTo((event.x / scale).floor(), (event.y / scale).floor());
		});

		canvas.addEventListener('pointerdown', (event:PointerEvent) -> {
			res.mouse.push(switch (event.button) {
				case 0: LEFT;
				case 1: MIDDLE;
				case 2: RIGHT;
				case _: LEFT;
			}, (event.x / scale).floor(), (event.y / scale).floor());
		});

		canvas.addEventListener('pointerup', (event:PointerEvent) -> {
			res.mouse.release(switch (event.button) {
				case 0: LEFT;
				case 1: MIDDLE;
				case 2: RIGHT;
				case _: LEFT;
			}, (event.x / scale).floor(), (event.y / scale).floor());
		});

		window.addEventListener('keydown', (event:KeyboardEvent) -> {
			if (event.key.length == 1)
				res.keyboard.keyPress(event.key.charCodeAt(0));

			res.keyboard.keyDown(event.keyCode);
		});

		window.addEventListener('keyup', (event:KeyboardEvent) -> {
			res.keyboard.keyUp(event.keyCode);
		});

		document.addEventListener('visibilitychange', (event) -> {
			lastTime = window.performance.now();
		});

		window.requestAnimationFrame(animationFrame);
	}

	public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer {
		return new Html5AudioBuffer(audioContext, audioStream);
	}

	public function createAudioMixer():IAudioMixer {
		return new Html5AudioMixer(audioContext);
	}

	public function createFrameBuffer(width:Int, height:Int, palette:Palette):IFrameBuffer {
		return new FrameBuffer(width, height, palette, canvas);
	}
}
