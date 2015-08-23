package;

import flixel.FlxG;

class Chupaclicker
{
	public static var SUFFIXES = [
		"",
		"K",
		"M",
		"B",
		"T",
	];

	public static function formatBigNum(bigNum:Float) : String {
		if (bigNum < 0) return "0";
		
		var expThousands = Std.int(Math.log(bigNum) / Math.log(1000));
		var remainder = bigNum / Math.pow(1000, expThousands);
		var wholePart = Std.int(remainder);
		var fullDecimalString = "" + (remainder - wholePart);
		var decimalPart = ".";
		for (i in 0...2) {
			decimalPart += (fullDecimalString.length > (2 + i)) ? fullDecimalString.charAt(i + 2) : "0";
		}		
		var suffix = (expThousands < SUFFIXES.length) ? SUFFIXES[expThousands] : "x10^" + (expThousands * 3);
		return wholePart + decimalPart + suffix;
	}

	// requires a valid Dynamic will all the fields required for idling simulation
	// edits Dynamic in-place
	public static function idle(data:Dynamic, dt:Float, dayLength:Float, nightLength:Float) : Void {
		// advance time in day=
		var prevTimeInDay:Float = data.timeInDay;
		data.timeInDay = (data.timeInDay + dt) % (dayLength + nightLength);
		var transitionedToDay = prevTimeInDay > data.timeInDay;

		// calculate rates
		data.multiplierDtoF = 0;
		data.multiplierL = 0;
		data.rateL = 0;
		data.rateC = 0;
		data.rateW = 0;
		data.rateDtoF = 0;
		data.rateLtoD = 0;
	}
}