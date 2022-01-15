package res.audio;

class AudioBufferCache {
	final buffers:Map<String, IAudioBuffer> = [];

	final res:RES;

	public function new(res:RES) {
		this.res = res;

		for (name => audioData in res.rom.audio)
			put(name, res.platform.createAudioBuffer(audioData.iterator()));
	}

	public function get(name:String):IAudioBuffer {
		return buffers[name];
	}

	public function put(name:String, audioBuffer:IAudioBuffer) {
		buffers[name] = audioBuffer;
	}
}
