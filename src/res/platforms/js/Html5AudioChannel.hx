package res.platforms.js;

import js.html.audio.AudioBufferSourceNode;
import js.html.audio.AudioContext;
import res.audio.AudioChannel;
import res.tools.MathTools.wrapf;

class Html5AudioChannel extends AudioChannel {
	var source:AudioBufferSourceNode;
	var buffer:Html5AudioBuffer;
	var ctx:AudioContext;
	var loop:Bool;
	var playing:Bool = false;
	var startedTime:Float;
	var playOffset:Float;
	var resumeOffset:Float;
	var ended:Bool = false;

	public function new(ctx:AudioContext, buffer:Html5AudioBuffer, loop:Bool) {
		this.ctx = ctx;
		this.buffer = buffer;
		this.loop = loop;
	}

	override function isEnded():Bool {
		return ended;
	}

	override function isPlaying():Bool {
		return playing;
	}

	override function start() {
		play();
	}

	function play(offset:Float = 0) {
		source = ctx.createBufferSource();
		source.buffer = buffer.buffer;
		source.loop = loop;
		source.addEventListener('ended', onSourceEnded);
		source.connect(ctx.destination);
		source.start(0, offset);

		playOffset = offset;
		startedTime = ctx.currentTime;

		playing = true;
	}

	function onSourceEnded() {
		ended = true;
		emit(ENDED);
	}

	override public function pause() {
		resumeOffset = wrapf(playOffset + (ctx.currentTime - startedTime), buffer.numSamples / buffer.sampleRate);

		source.removeEventListener('ended', onSourceEnded);
		source.stop();
		playing = false;
	}

	override public function resume() {
		if (!playing) {
			play(resumeOffset);
		}
	}

	override function stop() {
		source.stop();
		source.disconnect(ctx.destination);
		playing = false;
		ended = true;
		super.stop();
	}
}
