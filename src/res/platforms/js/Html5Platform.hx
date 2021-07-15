#if js
package res.platforms.js;

import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import res.platforms.Platform;

class Html5Platform implements Platform {
	var canvas:CanvasElement;
	var ctx:CanvasRenderingContext2D;
	var scale:Int;

	var res:Res;

	var lastTime:Float = 0;

	public function new(?canvas:CanvasElement, ?scale:Int = 4) {
		if (canvas == null) {
			canvas = Browser.document.createCanvasElement();
			Browser.document.body.appendChild(canvas);
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

		Browser.window.requestAnimationFrame(animationFrame);
	}

	// TODO: Hook up gamepads
	public function connect(res:Res) {
		this.res = res;

		canvas.width = res.frameBuffer.frameWidth;
		canvas.height = res.frameBuffer.frameHeight;

		canvas.style.width = '${res.frameBuffer.frameWidth * scale}px';
		canvas.style.height = '${res.frameBuffer.frameHeight * scale}px';

		Browser.window.addEventListener('keydown', (event) -> {
			res.keyboard.keyDown(event.keyCode);
		});

		Browser.window.addEventListener('keypress', (event) -> {
			res.keyboard.keyPress(event.charCode);
		});

		Browser.window.addEventListener('keyup', (event) -> {
			res.keyboard.keyUp(event.keyCode);
		});

		Browser.document.addEventListener('visibilitychange', (event) -> {
			lastTime = Browser.window.performance.now();
		});

		Browser.window.requestAnimationFrame(animationFrame);
	}

	public function render(res:Res) {
		ctx.putImageData(res.frameBuffer.getImageData(), 0, 0);
	}
}
#end
