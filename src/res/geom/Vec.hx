package res.geom;

typedef TVec = {
	x:Float,
	y:Float
}

/**
	Vector abstract
**/
abstract Vec(TVec) {
	public var x(get, set):Float;
	public var y(get, set):Float;

	inline function get_x()
		return this.x;

	inline function set_x(v:Float)
		return this.x = v;

	inline function get_y()
		return this.y;

	inline function set_y(v:Float)
		return this.y = v;

	private function new(newV:TVec)
		this = newV;

	/**
		Clone this vector
	**/
	public inline function clone():Vec
		return new Vec({x: this.x, y: this.y});

	/**
		Create a vector from `x` and `y` values

		@param x
		@param y
	**/
	public inline static function xy(?x:Float = 0, ?y:Float = 0)
		return new Vec({x: x, y: y});

	/**
		Wrap an object that matches a TVec ({x: Float, y:Float})
		in a Vec abstract

		@param xy
	 */
	public inline static function of(xy:TVec):Vec
		return new Vec(xy);

	/**
		Sums two 2-component vectors

		@param a
		@param b
	 */
	public inline static function sum(a:TVec, b:TVec)
		return new Vec({
			x: a.x + b.x,
			y: a.y + b.y
		});

	/**
		Convert an array of Floats to a Vector
		Only uses the first two elements of the array

		@param a Array
	 */
	public inline static function arr(a:Array<Float>)
		return new Vec({
			x: a[0],
			y: a[1]
		});

	/**
		Create a Vector from a difference of two vectors (`b - a`)

		@param a Vector
		@param b Vector
	 */
	public static function diff(a:TVec, b:TVec)
		return xy(b.x - a.x, b.y - a.y);

	/**
		Add two vectors

		@param b Vector
	 */
	@:op(A + B)
	public inline function add(b:Vec)
		return new Vec({x: this.x + b.x, y: this.y + b.y});

	/**
		Add vector and modify this vector in place

		@param b Vector
	 */
	@:op(A += B)
	public inline function addm(b:Vec) {
		this.x += b.x;
		this.y += b.y;
		return new Vec(this);
	}

	/**
		Subtract two vectors

		@param b Vector
	 */
	@:op(A - B)
	public inline function sub(b:Vec) {
		return new Vec({x: this.x - b.x, y: this.y - b.y});
	}

	/**
		Subtract vectors and modify this vector in place

		@param b Vector
	 */
	@:op(A -= B)
	public inline function subm(b:Vec) {
		this.x -= b.x;
		this.y -= b.y;
		return new Vec(this);
	}

	/**
		Multiply the vector by a scalar value

		@param scalar Scalar value
	 */
	@:op(A * B)
	public inline function mults(scalar:Float) {
		return new Vec({x: x * scalar, y: y * scalar});
	}

	/**
		Multiply the vector by a scalar value and change it in place

		@param scalar Scalar value
	 */
	@:op(A *= B)
	public inline function multsm(scalar:Float) {
		this.x *= scalar;
		this.y *= scalar;
		return new Vec(this);
	}

	/**
		Cross-product of two vectors

		@param v Vector
	 */
	@:op(A || B)
	public inline function cross(v:Vec):Vec
		return Vec.of({x: this.x * v.y, y: v.x * this.y});

	/**
		Hadamard-product of two vectors

		@param v Vector
	 */
	@:op(A * B)
	public inline function hadamard(v:Vec):Vec
		return Vec.of({x: this.x * v.y, y: v.x * this.y});

	/**
		Calculates the length of the vector
	 */
	public inline function length()
		return Math.sqrt(length2());

	/**
		Calculates the squared length of the vector
	 */
	public inline function length2()
		return this.x * this.x + this.y * this.y;

	/**
		Set the length of the vector

		@param len Length
	 */
	public function normalize(len:Float = 1) {
		final l = length();
		if (l != 0)
			set(this.x / l * len, this.y / l * len);
		else
			set(0);
		return this;
	}

	/**
		Set `x` and `y` of the vector
	 */
	public function set(x:Float, ?y:Float) {
		this.x = x;
		this.y = y == null ? x : y;
		return this;
	}

	/**
		Convert vector to radians
	 */
	public inline function rad():Float
		return Math.atan2(this.y, this.x);

	public inline function toString():String
		return '(${this.x}, ${this.y})';
}
