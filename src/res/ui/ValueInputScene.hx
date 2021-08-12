package res.ui;

import res.input.Key;
import res.input.KeyboardEvent;
import res.text.Textmap;

class ValueInputScene extends Scene {
	var text:Textmap;

	var enteredValue:String;

	public function new(res:RES, valueName:String = "Value", initial:String = '') {
		super(res);

		enteredValue = initial;

		updateValue();
	}

	function updateValue() {
		text.textCentered(Std.int(text.vTiles / 2 + 1), enteredValue);
	}

	override function keyboardEvent(event:KeyboardEvent) {
		switch (event) {
			case KEY_DOWN(keyCode):
				switch (keyCode) {
					case Key.BACKSPACE:
						enteredValue = enteredValue.substr(0, -1);
						updateValue();
					case Key.ENTER:
						res.popScene(enteredValue);
				}
			case KEY_PRESS(charCode):
				enteredValue += String.fromCharCode(charCode);
				updateValue();
			case _:
		}
	}
}
