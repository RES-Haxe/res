package res;

class PaletteSample {
	public var colors(get, never):Array<Color>;

	function get_colors():Array<Color> {
		return [for (idx in _indecies) _palette.get(idx)];
	}

	private var _indecies:Array<Int>;

	public var indecies(get, set):Array<Int>;

	function get_indecies():Array<Int>
		return _indecies;

	function set_indecies(val:Array<Int>) {
		_indecies = val;
		return _indecies;
	}

	private var _palette:Palette;

	public function get(index:Int):Color {
		return _palette.get(_indecies[index]);
	}

	public function new(palette:Palette, indecies:Array<Int>) {
		this._indecies = indecies;
		this._palette = palette;
	}
}
