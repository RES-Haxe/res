package res.extra;

import haxe.io.BytesOutput;
import res.FrameBuffer;
import res.text.Font;
import res.tiles.Tilemap;
import res.tiles.Tileset;
import res.timeline.Timeline;
import res.tools.MathTools.wrap;

using Std;
using res.Paint;
using res.Sprite;

class Splash extends State {
	static final TIME:Int = 1;
	static final BAR_SIZE:Int = 8;

	final stateFn:Void->State;

	var font:Font;
	var phase:Float = 0;
	var timeline = new Timeline();

	var bgMap:Tilemap;

	public function new(res, stateFn:Void->State) {
		super(res);
		this.stateFn = stateFn;

		timeline.after(TIME, (_) -> {
			final state = stateFn();
			if (state != null)
				res.setState(state, true);
		});

		font = res.rom.fonts['num'];

		if (font == null)
			font = res.defaultFont;

		final tilesBytes = new BytesOutput();

		for (index in res.rom.palette.indecies) {
			for (_ in 0...BAR_SIZE)
				for (_ in 0...BAR_SIZE)
					tilesBytes.writeByte(index);
		}

		final tileset = new Tileset(BAR_SIZE, BAR_SIZE, tilesBytes.getBytes());

		bgMap = new Tilemap(tileset, res.rom.palette.numColors, 1, res.width, res.height);

		bgMap.rasterInrpt = (screenLine, _) -> {
			bgMap.scrollX = Math.sin(phase + Math.PI * (screenLine / res.height * (res.height / 64))) * 16;
			return NONE;
		};

		for (c in 0...res.rom.palette.indecies.length)
			bgMap.set(c, 0, c);
	}

	override function update(dt:Float) {
		timeline.update(dt);
		phase = wrap(phase + Math.PI * dt, Math.PI * 2);
	}

	override function render(frameBuffer:FrameBuffer) {
		frameBuffer.clear(clearColorIndex);

		bgMap.render(frameBuffer);

		final sp = res.rom.sprites['splash'];

		final bg = res.rom.palette.darkest;

		frameBuffer.circle((frameBuffer.width / 2).int(), (frameBuffer.height / 2 + 2).int(), 25, bg, bg);

		frameBuffer.sprite(sp, Std.int((frameBuffer.width - sp.width) / 2), Std.int((frameBuffer.height - sp.height) / 2));

		if (font != null)
			font.drawPivot(frameBuffer, 'v${RES.VERSION}', Std.int(frameBuffer.width / 2), Std.int(frameBuffer.height / 2 + sp.height / 2) + 2, 0.5, 0);
	}
}
