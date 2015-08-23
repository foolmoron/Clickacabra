package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import flixel.util.FlxMath;
import flixel.util.FlxColorUtil;
import flixel.util.FlxRandom;

class PlayState extends FlxState
{
	var save:FlxSave = new FlxSave();
	var time:Float = 50;

	var background:FlxSprite;

	public static inline var SKY_HEIGHT = 60;
	public static inline var DAY_LENGTH = 60;
	public static inline var NIGHT_LENGTH = 20;
	public static inline var SKY_LERP_STEPS = 100;
	var skyBackground:FlxSprite;
	var skyColors:Array<Int> = [
		// sunrise
		0xFFFFBB00, 
		// day
		0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF,
		// dusk
		0xFF6600FF,
		// night
		0xFF4D2C80, 0xFF4D2C80, 0xFF4D2C80, 0xFF4D2C80,
	];

	var tidText:DataText<Float>;
	var ticText:DataText<Float>;
	var lText:DataText<Float>;
	var dText:DataText<Float>;
	var fText:DataText<Float>;
	var zText:DataText<Float>;
	var cText:DataText<Float>;
	var wText:DataText<Float>;
	var mText:DataText<Float>;
	var nText:DataText<Float>;
	var gText:DataText<Float>;
	var pText:DataText<Float>;

	var testText:FlxText;
	var b:Float = 0;

	override public function create():Void
	{
		FlxG.autoPause = false; // it's an idler, so let it always play

		// set up save data
		{
			save.bind("clickacabra1");
			time = save.data.timeInDay = Std.is(save.data.timeInDay, Float) ? save.data.timeInDay : time;
			save.data.timeToConversion = Std.is(save.data.timeToConversion, Float) ? save.data.timeToConversion : Chupaclicker.CONVERSION_INTERAL;
			save.data.L = Std.is(save.data.L, Float) ? save.data.L : 0.0; // live people
			save.data.D = Std.is(save.data.D, Float) ? save.data.D : 0.0; // dead people
			save.data.F = Std.is(save.data.F, Float) ? save.data.F : 0.0; // flesh
			save.data.Z = Std.is(save.data.Z, Float) ? save.data.Z : 0.0; // diamonds
			save.data.C = Std.is(save.data.C, Float) ? save.data.C : 0.0; // chupacabras
			save.data.W = Std.is(save.data.W, Float) ? save.data.W : 0.0; // daywalkers
			save.data.M = Std.is(save.data.M, Float) ? save.data.M : 0.0; // mothers
			save.data.N = Std.is(save.data.N, Float) ? save.data.N : 0.0; // nests
			save.data.G = Std.is(save.data.G, Float) ? save.data.G : 0.0; // goats
			save.data.P = Std.is(save.data.P, Float) ? save.data.P : 0.0; // puppies
			save.flush();
		}
		// make background
		{
			background = new FlxSprite(0, 0);
			background.loadGraphic("assets/images/bg.png");
			add(background);
		}
		// make sky
		{
			skyBackground = new FlxSprite(0, 0);
			add(skyBackground);
		}
		// set up texts
		{
			tidText = new DataText<Float>(save.data, "timeInDay", function(val) return "timeInDay=" + val);
			ticText = new DataText<Float>(save.data, "timeToConversion", function(val) return "timeToConversion=" + val);
			lText = new DataText<Float>(save.data, "L", function(val) return "L=" + Chupaclicker.formatBigNum(val, 0));
			dText = new DataText<Float>(save.data, "D", function(val) return "D=" + Chupaclicker.formatBigNum(val, 0));
			fText = new DataText<Float>(save.data, "F", function(val) return "F=" + Chupaclicker.formatBigNum(val, 0));
			zText = new DataText<Float>(save.data, "Z", function(val) return "Z=" + Chupaclicker.formatBigNum(val, 0));
			cText = new DataText<Float>(save.data, "C", function(val) return "C=" + Chupaclicker.formatBigNum(val, 0));
			wText = new DataText<Float>(save.data, "W", function(val) return "W=" + Chupaclicker.formatBigNum(val, 0));
			mText = new DataText<Float>(save.data, "M", function(val) return "M=" + Chupaclicker.formatBigNum(val, 0));
			nText = new DataText<Float>(save.data, "N", function(val) return "N=" + Chupaclicker.formatBigNum(val, 0));
			gText = new DataText<Float>(save.data, "G", function(val) return "G=" + Chupaclicker.formatBigNum(val, 0));
			pText = new DataText<Float>(save.data, "P", function(val) return "P=" + Chupaclicker.formatBigNum(val, 0));
			var texts = [tidText, ticText, lText, dText, fText, zText, cText, wText, mText, nText, gText, pText];
			for (i in 0...texts.length) {
				texts[i].x = 15;
				texts[i].y = i * 15 + 80;
				texts[i].setBorderStyle(FlxText.BORDER_OUTLINE, 0x000000, 1, 1);
				texts[i].color = 0xFFFFFFFF;
				add(texts[i]);
			}
		}
		// debug grid
		{
			var cellSize = 10;
			for (x in 0...Std.int(FlxG.width/cellSize)) {
				var vertLine = new FlxSprite(x * cellSize, 0);
				vertLine.makeGraphic(1, FlxG.height, 0x40FFFFFF);
				add(vertLine);
			}
			for (y in 0...Std.int(FlxG.height/cellSize)) {
				var horizLine = new FlxSprite(0, y * cellSize);
				horizLine.makeGraphic(FlxG.width, 1, 0x40FFFFFF);
				add(horizLine);
			}
		}
		// debug text
		{
			testText = new FlxText(75, 150, 0, null, 16);
			testText.setBorderStyle(FlxText.BORDER_OUTLINE, 0x000000, 2, 1);
			testText.color = 0xFFFFFFFF;
			add(testText);
		}

		super.create();
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		var dt = FlxG.keys.pressed.R ? FlxG.elapsed * 20 : FlxG.elapsed;
		time += dt;

		if (FlxG.mouse.justPressed) {
			if (save.data.L > 1) {
				save.data.D++;
				save.data.L--;
			}
			if (FlxRandom.chanceRoll(5)) {
				save.data.C++;
			}
		}

		Chupaclicker.idle(save.data, dt, DAY_LENGTH, NIGHT_LENGTH);

		var val = FlxG.keys.pressed.G ? 921070 : 500;
		val *= FlxG.keys.pressed.T ? 100 : 1;
		var sign = FlxG.keys.pressed.F ? -1 : 1;
		b = b + (val * sign);
		if (FlxG.keys.pressed.Y) {
			b *= 2;
		} else if (FlxG.keys.pressed.U) {
			b /= 2;
		}
		testText.text = "t=" + Std.int(time) + " b=" + Chupaclicker.formatBigNum(b);

		// do sky color interp
		{
			var percInDay = save.data.timeInDay / (DAY_LENGTH + NIGHT_LENGTH);
			var colorIndex = Std.int(skyColors.length * percInDay);
			var interColorLerp = (skyColors.length * percInDay) - colorIndex;

			var firstColor = skyColors[colorIndex];
			var secondColor = skyColors[(colorIndex + 1) % skyColors.length];
			skyBackground.makeGraphic(FlxG.width, SKY_HEIGHT, FlxColorUtil.interpolateColor(firstColor, secondColor, SKY_LERP_STEPS, Std.int(interColorLerp*SKY_LERP_STEPS)));
		}

		save.flush();
		super.update();
	}	
}