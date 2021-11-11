import res.IFrameBuffer;
import res.Scene;
import res.collisions.Collider;
import res.collisions.CollisionResult;
import res.collisions.Shape;

using res.graphics.Painter;
using res.text.Textmap;
using res.tiles.Tilemap;

class CollisionTest extends Scene {
	var phase:Float = 0;

	var testShape:Shape;
	var circleRadius:Float = 20;

	var text:Textmap;

	var result:CollisionResult = NONE;

	var circleX:Int = 0;
	var circleY:Int = 0;

	override function init() {
		testShape = RECT(Std.int((res.width / 2) * Math.random() + Math.random() * 10), Std.int((res.height / 2) * Math.random() + Math.random() * 10),
			Std.int(50 + Math.random() * 10), Std.int(30 + Math.random() * 10));
		// testShape = CIRCLE(res.width / 2, res.height / 2, 50);
		text = res.createTextmap();
	}

	override function render(frameBuffer:IFrameBuffer) {
		frameBuffer.clear(clearColorIndex);

		var rx:Int = 0;
		var ry:Int = 0;

		switch (testShape) {
			case RECT(cx, cy, w, h):
				rx = Std.int(cx);
				ry = Std.int(cy);
				frameBuffer.rect(Std.int(cx - w / 2), Std.int(cy - h / 2), Std.int(w), Std.int(h), res.rom.palette.brightestIndex);
			case CIRCLE(cx, cy, r):
				rx = Std.int(cx);
				ry = Std.int(cy);
				frameBuffer.circle(rx, ry, Std.int(r), res.rom.palette.brightestIndex);
		}

		frameBuffer.rect(Std.int(circleX - circleRadius), Std.int(circleY - circleRadius), Std.int(circleRadius * 2), Std.int(circleRadius * 2), 2);
		frameBuffer.circle(circleX, circleY, Std.int(circleRadius), res.rom.palette.brightestIndex);

		switch (result) {
			case OFFSET(dx, dy):
				frameBuffer.line(circleX, circleY, Std.int(circleX + dx), Std.int(circleY + dy), 3);
			case NONE:
		}

		frameBuffer.drawTilemap(text);
	}

	override function update(dt:Float) {
		circleX = res.mouse.x;
		circleY = res.mouse.y;
		result = Collider.collide(testShape, CIRCLE(circleX, circleY, circleRadius));

		switch (result) {
			case OFFSET(dx, dy):
				circleX = Std.int(circleX + dx);
				circleY = Std.int(circleY + dy);
			case NONE:
		}

		text.textAt(0, 0, '$result');
	}
}
