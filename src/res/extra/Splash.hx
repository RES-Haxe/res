package res.extra;

import res.data.SplashData;
import res.graphics.Graphics;
import res.timeline.Timeline;
import res.tools.MathTools.wrapi;

class Splash extends Scene {
	final scene:Scene;

	var paletteTest:Graphics;
	var logo:Graphics;

	public function new(scene:Scene) {
		super();

		this.scene = scene;
	}

	override public function init() {
		final indexes = res.rom.palette.byLuminance.slice(0);

		paletteTest = new Graphics(res.frameBuffer.frameWidth, res.frameBuffer.frameHeight, indexes);

		final barHeight:Int = Math.floor(Math.max(2, res.frameBuffer.frameHeight * 0.1));

		for (col in 0...res.frameBuffer.frameWidth) {
			for (t in 0...barHeight) {
				final idx = wrapi(col, indexes.length - 1);
				paletteTest.setPixel(col, t, idx);
				paletteTest.setPixel(col, res.frameBuffer.frameHeight - t - 1, idx);
			}
		}

		add(paletteTest);

		logo = new Graphics(res.frameBuffer.frameWidth, res.frameBuffer.frameHeight, [0, res.rom.palette.brightestIndex]);

		final sx = Math.floor((res.frameBuffer.frameWidth - SplashData.WIDTH) / 2);
		final sy = Math.floor((res.frameBuffer.frameHeight - SplashData.HEIGHT) / 2);

		logo.drawImage(SplashData.DATA, sx, sy, SplashData.WIDTH, SplashData.HEIGHT);

		add(logo);

		var timeline = new Timeline();

		timeline.every((2 / indexes.length) * 0.2, (_) -> {
			paletteTest.colorMap.unshift(paletteTest.colorMap.pop());
		});

		timeline.after(1, (_) -> {
			if (scene != null)
				res.setScene(scene, true);
		});

		add(timeline);
	}
}
