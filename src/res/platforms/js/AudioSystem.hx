package res.platforms.js;

import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import res.audio.AudioSample;

class AudioSystem {
	final buffers:Map<String, AudioBuffer> = [];

	final audioContext:AudioContext;

	public function new() {
		audioContext = new AudioContext();
	}

	public function createBuffer(id:String, sample:AudioSample) {
		final buffer = audioContext.createBuffer(sample.channels, sample.length, sample.rate);

		for (nChan in 0...sample.channels) {
			final buffering = buffer.getChannelData(nChan);

			for (n in 0...sample.length)
				buffering[n] = sample.getSampleFloat(nChan, n);
		}

		buffers[id] = buffer;
	}

	public function playBuffer(id:String) {
		final buffer = buffers[id];

		if (buffer != null) {
			final source = audioContext.createBufferSource();
			source.buffer = buffer;
			source.connect(audioContext.destination);
			source.start();
		}
	}
}
