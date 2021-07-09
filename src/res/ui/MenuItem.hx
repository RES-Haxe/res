package res.ui;

class MenuItem {
	public var text:String;
	public var callback:Void->Void;

	public inline function new(text, callback) {
		this.text = text;
		this.callback = callback;
	}
}
