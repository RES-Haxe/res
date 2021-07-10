package res.devtools;

import res.input.Key;

using String;
using StringTools;

typedef ConsoleCommandFunc = Array<String>->Void;

typedef ConsoleCommand = {
	cmd:String,
	help:String,
	callback:ConsoleCommandFunc
};

class Console extends Scene {
	static final BLINK_TIME:Float = 1;
	static final CURSOR:String = '_';

	var consoleText:Textmap;

	final commands:Map<String, ConsoleCommand> = [];

	var commandInput:String = '';

	var blinkTimer:Float = 0;
	var blink:Bool = true;

	final log:Array<String> = [];

	function updateInput(?value:String) {
		if (value != null)
			commandInput = value;

		consoleText.textAt(0, consoleText.vTiles - 1, '>' + commandInput + (blink ? CURSOR : ''));
	}

	@:allow(res)
	private function new(res:Res) {
		super(res);

		addCommand('clear', 'Clear console', clear);
		addCommand('help', 'Show help for commands', help);
		addCommand('exit', 'Exit console', (_) -> {
			res.popScene();
		});

		consoleText = res.createDefaultTextmap([res.palette.brightestIndex]);

		consoleText.scrollY = consoleText.pixelHeight - res.frameBuffer.frameHeight;

		renderList.push(consoleText);

		updateInput('');
	}

	override function keyDown(keyCode:Int) {
		switch (keyCode) {
			case Key.BACKSPACE:
				updateInput(commandInput.substr(0, -1));
			case Key.ENTER:
				if (commandInput.trim() != '') {
					execute(commandInput.trim());
					updateInput('');
				}
			case Key.ESCAPE:
				res.popScene();
		}
	}

	override function keyPress(charCode:Int) {
		if (charCode != '`'.code)
			updateInput(commandInput += charCode.fromCharCode());
		else
			res.popScene();
	}

	public function clear(?params:Array<String>) {
		log.resize(0);
		for (line in 0...consoleText.vTiles - 1)
			consoleText.textAt(0, line, '');
	}

	function help(params:Array<String>) {
		for (cmd in commands) {
			if (params.length == 0 || params.indexOf(cmd.cmd) != -1) {
				println('${cmd.cmd}');
				println('  ${cmd.help}');
				println(' ');
			}
		}
		println('----');
		println('Press ESC to close console');
	}

	public function addCommand(cmd:String, ?help:String, cb:ConsoleCommandFunc) {
		commands[cmd] = {
			cmd: cmd,
			help: help,
			callback: cb
		};
	}

	public function execute(cmdStr:String) {
		var parts = cmdStr.split(' ').map(s -> s.trim()).filter(s -> s != '');

		var cmd = parts.shift();

		if (commands[cmd] != null) {
			commands[cmd].callback(parts);
		} else {
			println('Unknown command `$cmd`');
		}
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
