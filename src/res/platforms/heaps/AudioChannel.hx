package res.platforms.heaps;

import hxd.snd.Channel;

class AudioChannel extends res.audio.AudioChannel {
	var channel:Channel;

	public function new(buffer:AudioBuffer, loop:Bool) {
		channel = buffer.play(loop);
	}
}
