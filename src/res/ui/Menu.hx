package res.ui;

import res.helpers.Funcs.wrapi;

// TODO: Scrolling
class Menu implements Renderable {
	public final textmap:Textmap;

	var items:Array<MenuItem> = [];

	public var selectedIndex(default, set):Int = 0;

	function set_selectedIndex(val:Int) {
		selectedIndex = wrapi(val, items.length);

		updateText();

		return selectedIndex;
	}

	public function new(textmap:Textmap) {
		this.textmap = textmap;
	}

	public function updateText() {
		for (line in 0...textmap.vTiles) {
			if (line < items.length) {
				textmap.textAt(0, line, (selectedIndex == line ? '>' : ' ') + items[line].text);
			} else
				break;
		}
	}

	public function execute() {
		items[selectedIndex].callback();
	}

	public function addItem(text:String, callback:Void->Void) {
		var menuItem = new MenuItem(text, callback);
		items.push(menuItem);

		updateText();

		return menuItem;
	}

	public function render(frameBuffer:FrameBuffer) {
		textmap.render(frameBuffer);
	}
}
