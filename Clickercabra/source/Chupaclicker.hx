package;

import flixel.FlxG;

class Chupaclicker
{
	public static inline var CONVERSION_INTERAL = 3.0; // seconds between processing each conversion
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
		var isDaytime = data.timeInDay < dayLength;
		var isNighttime = !isDaytime;
		var transitionedToDay = prevTimeInDay > data.timeInDay;

		// calculate rates
		data.multiplierDtoF = Math.pow(2, data.G); // each Goat doubles Chupacabra's harvesting of Flesh from Dead
		data.multiplierL = Math.pow(2, data.P); // each Puppy doubles the amount Living coming to be killed by Daywalkers
		data.rateL = 1.0 * data.multiplierL; // Living are attracted to the area per Daytime second
		data.rateC = 1.0 * (data.M > 0) ? Math.pow(2, data.M) : 0; // Mothers spawn Chupacabras per second
		data.rateW = 1.0 * (data.N > 0) ? Math.pow(2, data.N) : 0; // Nests spawn Daywalkers per second
		data.rateDtoF = 1.0 * data.C * data.multiplierDtoF; // Chupacabras turn Dead into Flesh per Nightime second
		data.rateLtoD = 1.0 * data.W; // Daywalkers turn Living into Dead per Daytime second

		// generate stuff
		if (isDaytime) {
			data.L += data.rateL * dt;
		}
		if (isNighttime) {

		}
		data.C += data.rateC * dt;
		data.W += data.rateW * dt;

		// convert stuff at an interval so the player can see numbers going up and down
		data.timeToConversion -= dt;
		if (data.timeToConversion < 0) {
			data.timeToConversion = CONVERSION_INTERAL;
			dt = CONVERSION_INTERAL;
			if (isDaytime) {
				var LtoD = Math.min(data.rateLtoD * dt, data.L);
				data.D += LtoD;
				data.L -= LtoD;
			}
			if (isNighttime) {
				var DtoF = Math.min(data.rateDtoF * dt, data.D);
				data.F += DtoF;
				data.D -= DtoF;
			}
		}
	}
}