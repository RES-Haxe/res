package res.platforms.openfl;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.GameInput;
import res.audio.IAudioBuffer;
import res.audio.IAudioMixer;
import res.audio.IAudioStream;

class OpenFLPlatform implements IPlatform {
	public var bitmap:Bitmap;

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
		if (bitmap != null && frameBuffer != null) {
			final s = Math.min(container.stage.stageWidth / frameBuffer.frameWidth, container.stage.stageHeight / frameBuffer.frameHeight);

			bitmap.width = frameBuffer.frameWidth * s;
			bitmap.height = frameBuffer.frameHeight * s;

			bitmap.x = (container.stage.stageWidth - bitmap.width) / 2;
			bitmap.y = (container.stage.stageHeight - bitmap.height) / 2;
		}
	}

	public function connect(res:RES) {
		this.res = res;

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
			res.mouse.push(LEFT, Std.int(event.localX), Std.int(event.localY));
		});

		container.stage.addEventListener(MouseEvent.MOUSE_UP, (event) -> {
			res.mouse.release(LEFT, Std.int(event.localX), Std.int(event.localY));
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

	public final name:String = 'OpenFL';

	public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer {
		return new AudioBuffer(audioStream);
	}

	public function createAudioMixer():IAudioMixer {
		return new AudioMixer();
	}

	public function createFrameBuffer(width:Int, height:Int, palette:Palette):FrameBuffer {
		frameBuffer = new FrameBuffer(width, height, palette);

		container.addChild(bitmap = new Bitmap(frameBuffer.bitmapData));

		if (autosize)
			resize();

		return frameBuffer;
	}

	var frameBuffer:FrameBuffer;
}
