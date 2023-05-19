package res.rom;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import res.audio.AudioData;

class AudioChunk extends RomChunk {
	public function new(name, data) {
		super(AUDIO, name, data);
	}

	public function getAudio():AudioData {
		final input = new BytesInput(data);

		final channels = input.readByte();
		final rate = input.readInt32();
		final bps = input.readByte();
		final dataLen = input.readInt32();
		final data = Bytes.alloc(dataLen);
		input.readBytes(data, 0, dataLen);

		return new AudioData(channels, rate, cast bps, data);
	}
}
