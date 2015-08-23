package;

import flixel.FlxG;
import flixel.util.FlxRandom;

typedef PropertyFunctions = {
	var canBuy : Dynamic->Bool;
	var costString : Dynamic->String;
	var onBuy: Dynamic->Void;
}

class Clickercabra
{
	public static var SUFFIXES = [ // clickerheroes ftw
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
		"D"
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
		var suffix = (expThousands >= 0 && expThousands < SUFFIXES.length) ? SUFFIXES[expThousands] : "x10^" + (expThousands * 3);
		return wholePart + decimalPart + suffix;
	}


	public static inline var CONVERSION_INTERAL = 1.0; // seconds between processing each conversion
	public static function idle(data:Dynamic, dt:Float, dayLength:Float, nightLength:Float) {
		// advance time in day=
		var prevTimeInDay:Float = data.timeInDay;
		data.timeInDay = (data.timeInDay + dt) % (dayLength + nightLength);
		data.isDaytime = data.timeInDay < dayLength;
		data.isNighttime = !data.isDaytime;

		// calculate rates
		data.multiplierDtoF = Math.pow(2, data.G); // each Goat multiplies Chupacabra's harvesting of Flesh from Dead
		data.multiplierL = Math.pow(5, data.P); // each Puppy multiplies the amount Living coming to be killed by Daywalkers
		data.rateL = 2.5 * data.multiplierL; // Living are attracted to the area per Daytime second
		data.rateC = 1.0 * ((data.M > 0) ? Math.pow(1.5, data.M) : 0); // Mothers spawn Chupacabras per second
		data.rateW = 1.0 * ((data.N > 0) ? Math.pow(1.5, data.N) : 0); // Nests spawn Daywalkers per second
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
		var livingKilled = 0.0;
		data.timeToConversion -= dt;
		if (data.timeToConversion < 0) {
			data.timeToConversion = CONVERSION_INTERAL;
			dt = CONVERSION_INTERAL;
			if (data.isDaytime) {
				var LtoD = livingKilled = Math.min(data.rateLtoD * dt, data.L);
				data.D += LtoD;
				data.L -= LtoD;
			}
			if (data.isNighttime) {
				var DtoF = Math.min(data.rateDtoF * dt, data.D);
				data.F += DtoF;
				data.D -= DtoF;
			}

			// generate diamonds based on number of people killed
			var diamondsToGenerate = livingKilled * 0.0001;
			var remainder = diamondsToGenerate % 1;
			var fullDiamonds = diamondsToGenerate - remainder;
			if (fullDiamonds >= 1) {
				data.Z += fullDiamonds;
			}
			if (remainder > 0.01) {
				if (FlxRandom.chanceRoll(remainder * 100)) {
					data.Z++;
				}
			}
		}
	}

