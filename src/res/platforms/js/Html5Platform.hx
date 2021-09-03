package res.platforms.js;

import js.Browser.document;
import js.Browser.window;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.KeyboardEvent;
import js.html.PointerEvent;
import res.platforms.Platform;

using Math;

class Html5Platform implements Platform {
	public final pixelFormat:PixelFormat = ARGB;

	var canvas:CanvasElement;
	var ctx:CanvasRenderingContext2D;
	var scale:Int;

	var res:RES;

	var lastTime:Float = 0;

	public function new(?canvas:CanvasElement, ?scale:Int = 4) {
		if (canvas == null) {
			canvas = document.createCanvasElement();
			document.body.appendChild(canvas);
		}

		this.scale = scale;

		this.canvas = canvas;
		this.canvas.style.imageRendering = 'pixelated';

		this.ctx = this.canvas.getContext2d();
	}

	function animationFrame(time:Float) {
		final dt:Float = (time - lastTime) / 1000;

		lastTime = time;

		res.update(dt);
		res.render();

		window.requestAnimationFrame(animationFrame);
	}

	// TODO: Hook up gamepads
	public function connect(res:RES) {
		this.res = res;

		canvas.width = res.frameBuffer.frameWidth;
		canvas.height = res.frameBuffer.frameHeight;

		canvas.style.width = '${res.frameBuffer.frameWidth * scale}px';
		canvas.style.height = '${res.frameBuffer.frameHeight * scale}px';

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
			event.preventDefault();
		});

		window.addEventListener('keyup', (event:KeyboardEvent) -> {
			res.keyboard.keyUp(event.keyCode);
			event.preventDefault();
		});

		document.addEventListener('visibilitychange', (event) -> {
			lastTime = window.performance.now();
		});

		window.requestAnimationFrame(animationFrame);
	}

	public function render(res:RES) {
		ctx.putImageData(res.frameBuffer.getImageData(), 0, 0);
	}
}
