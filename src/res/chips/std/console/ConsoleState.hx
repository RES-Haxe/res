package res.chips.std.console;

import res.State;
import res.display.FrameBuffer;
import res.input.Key;
import res.input.KeyboardEvent;

using String;
using StringTools;

class ConsoleState extends State {
	static final BLINK_TIME:Float = 1;
	static final CURSOR:String = '_';

	final commands:Map<String, ConsoleCommand> = [];

	var commandInput:String = '';

	var blinkTimer:Float = 0;
	var blink:Bool = true;

	final log:Array<String> = [];

	final console:Console;

	public function new(console:Console) {
		super();

		this.console = console;
		this.console.println = println;
	}

	override function init() {
		updateInput('');
	}

	function updateInput(?value:String) {
		if (value != null)
			commandInput = value;
	}

	override function keyboardEvent(event:KeyboardEvent) {
		switch (event) {
			case KEY_DOWN(keyCode):
				switch (keyCode) {
					case Key.BACKSPACE:
						updateInput(commandInput.substr(0, -1));
					case Key.ENTER:
						if (commandInput.trim() != '') {
							console.run(commandInput.trim());
							updateInput('');
						}
				}
			case INPUT(text):
				if (text != '`')
					updateInput(commandInput += text);
			case _:
		}
	}

	public function clear()
		log.resize(0);

	public function println(s:String)
		log.push(s);

	override function update(dt:Float) {
		if (blinkTimer >= BLINK_TIME) {
			blinkTimer = blinkTimer - BLINK_TIME;
			blink = !blink;
			updateInput();
		} else
			blinkTimer += dt;
	}

	override function render(fb:FrameBuffer) {
		fb.clear(clearColorIndex);

		final f = res.defaultFont;

		f.draw(fb, '>$commandInput${blink ? CURSOR : ''}', 0, fb.height - f.lineHeight);

		var l = log.length - 1;
		var ly = fb.height - f.lineHeight * 2;

		while (l >= 0) {
			final line = log[l];
			f.draw(fb, line, 0, ly);
			ly -= f.lineHeight;
			if (ly < -f.lineHeight)
				break;
			l--;
		}
	}
}
