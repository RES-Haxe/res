package res.platforms.lincSdl;

import sdl.Event.TextInputEvent;
import sdl.Renderer;
import sdl.SDL;
import sdl.Surface;
import sdl.Texture;
import sdl.Window;

class LincSDL implements Platform {
	public final pixelFormat:PixelFormat;

	var window:Window;
	var res:RES;

	var scale:Int;
	var renderer:Renderer;

	var surface:Surface;
	var texture:Texture;

	var rect:SDLRect;

	public function connect(res:RES) {
		this.res = res;
		SDL.init(SDL_INIT_EVERYTHING);

		window = SDL.createWindow('RES', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, res.width * scale, res.height * scale, SDL_WINDOW_ALLOW_HIGHDPI);
		renderer = SDL.createRenderer(window, -1, SDL_RENDERER_ACCELERATED);

		texture = SDL.createTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, res.width, res.height);

		rect = {
			x: 0,
			y: 0,
			w: res.width,
			h: res.height
		};
	}

	public function run() {
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
			SDL.delay(16);

			SDL.renderClear(renderer);

			res.update(60 / 1000);
			res.render();

			SDL.renderCopy(renderer, texture, null, null);

			SDL.renderPresent(renderer);
		}
	}

	public function render(res:RES) {
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

	public function new(scale:Int = 3) {
		this.pixelFormat = RGBA;
		this.scale = scale;
	}
}
