package;

class BigNum
{
	public static inline var EXP_BASE = 1000;
	public static inline var MAX_EXP = 11;
	public static var SUFFIXES = [ // should be MAX_EXP + 1 suffixes
		"",
		"K",
		"M",
		"B",
		"T",
		"q",
		"Q",
		"s",
		"S",
		"O",
		"N",
		"D",
	];
	public static var EXPS = {
		var exps = new Array<Float>();
		for (i in 0...(MAX_EXP + 1)) {
			exps.push(Math.pow(EXP_BASE, i));
		}
		exps;
	}

	var negative:Bool = false;
	var coefficients:Array<Int>; // each coefficient in the array corresponds to EXP_BASE^index

	// constructor stuff
	function init() {
		this.coefficients = new Array<Int>();
		for (i in 0...MAX_EXP+1) this.coefficients.push(0);
	}  
	public function new() {
		init();
	}
	public static function fromCoefficients(coefficients:Array<Int>, negative:Bool = false) {
		var bigNum = new BigNum();
		var maxIndex = Std.int(Math.max(coefficients.length, MAX_EXP));
		for (i in 0...maxIndex) bigNum.coefficients[i] = coefficients[i];
		bigNum.negative = negative;
		return bigNum;
	}
	public static function fromBigNum(bigNum:BigNum) {
		return fromCoefficients(bigNum.coefficients, bigNum.negative);
	}
	public static function fromNum(val:Float) {
	var negative = val < 0;
	val = Math.abs(val);
		if (val < EXP_BASE) {
			return fromCoefficients([Std.int(Math.abs(val))], negative);
		} else {
			var bigNum = new BigNum();
			for (i in 0...MAX_EXP+1) {
				var exp = MAX_EXP - i;
				var coefficient = Std.int(val / EXPS[exp]);
				val -= coefficient * EXPS[exp];
				bigNum.coefficients[exp] = coefficient;
			}
			bigNum.negative = negative;
			return bigNum;
		}
	}

	// math operator stuff
	public function add(other:BigNum) {
		if (other.negative) {
			return sub(other.neg());
		}

		var newBigNum = fromBigNum(this);
		for (i in 0...MAX_EXP+1) {
			// add
			newBigNum.coefficients[i] += other.coefficients[i];
			// carry overflow up to next exponent
			var overflow = Std.int(newBigNum.coefficients[i] / EXP_BASE);
			if (overflow > 0 && i < MAX_EXP) {
				newBigNum.coefficients[i + 1] += overflow;
			} else if (overflow > 0) {
				// just max the number if we can't go any higher
				newBigNum.coefficients[i] = EXP_BASE - 1;
			}
			// leave remainder at this exponent
			newBigNum.coefficients[i] = newBigNum.coefficients[i] % EXP_BASE;
		}
		return newBigNum;
	}
	public function addNum(val:Float) {
		return add(fromNum(val));
	}
	public function sub(other:BigNum) {
		if (other.negative) {
			return add(other.neg());
		}

		var newBigNum = fromBigNum(this);
		if (compareTo(other) >= 1) {
			// we are bigger than the subtracted value, so we can do a real subtract
			for (i in 0...MAX_EXP+1) {
				// subtract
				newBigNum.coefficients[i] -= other.coefficients[i];
				// underflow
				if (newBigNum.coefficients[i] < 0) {
					var underflow = Std.int(-newBigNum.coefficients[i] / EXP_BASE) + 1;
					// pull extra numbers from the next exponent down to this exponent
					if (i < MAX_EXP) {
						newBigNum.coefficients[i + 1] -= underflow;
						newBigNum.coefficients[i] += underflow * EXP_BASE;
					} else {
						// the other number must be higher than our number for some reason, so just return 0
						return new BigNum();
					}
				}
			}
		} else {
			// if the subtracted value is bigger than us, just return a 0 BigNum, since doing the negative properly is too complicated/unnecessary
			newBigNum = new BigNum();
		}
		return newBigNum;
	}
	public function subNum(val:Float) {
		return sub(fromNum(val));
	}
	public function neg() {
		this.negative = !this.negative;
		return this;
	}

	public function compareTo(other: BigNum) {
		var result = 0;
		for (i in 0...MAX_EXP+1) {
			var exp = MAX_EXP - i;
			if (this.coefficients[exp] > other.coefficients[exp]) result = 1;
			else if (this.coefficients[exp] < other.coefficients[exp]) result = -1;
			else result = 0;

			if (result != 0) {
				return result;
			}
		}
		return result;
	}

	// the rest
	public function toString() {
		var highestExponentIndex = 0;
		for (i in 0...MAX_EXP+1) {
			if (this.coefficients[i] != 0) {
				highestExponentIndex = i;
			}
		}
		var fullDecimalString = "";
		var truncatedDecimalString = "";
		if (highestExponentIndex > 0) {
			fullDecimalString = "" + this.coefficients[highestExponentIndex - 1] / EXP_BASE;
			truncatedDecimalString = ".";
			for (i in 0...2) {
				truncatedDecimalString += (fullDecimalString.length > (2 + i)) ? fullDecimalString.charAt(i + 2) : "0";
			}
		}
		return this.coefficients[highestExponentIndex] + truncatedDecimalString + SUFFIXES[highestExponentIndex];
	}
}