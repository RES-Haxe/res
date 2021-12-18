import res.IFrameBuffer;
import res.Scene;
import res.collisions.Collider;
import res.geom.Vector2;
import res.input.ControllerEvent;
import res.text.Textmap;
import res.types.Shape;

using Std;
using res.graphics.Painter;
using res.tiles.Tilemap;
using res.tools.ShapeTools;

class MainScene extends Scene {
	final shapes:Array<{shape:Shape, vector:Vector2}> = [];

	var debugText:Textmap;

	var myShape:Shape = CIRCLE(0, 0, 10);

	var doResolve:Bool = true;

	override function init() {
		debugText = res.createTextmap([0, 8]);

		for (n in 0...30) {
			final cx = Math.floor(256 * Math.random());
			final cy = Math.floor(256 * Math.random());

			if (Math.random() > 0.5) {
				shapes.push({shape: CIRCLE(cx, cy, 3 + Math.floor(Math.random() * 30)), vector: null});
			} else {
				final w = 3 + Math.floor(Math.random() * 30);
				final h = 3 + Math.floor(Math.random() * 30);

				shapes.push({shape: RECT(cx, cy, w, h), vector: null});
			}
		}
	}

	override function controllerEvent(event:ControllerEvent) {
		switch (event) {
			case BUTTON_DOWN(_, button):
				switch (button) {
					case START:
						myShape = switch myShape {
							case CIRCLE(cx, cy, r): RECT(cx, cy, r, r);
							case RECT(cx, cy, w, h): CIRCLE(cx, cy, w);
						};

					case SELECT:
						doResolve = !doResolve;
					case _:
				}
			case _:
		}
	}

	override function update(dt:Float) {
		debugText.clear();

		switch (myShape) {
			case CIRCLE(_, _, r):
				myShape = CIRCLE(res.mouse.x, res.mouse.y, r);
			case RECT(_, _, w, h):
				myShape = RECT(res.mouse.x, res.mouse.y, w, h);
			case _:
		}

		for (item in shapes) {
			final collision = Collider.collide(myShape, item.shape);

			switch (collision) {
				case OFFSET(dx, dy):
					if (item.vector == null)
						item.vector = Vector2.xy(dx, dy);
					else
						item.vector.set(dx, dy);

					if (doResolve) {
						final pos = item.shape.pos();
						item.shape = item.shape.moveTo(pos.x + dx, pos.y + dy);
					}
				case NONE:
					item.vector = null;
			}
		}

		debugText.textAt(0, 0, 'Resolve: $doResolve');
		debugText.textAt(0, 1, 'Shape: $myShape');
	}

	override function render(frameBuffer:IFrameBuffer) {
		frameBuffer.clear(clearColorIndex);

		for (item in shapes) {
			frameBuffer.shape(item.shape, item.vector == null ? 10 : 5);
			if (item.vector != null) {
				final pos = item.shape.pos();
				frameBuffer.line(pos.x.int(), pos.y.int(), (pos.x + item.vector.x).int(), (pos.y + item.vector.y).int(), 3);
			}
		}

		frameBuffer.shape(myShape, 13);

		frameBuffer.drawTilemap(debugText);
	}
}
