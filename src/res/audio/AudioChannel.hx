package res.audio;

import haxe.exceptions.NotImplementedException;
import res.events.Emitter;

class AudioChannel extends Emitter<AudioEvent> {
	public function isEnded():Bool {
		throw new NotImplementedException();
	}

	public function isPlaying():Bool {
		throw new NotImplementedException();
	}

	public function pause():Void {
		throw new NotImplementedException();
	}

	public function resume():Void {
		throw new NotImplementedException();
	}

	public function start():Void {
		throw new NotImplementedException();
	}

	public function stop():Void {
		emit(ENDED);
	}
}
