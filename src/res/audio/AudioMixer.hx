package res.audio;

abstract class AudioMixer {
	public final playing:Array<AudioChannel> = [];

	var pausedChannels:Array<AudioChannel> = [];

	@:allow(res)
	var audioBufferCache:AudioBufferCache; // Will be injected by RES

	/**
		Play an AudioBuffer.

		If the name is given will look for a buffer in an AudioBufferCache.

		@param name Name of an AudioData from rom or a cached AudioBuffer
		@param buffer AudioBuffer to play
		@param loop Whether the audio should be looped (default: `false`)
	 */
	public function play(?name:String, ?buffer:IAudioBuffer, ?loop:Bool = false):AudioChannel {
		if (name != null)
			buffer = audioBufferCache.get(name);

		if (buffer != null) {
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
		} else {
			trace('$name - no such audio buffer');
			return null;
		}
	}

	/**
		Pause all currently playing audio channels
	 */
	public function pause() {
		for (channel in playing) {
			if (channel.isPlaying()) {
				channel.pause();
				pausedChannels.push(channel);
			}
		}
	}

	/**
		Resume all the channels paused by the `AudioMixer.pause()` method
	 */
	public function resume() {
		for (channel in pausedChannels) {
			channel.resume();
		}

		pausedChannels.resize(0);
	}

	/**
		Create an `AudioChannel` from an `IAudioBuffer`

		@param buffer Audio buffer
		@param loop Whether the channel should be looped or not
	 */
	abstract public function createAudioChannel(buffer:IAudioBuffer, ?loop:Bool):AudioChannel;

	/**
		Update Audio Buffer Cache

		@param total If `true` - all the buffers will be (re-)created, otherwise only the new ones will be added
	**/
	public function updateCache(total:Bool = false) {
		audioBufferCache.update(total);
	}
}
