package res.audio;

class AudioDataStream implements IAudioStream {
	public var numChannels:Int;
	public var sampleRate:Int;
	public var numSamples:Int;

	var _pos:Int = 0;
	var _data:AudioData;

	public function new(data:AudioData) {
		_data = data;

		numChannels = data.channels;
		numSamples = data.length;
		sampleRate = data.rate;
	}

	public function hasNext():Bool {
		return _pos < _data.length;
	}

	public function next():{key:Int, value:Array<Float>} {
		return {key: _pos, value: [for (n in 0..._data.channels) _data.getSampleFloat(n, _pos++)]};
	}
}
