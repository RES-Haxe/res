package res;

abstract ColorMap(Map<Int, Int>) from Map<Int, Int> to Map<Int, Int> {
	public function new(map:Map<Int, Int>) {
		this = map;
	}

	@:arrayAccess
	public inline function get(index:Int) {
		return this.exists(index) ? this[index] : index;
	}

	@:arrayAccess
	public inline function arrayWrite(key:Int, val:Int) {
		this[key] = val;
	}
}
