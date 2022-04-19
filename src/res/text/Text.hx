package res.text;

import res.display.FrameBuffer;

using Math;

class Text {
	public var font:Font;
	public var colorMap:ColorMap;
	public var x:Float = 0;
	public var y:Float = 0;

	private var _width:Int = 0;
	private var _height:Int = 0;

	public var text(default, set):String;

	function set_text(val:String) {
		if (text != val) {
			text = val;

			final measure = font.measure(text);

			_width = measure.width;
			_height = measure.height;
		}

		return text;
	}

	/** Text width */
	public var width(get, never):Int;

	function get_width():Int
		return _width;

	/** Text height */
	public var height(get, never):Int;

	function get_height():Int
		return _height;

	public function new(font:Font, text:String = '', ?x:Float = 0, ?y:Float = 0, ?colorMap:ColorMap) {
		this.font = font;
		this.text = text;
		this.colorMap = colorMap;
		this.x = x;
		this.y = y;
	}

	public function render(frameBuffer:FrameBuffer)
		font.draw(frameBuffer, text, x.floor(), y.floor(), colorMap);
}
