package res.text;

import res.display.Bitmap;

using Math;

class Text {
	public var font:Font;
	public var colorMap:IndexMap;
	public var x:Float = 0;
	public var y:Float = 0;
	public var hAlign:Float = 0; // 0 - left, 1 - right, 0.5 center
	public var vAlign:Float = 0; // 0 - left, 1 - right, 0.5 center

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

	public function new(font:Font, text:String = '', ?x:Float = 0, ?y:Float = 0, ?hAlight:Float = 0, ?vAlign:Float = 0, ?colorMap:IndexMap) {
		this.font = font;
		this.text = text;
		this.colorMap = colorMap;
		this.x = x;
		this.y = y;
		this.hAlign = hAlight;
		this.vAlign = vAlign;
	}

	public function render(surface:Bitmap)
		font.drawPivot(surface, text, x.floor(), y.floor(), hAlign, vAlign, colorMap);
}
