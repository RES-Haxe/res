package res.platforms.hlsdl;

import sdl.GL;
import sdl.Sdl;
import haxe.Timer;
import sdl.Window;

class HLSDLPlatform extends Platform {
	var window:Window;

	var windowTitle:String;

	var scale:Int;

	public function new(windowTitle:String = 'RES', scale:Int = 3) {
		super(RGBA);

		this.windowTitle = windowTitle;
		this.scale = scale;
	}

	override public function connect(res:RES) {
		window = new Window(windowTitle, res.width * scale, res.height * scale);

		GL.clearColor(1.0, 0.0, 0.0, 1.0);

		Timer.delay(mainLoop, 0);
	}

	function mainLoop() {
		while (true) {
			GL.clear(GL.COLOR_BUFFER_BIT);
			Sdl.delay(16);
		}
	}

	override public function render(res:RES) {}

	override public function playAudio(id:String) {}
}
