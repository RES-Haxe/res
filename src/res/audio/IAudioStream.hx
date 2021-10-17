package res.audio;

interface IAudioStream {
	public var numChannels:Int;
	public var sampleRate:Int;
	public var numSamples:Int;

	public function hasNext():Bool;

	public function next():{key:Int, value:Array<Float>};
}
