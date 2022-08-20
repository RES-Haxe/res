package res.chips.std.console;

import res.State;
import res.display.FrameBuffer;
import res.display.Painter.rect;
import res.input.Key;
import res.input.KeyboardEvent;
import res.timeline.Timeline;
import res.tools.MathTools.lerp;

using String;
using StringTools;

class ConsoleState extends State {
	static final BLINK_TIME:Float = 1;
	static final ROLL_TIME:Float = 0.3;
	static final CURSOR:String = '_';
	static final PROMPT:String = '>';

	var active:Bool = false;

	var backTo:State;

	var commandInput:String = '';

	var blinkTimer:Float = 0;
	var blink:Bool = true;
	var rolling:Bool = false;
	var rollBottom:Int = 0;

	var timeline:Timeline;

	final log:Array<String> = [];
	final console:Console;

	public function new(console:Console) {
		super();

		this.console = console;
		this.console.println = println;
	}

	public function isActive():Bool {
		return active;
	}

	public function rollDown(from:State) {
		backTo = from;
		rolling = true;
		active = true;

		timeline = new Timeline();
		timeline.forWhile(ROLL_TIME, (t, tt) -> {
			rollBottom = Math.floor(lerp(0, res.height / 2, t / tt));
		}, () -> {
			rolling = false;
			timeline = null;
		});
	}

	public function rollUp() {
		if (!rolling) {
			rolling = true;
			timeline = new Timeline();
			timeline.forWhile(ROLL_TIME, (t, tt) -> {
				rollBottom = Math.floor(lerp(res.height / 2, 0, t / tt));
			}, () -> {
				rolling = false;
				timeline = null;
				active = false;
				res.popState();
			});
		}
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

		if (timeline != null)
			timeline.update(dt);
	}

	override function render(fb:FrameBuffer) {
		backTo.render(fb);

		rect(fb, 0, 0, fb.width, rollBottom, clearColorIndex, clearColorIndex);

		final f = res.defaultFont;

		f.draw(fb, '$PROMPT$commandInput${blink ? CURSOR : ''}', 0, rollBottom - f.lineHeight);

		var l = log.length - 1;
		var ly = rollBottom - f.lineHeight * 2;

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
