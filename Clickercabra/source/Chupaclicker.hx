package;

import flixel.FlxG;

typedef PropertyFunctions = {
	var canBuy : Dynamic->Bool;
	var costString : Dynamic->String;
	var onBuy: Dynamic->Void;
}

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
		// if (bigNum < 0) return "0";

		var expThousands = Std.int(Math.log(bigNum) / Math.log(1000));
		var remainder = bigNum / Math.pow(1000, expThousands);
		var wholePart = Std.int(remainder);
		var fullDecimalString = "" + (remainder - wholePart);
		var decimalPart = "";
		if (expThousands > 0) {
			decimalPart = ".";
			for (i in 0...2) {
				decimalPart += (fullDecimalString.length > (2 + i)) ? fullDecimalString.charAt(i + 2) : "0";
			}
		}
		var suffix = (expThousands < SUFFIXES.length) ? SUFFIXES[expThousands] : "x10^" + (expThousands * 3);
		return wholePart + decimalPart + suffix;
	}


	public static inline var CONVERSION_INTERAL = 2.0; // seconds between processing each conversion
	public static function idle(data:Dynamic, dt:Float, dayLength:Float, nightLength:Float) {
		// advance time in day=
		var prevTimeInDay:Float = data.timeInDay;
		data.timeInDay = (data.timeInDay + dt) % (dayLength + nightLength);
		data.isDaytime = data.timeInDay < dayLength;
		data.isNighttime = !data.isDaytime;

		// calculate rates
		data.multiplierDtoF = Math.pow(2, data.G); // each Goat doubles Chupacabra's harvesting of Flesh from Dead
		data.multiplierL = Math.pow(2, data.P); // each Puppy doubles the amount Living coming to be killed by Daywalkers
		data.rateL = 1.0 * data.multiplierL; // Living are attracted to the area per Daytime second
		data.rateC = 1.0 * ((data.M > 0) ? Math.pow(2, data.M) : 0); // Mothers spawn Chupacabras per second
		data.rateW = 1.0 * ((data.N > 0) ? Math.pow(2, data.N) : 0); // Nests spawn Daywalkers per second
		data.rateDtoF = 1.0 * data.C * data.multiplierDtoF; // Chupacabras turn Dead into Flesh per Nightime second
		data.rateLtoD = 1.0 * data.W; // Daywalkers turn Living into Dead per Daytime second

		// generate stuff
		if (data.isDaytime) {
			data.L += data.rateL * dt;
		}
		if (data.isNighttime) {

		}
		data.C += data.rateC * dt;
		data.W += data.rateW * dt;

		// convert stuff at an interval so the player can see numbers going up and down
		data.timeToConversion -= dt;
		if (data.timeToConversion < 0) {
			data.timeToConversion = CONVERSION_INTERAL;
			dt = CONVERSION_INTERAL;
			if (data.isDaytime) {
				var LtoD = Math.min(data.rateLtoD * dt, data.L);
				data.D += LtoD;
				data.L -= LtoD;
			}
			if (data.isNighttime) {
				var DtoF = Math.min(data.rateDtoF * dt, data.D);
				data.F += DtoF;
				data.D -= DtoF;
			}
		}
	}

	public static var PROPERTIES:Map<String, { onBuy:Dynamic->Void, costString:Dynamic->String, canBuy:Dynamic->Bool }> = [
		"D"=> {
			canBuy: function(data:Dynamic) { return data.L >= 1 && data.isDaytime; },
			costString: function(data:Dynamic) { return "During the day, click on a human to kill them!"; },
			onBuy: function(data:Dynamic) { data.L--; data.D++; }
		},
		"C"=> {
			canBuy: function(data:Dynamic) { return data.F >= ((data.C == 0) ? 0 : 3); },
			costString: function(data:Dynamic) { return "Spawn a Chupacabra with 3 Flesh!"; },
			onBuy: function(data:Dynamic) { data.F -= ((data.C == 0) ? 0 : 3); data.C++; }
		},
		"W"=> {
			canBuy: function(data:Dynamic) { return data.C >= 1 && data.F >= 50; },
			costString: function(data:Dynamic) { return "Convert a Chupacabra into a Daywalker with 50 Flesh!"; },
			onBuy: function(data:Dynamic) { data.C--; data.F -= 50; data.W++; }
		},
		"M"=> {
			canBuy: function(data:Dynamic) { return data.C >= 50 && data.F >= (300 * Math.pow(2, data.M)); },
			costString: function(data:Dynamic) { return "Create a Mother with 50 Chupacabras and " + formatBigNum(300 * Math.pow(2, data.M)) + " Flesh!"; },
			onBuy: function(data:Dynamic) { data.C -= 50; data.F -= (300 * Math.pow(2, data.M)); data.M++; }
		},
		"N"=> {
			canBuy: function(data:Dynamic) { return data.W >= 50 && data.F >= (300 * Math.pow(2, data.N)); },
			costString: function(data:Dynamic) { return "Create a Nest with 50 Daywalkers and " + formatBigNum(300 * Math.pow(2, data.N)) + " Flesh!"; },
			onBuy: function(data:Dynamic) { data.W -= 50; data.F -= (300 * Math.pow(2, data.N)); data.N++; }
		},
		"G"=> {
			canBuy: function(data:Dynamic) { return data.F >= (500 * Math.pow(2, data.G)); },
			costString: function(data:Dynamic) { return "Upgrade your Goat Farm with " + formatBigNum(500 * Math.pow(2, data.G)) + " Flesh!"; },
			onBuy: function(data:Dynamic) { data.F -= (500 * Math.pow(2, data.G)); data.G++; }
		},
		"P"=> {
			canBuy: function(data:Dynamic) { return data.F >= (500 * Math.pow(2, data.P)); },
			costString: function(data:Dynamic) { return "Upgrade your Goat Farm with " + formatBigNum(500 * Math.pow(2, data.P)) + " Flesh!"; },
			onBuy: function(data:Dynamic) { data.F -= (500 * Math.pow(2, data.P)); data.P++; }
		},
	];
	public static function canBuy(data:Dynamic, propertyName:String) : Bool {
		if (!PROPERTIES.exists(propertyName)) return false;
		else return PROPERTIES[propertyName].canBuy(data);
	}
	public static function costString(data:Dynamic, propertyName:String) : String {
		if (!PROPERTIES.exists(propertyName)) return "???";
		else return PROPERTIES[propertyName].costString(data);
	}
	public static function attemptBuy(data:Dynamic, propertyName:String) {
		if (!PROPERTIES.exists(propertyName)) return;
		else PROPERTIES[propertyName].onBuy(data);
	}
}