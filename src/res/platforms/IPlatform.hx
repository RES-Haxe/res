package res.platforms;

import res.storage.IStorage;
import res.audio.IAudioBuffer;
import res.audio.IAudioMixer;
import res.audio.IAudioStream;

interface IPlatform {
	public final name:String;

	public function connect(res:RES):Void;

	public function createAudioBuffer(audioStream:IAudioStream):IAudioBuffer;

	public function createAudioMixer():IAudioMixer;

	public function createFrameBuffer(width:Int, height:Int, palette:Palette):IFrameBuffer;

	public function createStorage():IStorage;
}
