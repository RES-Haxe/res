import res.Scene;
import res.audio.IAudioBuffer;
import res.audio.Note;
import res.audio.Tone;
import res.audio.WaveFunc.sawtooth;
import res.audio.WaveFunc.square;
import res.input.ControllerEvent;
import res.text.Textmap;
import res.tools.MathTools.wrapi;

using StringTools;

class MainMenu extends Scene {
	var textmap:Textmap;

	final menuItems:Array<String> = ['START GAME'];

	var selectedItem:Int = 0;

	var selectSound:IAudioBuffer;
	var startSound:IAudioBuffer;

	override function init() {
		textmap = res.createTextmap();

		textmap.textAt(0, 0, '1UP', [0, 3]);
		textmap.textAt(2, 1, '${Game.sessionScore}'.lpad('0', 2));

		textmap.textCentered(0, 'HIGH SCORE', [0, 3], false);
		textmap.textCentered(1, '${res.storage.getInt('high_score', 50000)}', false);

		textmap.textCentered(26, '(c) TAITO CORPORATION 1987');
		textmap.textCentered(27, 'LICENSED BY');
		textmap.textCentered(28, 'NINTENDO OF AMERICA INC.');
		textmap.textCentered(29, 'Made with RES 2021');

		selectSound = res.createAudioBuffer(new Tone(sawtooth, Note.A4, 0.05));
		startSound = res.createAudioBuffer(new Tone(square, Note.G4, 0.075));

		updateMenu();

		add(textmap);
		add(res.rom.sprites['logo'].createObject(67, 57));
		add(res.rom.sprites['taito_logo'].createObject(92, 169));
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
						res.setScene(Game, true);
					case _:
				}
			case _:
		}
	}

	function updateMenu() {
		for (n => text in menuItems) {
			textmap.textCentered(15 + n, '${(n == selectedItem ? '> ' : '  ')}$text');
		}
	}
}
