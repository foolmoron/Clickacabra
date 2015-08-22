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

class PlayState extends FlxState
{
	var save:FlxSave = new FlxSave();
	var time:Float = 0.0;

	var background:FlxSprite;

	public static inline var SKY_HEIGHT = 60;
	public static inline var DAY_LENGTH = 60;
	public static inline var NIGHT_LENGTH = 30;
	public static inline var SKY_LERP_STEPS = 100;
	var skyBackground:FlxSprite;
	var skyColors:Array<Int> = [
		// sunrise
		0xFFFFBB00, 
		// day
		0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF,
		// dusk
		0xFF6600FF,
		// night
		0xFF4D2C80, 0xFF4D2C80, 0xFF4D2C80, 0xFF4D2C80,
	];

	var lText:DataText<Int>;
	var dText:DataText<Int>;
	var fText:DataText<Int>;
	var zText:DataText<Int>;
	var cText:DataText<Int>;
	var wText:DataText<Int>;
	var mText:DataText<Int>;
	var nText:DataText<Int>;
	var gText:DataText<Int>;
	var pText:DataText<Int>;

	var testText:FlxText;
	var b:BigNum = new BigNum();

	override public function create():Void
	{
		FlxG.autoPause = false; // it's an idler, so let it always play

		// set up save data
		{
			save.bind("clickacabra1");
			save.data.L = Std.is(save.data.L, Int) ? save.data.L : 0; // live people
			save.data.D = Std.is(save.data.D, Int) ? save.data.D : 0; // dead people
			save.data.F = Std.is(save.data.F, Int) ? save.data.F : 0; // flesh
			save.data.Z = Std.is(save.data.Z, Int) ? save.data.Z : 0; // diamonds
			save.data.C = Std.is(save.data.C, Int) ? save.data.C : 0; // chupacabras
			save.data.W = Std.is(save.data.W, Int) ? save.data.W : 0; // daywalkers
			save.data.M = Std.is(save.data.M, Int) ? save.data.M : 0; // mothers
			save.data.N = Std.is(save.data.N, Int) ? save.data.N : 0; // nests
			save.data.G = Std.is(save.data.G, Int) ? save.data.G : 0; // goats
			save.data.P = Std.is(save.data.P, Int) ? save.data.P : 0; // puppies
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
			lText = new DataText<Int>(save.data, "L", function(val) return "L=" + val);
			dText = new DataText<Int>(save.data, "D", function(val) return "D=" + val);
			fText = new DataText<Int>(save.data, "F", function(val) return "F=" + val);
			zText = new DataText<Int>(save.data, "Z", function(val) return "Z=" + val);
			cText = new DataText<Int>(save.data, "C", function(val) return "C=" + val);
			wText = new DataText<Int>(save.data, "W", function(val) return "W=" + val);
			mText = new DataText<Int>(save.data, "M", function(val) return "M=" + val);
			nText = new DataText<Int>(save.data, "N", function(val) return "N=" + val);
			gText = new DataText<Int>(save.data, "G", function(val) return "G=" + val);
			pText = new DataText<Int>(save.data, "P", function(val) return "P=" + val);
			var texts = [lText, dText, fText, zText, cText, wText, mText, nText, gText, pText];
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
			testText = new FlxText(150, 150, 0, null, 16);
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
		time += FlxG.keys.pressed.R ? FlxG.elapsed * 20 : FlxG.elapsed;

		var val = FlxG.keys.pressed.G ? 921070 : 500;
		val *= FlxG.keys.pressed.T ? 100 : 1;
		var sign = FlxG.keys.pressed.F ? -1 : 1;
		b = b.addNum(val * sign);
		testText.text = "t=" + Std.int(time) + " b=" + b.toString();

		// do sky color interp
		{
			var inDayTime = time % (DAY_LENGTH + NIGHT_LENGTH);
			var inDayPerc = inDayTime / (DAY_LENGTH + NIGHT_LENGTH);
			var colorIndex = Std.int(skyColors.length * inDayPerc);
			var interColorLerp = (skyColors.length * inDayPerc) - colorIndex;

			var firstColor = skyColors[colorIndex];
			var secondColor = skyColors[(colorIndex + 1) % skyColors.length];
			skyBackground.makeGraphic(FlxG.width, SKY_HEIGHT, FlxColorUtil.interpolateColor(firstColor, secondColor, SKY_LERP_STEPS, Std.int(interColorLerp*SKY_LERP_STEPS)));
		}

		super.update();
	}	
}