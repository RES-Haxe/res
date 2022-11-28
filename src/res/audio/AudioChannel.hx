package res.audio;

import haxe.exceptions.NotImplementedException;
import res.events.Emitter;

abstract class AudioChannel extends Emitter<AudioEvent> {
	abstract public function isEnded():Bool;

	abstract public function isPlaying():Bool;

	abstract public function pause():Void;

	abstract public function resume():Void;

	abstract public function start():Void;

	public function stop():Void {
		emit(ENDED);
	}
}
