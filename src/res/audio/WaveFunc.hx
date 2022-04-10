package res.audio;

/**
	Returns a value between -1 and 1
 */
typedef WaveFunc = Float->Float;

function sine(p:Float):Float
	return Math.sin(Math.PI * 2 * p);

function square(p:Float):Float
	return p < 0.5 ? -1 : 1;

function triangle(p:Float):Float
	return -1 + Math.abs((-1 + p * 2) % 2) * 2;

function sawtooth(p:Float):Float
	return -1 + 2 * p;
