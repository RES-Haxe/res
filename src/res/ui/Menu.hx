package res.ui;

import res.text.Textmap;
import res.tools.MathTools.wrapi;

// TODO: Scrolling
class Menu extends Renderable {
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

	public function keyDown(keyCode:Int) {
		switch (keyCode) {
			case 13:
				execute();
			case 38 | 87 | 75:
				selectedIndex--;
			case 40 | 83 | 74:
				selectedIndex++;
		}
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

	override public function render(frameBuffer:FrameBuffer) {
		textmap.render(frameBuffer);
	}
}
