package res.platforms.lincSdl;

import haxe.Timer;
import sdl.Renderer;
import sdl.SDL;
import sdl.Surface;
import sdl.Texture;
import sdl.Window;

class LincSDLPlatform extends Platform {
	var window:Window;
	var res:RES;

	var scale:Int;
	var windowTitle:String;
	var renderer:Renderer;

	var surface:Surface;
	var texture:Texture;

	var rect:SDLRect;

	public function new(?windowTitle:String = 'RES', ?scale:Int = 3) {
		super('LincSDL', RGBA);
		this.windowTitle = windowTitle;
		this.scale = scale;
	}

	override public function connect(res:RES) {
		this.res = res;

		SDL.init(SDL_INIT_EVERYTHING);

		window = SDL.createWindow(windowTitle, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, res.width * scale, res.height * scale,
			SDL_WINDOW_ALLOW_HIGHDPI);
		renderer = SDL.createRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);

		texture = SDL.createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, res.width, res.height);

		rect = {
			x: 0,
			y: 0,
			w: res.width,
			h: res.height
		};

		Timer.delay(() -> {
			run();
		}, 0);
	}

	public function run() {
		var lastTime = Timer.stamp();

		while (true) {
			while (SDL.hasAnEvent()) {
				final event = SDL.pollEvent();

				switch (event.type) {
					case SDL_KEYDOWN:
						res.keyboard.keyDown(event.key.keysym.sym);
					case SDL_KEYUP:
						res.keyboard.keyUp(event.key.keysym.sym);
					case SDL_TEXTINPUT:
						res.keyboard.keyPress(event.text.text.toString().charCodeAt(0));
					case SDL_QUIT:
						res.poweroff();
					case _:
				}
			}
			SDL.renderClear(renderer);

			var currentTime = Timer.stamp();

			res.update(currentTime - lastTime);
			res.render();

			lastTime = currentTime;

			SDL.renderCopy(renderer, texture, null, null);

			SDL.renderPresent(renderer);
		}
	}

	override public function render(res:RES) {
		SDL.updateTexture(texture, rect, res.frameBuffer.getFrame().getData(), res.width * 4);
		// The following doesn't work for whatever reason but should be more efficient
		/*
			if (SDL.lockTexture(texture, rect, res.frameBuffer.getFrame().getData()) > 0) {
				SDL.unlockTexture(texture);
			} else {
				trace(SDL.getError());
				Sys.exit(1);
			}
		 */
	}

	override public function playAudio(id:String) {}
}
