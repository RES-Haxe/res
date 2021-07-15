package res.ui;

import res.input.Key;
import res.text.Textmap;

class ValueInputScene extends Scene {
	var text:Textmap;

	var enteredValue:String;

	public function new(res:Res, valueName:String = "Value", initial:String = '') {
		super(res);

		enteredValue = initial;

		text = res.createDefaultTextmap([res.palette.brightestIndex]);
		text.textCentered(Std.int(text.vTiles / 2 - 1), valueName);
		renderList.push(text);

		updateValue();
	}

	function updateValue() {
		text.textCentered(Std.int(text.vTiles / 2 + 1), enteredValue);
	}

	override function keyDown(keyCode:Int) {
		switch (keyCode) {
			case Key.BACKSPACE:
				enteredValue = enteredValue.substr(0, -1);
				updateValue();
			case Key.ENTER:
				res.popScene(enteredValue);
		}
	}

	override function keyPress(charCode:Int) {
		enteredValue += String.fromCharCode(charCode);
		updateValue();
	}
}
