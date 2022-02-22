package res.text;

import res.display.FrameBuffer;

using Math;

class Text {
	public var font:Font;
	public var text:String;
	public var colorMap:ColorMap;
	public var x:Float = 0;
	public var y:Float = 0;

	public function new(font:Font, text:String, ?x:Float = 0, ?y:Float = 0, ?colorMap:ColorMap) {
		this.font = font;
		this.text = text;
		this.colorMap = colorMap;
		this.x = x;
		this.y = y;
	}

	public function render(frameBuffer:FrameBuffer)
		font.draw(frameBuffer, text, x.floor(), y.floor(), colorMap);
}
