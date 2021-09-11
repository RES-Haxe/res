package res.extra;

import res.data.SplashData;
import res.graphics.Graphics;
import res.timeline.Timeline;
import res.tools.MathTools.wrapi;

class Splash extends Scene {
	final paletteTest:Graphics;
	final logo:Graphics;

	public function new(res:RES) {
		super(res);

		final indexes = res.rom.palette.byLuminance.copy();

		paletteTest = new Graphics(res.frameBuffer.frameWidth, res.frameBuffer.frameHeight, indexes);

		final barHeight:Int = Math.floor(Math.max(2, res.frameBuffer.frameHeight * 0.1));

		for (col in 0...res.frameBuffer.frameWidth) {
			for (t in 0...barHeight) {
				final idx = 1 + wrapi(col, indexes.length);
				paletteTest.setPixel(col, t, idx);
				paletteTest.setPixel(col, res.frameBuffer.frameHeight - t - 1, idx);
			}
		}

		add(paletteTest);

		logo = new Graphics(res.frameBuffer.frameWidth, res.frameBuffer.frameHeight, [res.rom.palette.brightestIndex]);

		final sx = Math.floor((res.frameBuffer.frameWidth - SplashData.WIDTH) / 2);
		final sy = Math.floor((res.frameBuffer.frameHeight - SplashData.HEIGHT) / 2);

		logo.drawImage(SplashData.DATA, sx, sy, SplashData.WIDTH, SplashData.HEIGHT);

		add(logo);

		var timeline = new Timeline();

		timeline.every((2 / indexes.length) * 0.2, (_) -> {
			paletteTest.colorMap.unshift(paletteTest.colorMap.pop());
		});

		timeline.after(1, (_) -> {
			res.setScene(res.mainScene);
		});

		add(timeline);
	}
}
