package res.platforms.openfl;

import openfl.events.Event;
import openfl.media.SoundChannel;

class AudioChannel extends res.audio.AudioChannel {
	var _ended:Bool = false;
	var _playing:Bool = false;
	var _loop:Bool;
	var _position:Float = 0;

	var buffer:AudioBuffer;
	var channel:SoundChannel;

	public function new(buffer:AudioBuffer, loop:Bool = false) {
		this.buffer = buffer;
		_loop = loop;
	}

	override function isEnded():Bool {
		return _ended;
	}

	override function isPlaying():Bool {
		return _playing;
	}

	override function start() {
		play();
	}

	override function pause() {
		_playing = false;
		_position = channel.position;
		channel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		channel.stop();
	}

	override function resume() {
		play();
	}

	override function stop() {
		_playing = false;
		super.stop();
	}

	function play() {
		channel = buffer.sound.play(_position);
		channel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		_playing = true;
	}

	function onSoundComplete(e:Event) {
		if (_loop) {
			_position = 0;
			play();
		} else {
			stop();
		}
	}
}
