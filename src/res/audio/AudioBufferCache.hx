package res.audio;

class AudioBufferCache {
	final buffers:Map<String, IAudioBuffer> = [];

	final res:RES;

	public function new(res:RES) {
		this.res = res;
		update();
	}

	/**
		Update Audio Buffer Cache

		@param total If `true` - all the buffers will be (re-)created, otherwise only the new ones will be added
	**/
	public function update(total:Bool = false) {
		for (name => audioData in res.rom.audio)
			if (!buffers.exists(name) || total)
				put(name, res.bios.createAudioBuffer(audioData.iterator()));
	}

	public function get(name:String):IAudioBuffer {
		return buffers[name];
	}

	public function put(name:String, audioBuffer:IAudioBuffer) {
		buffers[name] = audioBuffer;
	}
}
