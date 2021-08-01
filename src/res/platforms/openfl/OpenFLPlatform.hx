#if openfl
package res.platforms.openfl;

import openfl.events.MouseEvent;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.GameInput;

class OpenFLPlatform implements Platform {
	public final pixelFormat:PixelFormat = ARGB;

	public var bitmap:Bitmap;

	var bitmapData:BitmapData;
	var container:DisplayObjectContainer;
	var res:RES;
	var autosize:Bool;
	var lastTime:Int;

	public function new(container:DisplayObjectContainer, autosize:Bool = true) {
		this.container = container;
		this.container.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		this.autosize = autosize;
	}

	function onEnterFrame(e:Event) {
		if (res != null) {
			var currentTime = Lib.getTimer();

			res.update((currentTime - lastTime) / 1000);
			res.render();

			lastTime = currentTime;
		}
	}

	function resize() {
		final s = Math.min(container.stage.stageWidth / res.width, container.stage.stageHeight / res.height);

		bitmap.width = res.width * s;
		bitmap.height = res.height * s;

		bitmap.x = (container.stage.stageWidth - bitmap.width) / 2;
		bitmap.y = (container.stage.stageHeight - bitmap.height) / 2;
	}

	public function connect(res:RES) {
		this.res = res;
		bitmap = new Bitmap(bitmapData = new BitmapData(res.width, res.height, false));
		container.addChild(bitmap);

		container.stage.addEventListener(KeyboardEvent.KEY_DOWN, (event:KeyboardEvent) -> {
			res.keyboard.keyDown(event.keyCode);

			if (event.charCode >= 0x20) {
				res.keyboard.keyPress(event.charCode);
			}
		});

		container.stage.addEventListener(KeyboardEvent.KEY_UP, (event:KeyboardEvent) -> {
			res.keyboard.keyUp(event.keyCode);
		});

		container.stage.addEventListener(MouseEvent.MOUSE_MOVE, (event) -> {
			res.mouse.moveTo(Std.int(event.localX), Std.int(event.localY));
		});

		container.stage.addEventListener(MouseEvent.MOUSE_DOWN, (event) -> {
			res.mouse.push(LEFT);
		});

		container.stage.addEventListener(MouseEvent.MOUSE_UP, (event) -> {
			res.mouse.release(LEFT);
		});

		if (GameInput.isSupported) {}

		if (autosize) {
			container.stage.addEventListener(Event.RESIZE, (_) -> {
				resize();
			});

			resize();
		}

		lastTime = Lib.getTimer();
	}

	public function render(res:RES) {
		bitmapData.lock();
		bitmapData.setPixels(bitmapData.rect, res.frameBuffer.getFrame());
		bitmapData.unlock();
	}
}
#end
