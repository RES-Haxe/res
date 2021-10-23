package res.audio;

class AudioMixerBase implements IAudioMixer {
	public final playing:Array<AudioChannel> = [];

	var pausedChannels:Array<AudioChannel> = [];

	public function play(buffer:IAudioBuffer, ?loop:Bool = false):AudioChannel {
		final newChannel = createAudioChannel(buffer, loop);
		playing.push(newChannel);
		newChannel.listen((e) -> {
			switch (e) {
				case ENDED:
					playing.remove(newChannel);
			}
		});
		newChannel.start();
		return newChannel;
	}

	public function pause() {
		for (channel in playing) {
			if (channel.isPlaying()) {
				channel.pause();
				pausedChannels.push(channel);
			}
		}
	}

	public function resume() {
		for (channel in pausedChannels) {
			channel.resume();
		}

		pausedChannels.resize(0);
	}

	public function createAudioChannel(buffer:IAudioBuffer, ?loop:Bool):AudioChannel {
		throw new haxe.exceptions.NotImplementedException();
	}
}