	public static var PROPERTIES:Map<String, { infoString:Dynamic->String, rateString:Dynamic->String, costString:Dynamic->String, canBuy:Dynamic->Bool, onBuy:Dynamic->Void }> = [
		"L"=> {
			infoString: function(data:Dynamic) { return "Living people are attracted to this the legend of the Chupacabra in this field. Click to kill them!"; },
			rateString: function(data:Dynamic) { return formatBigNum(data.rateL) + " Living/s during Daytime"; },
			costString: function(data:Dynamic) { return "Click sky during Daytime to kill Living people. You monster."; },
			canBuy: null,
			onBuy: null,
		},
		"D"=> {
			infoString: function(data:Dynamic) { return "During Daytime, Living people can be killed with clicks or Daywalkers. What a shame."; },
			rateString: null,
			costString: function(data:Dynamic) { return "Click sky during Daytime to kill Living people. You monster."; },
			canBuy: null,
			onBuy: null
		},
		"F"=> {
			infoString: function(data:Dynamic) { return "During Nighttime, Chupacabras harvest Flesh from the Dead. Delicious!"; },
			rateString: null,
			costString: null,
			canBuy: null,
			onBuy: null,
		},
		"Z"=> {
			infoString: function(data:Dynamic) { return "Sometimes people will drop Diamonds when they are killed. These are VERY rare..."; },
			rateString: null,
			costString: null,
			canBuy: null,
			onBuy: null,
		},
		"C"=> {
			infoString: function(data:Dynamic) { return "The legendary Chupacabra feeds on the Dead at Night to harvest Flesh. Is it the monster, or are you?"; },
			rateString: function(data:Dynamic) { return formatBigNum(data.rateDtoF) + " Flesh/s at Night"; },
			costString: function(data:Dynamic) { return "Spawn a Chupacabra with 3 Flesh!"; },
			canBuy: function(data:Dynamic) { return data.F >= ((data.C == 0) ? 0 : 3); },
			onBuy: function(data:Dynamic) { data.F -= ((data.C == 0) ? 0 : 3); data.C++; }
		},
		"W"=> {
			infoString: function(data:Dynamic) { return "The Daywalker is an evolved Chupacabra who goes out during During to kill Living people."; },
			rateString: function(data:Dynamic) { return formatBigNum(data.rateLtoD) + " Dead/s during Day"; },
			costString: function(data:Dynamic) { return "Evolve 5 Chupacabras into a Daywalker with 50 Flesh!"; },
			canBuy: function(data:Dynamic) { return data.C >= 5 && data.F >= 50; },
			onBuy: function(data:Dynamic) { data.C -= 5; data.F -= 50; data.W++; }
		},
		"M"=> {
			infoString: function(data:Dynamic) { return "The Mother spawns Chupacabras over time via osmosis or something like that."; },
			rateString: function(data:Dynamic) { return formatBigNum(data.rateC) + " Chupacabras spawn/s"; },
			costString: function(data:Dynamic) { return "Create a Mother with " + formatBigNum(50 * Math.pow(2, data.M)) + " Chupacabras and " + formatBigNum(1000 * Math.pow(2, data.M)) + " Flesh!"; },
			canBuy: function(data:Dynamic) { return data.C >= (50 * Math.pow(2, data.M)) && data.F >= (1000 * Math.pow(2, data.M)); },
			onBuy: function(data:Dynamic) { data.C -= (50 * Math.pow(2, data.M)); data.F -= (1000 * Math.pow(2, data.M)); data.M++; }
		},
		"N"=> {
			infoString: function(data:Dynamic) { return "The Nest is where Chupacabras study to obtain their Daywalking degree."; },
			rateString: function(data:Dynamic) { return formatBigNum(data.rateW) + " Daywalkers spawn/s"; },
			costString: function(data:Dynamic) { return "Create a Nest with " + formatBigNum(50 * Math.pow(2, data.N)) + " Daywalkers and " + formatBigNum(1000 * Math.pow(2, data.N)) + " Flesh!"; },
			canBuy: function(data:Dynamic) { return data.W >= (50 * Math.pow(2, data.N)) && data.F >= (1000 * Math.pow(2, data.N)); },
			onBuy: function(data:Dynamic) { data.W -= (50 * Math.pow(2, data.N)); data.F -= (1000 * Math.pow(2, data.N)); data.N++; }
		},
		"G"=> {
			infoString: function(data:Dynamic) { return "Goat Farms make your Chupacabras excited and faster at harvesting Flesh."; },
			rateString: function(data:Dynamic) { return formatBigNum(data.multiplierDtoF) + "x Flesh harvesting"; },
			costString: function(data:Dynamic) { return "Upgrade your Goat Farm with " + formatBigNum(150 * Math.pow(5, data.G)) + " Flesh!"; },
			canBuy: function(data:Dynamic) { return data.F >= (150 * Math.pow(5, data.G)); },
			onBuy: function(data:Dynamic) { data.F -= (150 * Math.pow(5, data.G)); data.G++; }
		},
		"P"=> {
			infoString: function(data:Dynamic) { return "Puppies attract more Living to the area. People love puppies!"; },
			rateString: function(data:Dynamic) { return formatBigNum(data.multiplierL) + "x Living attracted"; },
			costString: function(data:Dynamic) { return "Get more puppies with " + formatBigNum(150 * Math.pow(5, data.P)) + " Flesh!"; },
			canBuy: function(data:Dynamic) { return data.F >= (150 * Math.pow(5, data.P)); },
			onBuy: function(data:Dynamic) { data.F -= (150 * Math.pow(5, data.P)); data.P++; }
		},
	];
	public static function infoString(data:Dynamic, propertyName:String) : String {
		if (!PROPERTIES.exists(propertyName)) return "???";
		else return PROPERTIES[propertyName].infoString != null ? PROPERTIES[propertyName].infoString(data) : "";
	}
	public static function costString(data:Dynamic, propertyName:String) : String {
		if (!PROPERTIES.exists(propertyName)) return "???";
		else return PROPERTIES[propertyName].costString != null ? PROPERTIES[propertyName].costString(data) : "";
	}
	public static function rateString(data:Dynamic, propertyName:String) : String {
		if (!PROPERTIES.exists(propertyName)) return "???";
		else return PROPERTIES[propertyName].rateString != null ? PROPERTIES[propertyName].rateString(data) : "";
	}
	public static function canBuy(data:Dynamic, propertyName:String) : Bool {
		if (!PROPERTIES.exists(propertyName)) return false;
		else return PROPERTIES[propertyName].canBuy != null ? PROPERTIES[propertyName].canBuy(data) : false;
	}
	public static function doBuy(data:Dynamic, propertyName:String) {
		if (!PROPERTIES.exists(propertyName)) return;
		else if (PROPERTIES[propertyName].onBuy != null) PROPERTIES[propertyName].onBuy(data);
	}
}