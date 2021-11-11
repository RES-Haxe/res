import res.Scene;
import res.audio.IAudioBuffer;
import res.audio.Note;
import res.audio.Tone;
import res.audio.WaveFunc.sawtooth;
import res.audio.WaveFunc.square;
import res.input.ControllerEvent;
import res.text.Textmap;
import res.tools.MathTools.wrapi;

class MainMenu extends Scene {
	var textmap:Textmap;

	final menuItems:Array<String> = ['1 PLAYER', '2 PLAYERS'];

	var selectedItem:Int = 0;

	var selectSound:IAudioBuffer;
	var startSound:IAudioBuffer;

	override function init() {
		textmap = res.createTextmap();

		textmap.textAt(0, 0, '1UP', [0, 3]);
		textmap.textAt(2, 1, '00');

		textmap.textCentered(0, 'HIGH SCORE', [0, 3], false);
		textmap.textAt(13, 1, '50000');

		selectSound = res.createAudioBuffer(new Tone(sawtooth, Note.A4, 0.05));
		startSound = res.createAudioBuffer(new Tone(square, Note.G4, 0.075));

		updateMenu();

		add(textmap);
	}

	function menuSelect(inc:Int) {
		selectedItem = wrapi(selectedItem + inc, menuItems.length);
		audioMixer.play(selectSound);
		updateMenu();
	}

	override function controllerEvent(event:ControllerEvent) {
		switch (event) {
			case BUTTON_DOWN(controller, button):
				switch (button) {
					case UP:
						menuSelect(-1);
					case DOWN | SELECT:
						menuSelect(1);
					case START:
						audioMixer.play(startSound);
						res.setScene(Game);
					case _:
				}
			case _:
		}
	}

	function updateMenu() {
		for (n => text in menuItems) {
			textmap.textAt(10, 14 + n, '${(n == selectedItem ? '> ' : '  ')}$text');
		}
	}
}
