package res.ui;

import res.helpers.Funcs.wrapi;

typedef MenuItem = {
	text:String,
	callback:Void->Void
};

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

	function updateText() {
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

	public function addItem(text:String, callback:Void->Void) {
		items.push({
			text: text,
			callback: callback
		});

		updateText();
	}

	public function render(frameBuffer:FrameBuffer) {
		textmap.render(frameBuffer);
	}
}
