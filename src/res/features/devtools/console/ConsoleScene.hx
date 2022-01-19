package res.features.devtools.console;

import res.Scene;
import res.input.Key;
import res.input.KeyboardEvent;
import res.text.Textmap;

using String;
using StringTools;

class ConsoleScene extends Scene {
	static final BLINK_TIME:Float = 1;
	static final CURSOR:String = '_';

	var consoleText:Textmap;

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
		consoleText = res.createTextmap();
		consoleText.scrollY = consoleText.pixelHeight - res.frameBuffer.frameHeight;

		renderList.push(consoleText);

		updateInput('');
	}

	function updateInput(?value:String) {
		if (value != null)
			commandInput = value;

		consoleText.textAt(0, consoleText.vTiles - 1, '>' + commandInput + (blink ? CURSOR : ''));
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

	public function clear() {
		log.resize(0);
		for (line in 0...consoleText.vTiles - 1)
			consoleText.textAt(0, line, '');
	}

	public function println(s:String) {
		var lines:Array<String> = [];

		while (s.length > consoleText.hTiles) {
			lines.push(s.substr(0, consoleText.hTiles));
			s = s.substr(consoleText.hTiles);
		}

		if (s != '')
			lines.push(s);

		for (line in lines)
			log.push(line);

		var line = consoleText.vTiles - 2;
		var index = log.length - 1;

		while (index >= 0 && line >= 0) {
			consoleText.textAt(0, line, log[index]);
			index--;
			line--;
		}
	}

	override function update(dt:Float) {
		if (blinkTimer >= BLINK_TIME) {
			blinkTimer = blinkTimer - BLINK_TIME;
			blink = !blink;
			updateInput();
		} else
			blinkTimer += dt;
	}
}
