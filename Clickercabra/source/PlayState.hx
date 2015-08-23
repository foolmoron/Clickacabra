package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
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

	var everythingGroup = new FlxTypedGroup<FlxSprite>();

	var peopleGroup = new FlxTypedGroup<FlxTypedGroup<FlxSprite>>();
	var livingGroup = new FlxTypedGroup<FlxSprite>();
	var deadGroup = new FlxTypedGroup<FlxSprite>();

	var monsterGroup = new FlxTypedGroup<FlxTypedGroup<FlxSprite>>();
	var chupacabraGroup = new FlxTypedGroup<FlxSprite>();
	var daywalkerGroup = new FlxTypedGroup<FlxSprite>();
	
	var itemGroup = new FlxTypedGroup<FlxTypedGroup<FlxSprite>>();
	var goatGroup = new FlxTypedGroup<FlxSprite>();
	var puppyGroup = new FlxTypedGroup<FlxSprite>();
	var diamondGroup = new FlxTypedGroup<FlxSprite>();

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

	var lButton:Dynamic = { prop: "L" };
	var dButton:Dynamic = { prop: "D" };
	var fButton:Dynamic = { prop: "F" };
	var zButton:Dynamic = { prop: "Z" };
	var cButton:Dynamic = { prop: "C" };
	var wButton:Dynamic = { prop: "W" };
	var mButton:Dynamic = { prop: "M" };
	var nButton:Dynamic = { prop: "N" };
	var gButton:Dynamic = { prop: "G" };
	var pButton:Dynamic = { prop: "P" };
	var buttons:Array<Dynamic>;

	var testText:FlxText;
	var b:Float = 0;

	override public function create():Void
	{
		FlxG.autoPause = false; // it's an idler, so let it always play

		// set up save data
		{
			save.bind("clickacabra1");
			time = save.data.timeInDay = Std.is(save.data.timeInDay, Float) ? save.data.timeInDay : time;
			save.data.isDaytime = Std.is(save.data.isDaytime, Bool) ? save.data.isDaytime : save.data.timeInDay < DAY_LENGTH;
			save.data.isNighttime = Std.is(save.data.isNighttime, Bool) ? save.data.isNighttime : !save.data.timeInDay;
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
		// set up sprite groups
		{
			peopleGroup.add(livingGroup);
			peopleGroup.add(deadGroup);
			for (i in 0...20) {
				var living = new FlxSprite(FlxRandom.floatRanged(0, FlxG.width), 0);
				living.makeGraphic(10, 20, 0xFF00FF00);
				living.offset.y = 20;
				livingGroup.add(living);
				everythingGroup.add(living);

				var dead = new FlxSprite(FlxRandom.floatRanged(0, FlxG.width), 0);
				dead.makeGraphic(20, 10, 0xFFFF0000);
				dead.offset.y = 10;
				deadGroup.add(dead);
				everythingGroup.add(dead);
			}
			add(peopleGroup);

			monsterGroup.add(chupacabraGroup);
			monsterGroup.add(daywalkerGroup);
			for (i in 0...10) {
				var chupacabra = new FlxSprite(FlxRandom.floatRanged(0, FlxG.width), 0);
				chupacabra.makeGraphic(20, 30, 0xFF5C5400);
				chupacabra.offset.y = 30;
				chupacabraGroup.add(chupacabra);
				everythingGroup.add(chupacabra);

				var daywalker = new FlxSprite(FlxRandom.floatRanged(0, FlxG.width), 0);
				daywalker.makeGraphic(30, 40, 0xFF4F0D93);
				daywalker.offset.y = 40;
				daywalkerGroup.add(daywalker);
				everythingGroup.add(daywalker);
			}
			add(monsterGroup);
	
			itemGroup.add(goatGroup);
			itemGroup.add(puppyGroup);
			itemGroup.add(diamondGroup);
			for (i in 0...10) {
				var goat = new FlxSprite(FlxRandom.floatRanged(0, FlxG.width), 0);
				goat.makeGraphic(15, 8, 0xFF878787);
				goat.offset.y = 8;
				goatGroup.add(goat);
				everythingGroup.add(goat);

				var puppy = new FlxSprite(FlxRandom.floatRanged(0, FlxG.width), 0);
				puppy.makeGraphic(15, 8, 0xFFDBC905);
				puppy.offset.y = 8;
				puppyGroup.add(puppy);
				everythingGroup.add(puppy);
			}
			for (i in 0...30) {
				var diamond = new FlxSprite(FlxRandom.floatRanged(0, FlxG.width), 0);
				diamond.makeGraphic(5, 5, 0xFF06FBA7);
				diamond.offset.y = 5;
				diamondGroup.add(diamond);
				everythingGroup.add(diamond);
			}
			add(itemGroup);

			everythingGroup.forEach(function(sprite) {
				sprite.acceleration.y = 100;
				sprite.velocity.x = FlxRandom.chanceRoll() ? 50 : -50;
				sprite.velocity.x = FlxRandom.chanceRoll() ? sprite.velocity.x * 1.5 : sprite.velocity.x;
				sprite.velocity.x = FlxRandom.chanceRoll() ? sprite.velocity.x * 1.5 : sprite.velocity.x;
				sprite.maxVelocity.y = 500;
				sprite.maxVelocity.x = 200;
				sprite.health = FlxRandom.floatRanged(0, 5);
			});
		}
		// set up texts
		{
			tidText = new DataText<Float>(save.data, "timeInDay", function(val) return "timeInDay=" + val);
			ticText = new DataText<Float>(save.data, "timeToConversion", function(val) return "timeToConversion=" + val);
			lText = new DataText<Float>(save.data, "L", function(val) return "L=" + Chupaclicker.formatBigNum(val));
			dText = new DataText<Float>(save.data, "D", function(val) return "D=" + Chupaclicker.formatBigNum(val));
			fText = new DataText<Float>(save.data, "F", function(val) return "F=" + Chupaclicker.formatBigNum(val));
			zText = new DataText<Float>(save.data, "Z", function(val) return "Z=" + Chupaclicker.formatBigNum(val));
			cText = new DataText<Float>(save.data, "C", function(val) return "C=" + Chupaclicker.formatBigNum(val));
			wText = new DataText<Float>(save.data, "W", function(val) return "W=" + Chupaclicker.formatBigNum(val));
			mText = new DataText<Float>(save.data, "M", function(val) return "M=" + Chupaclicker.formatBigNum(val));
			nText = new DataText<Float>(save.data, "N", function(val) return "N=" + Chupaclicker.formatBigNum(val));
			gText = new DataText<Float>(save.data, "G", function(val) return "G=" + Chupaclicker.formatBigNum(val));
			pText = new DataText<Float>(save.data, "P", function(val) return "P=" + Chupaclicker.formatBigNum(val));
			var texts = [tidText, ticText, lText, dText, fText, zText, cText, wText, mText, nText, gText, pText];
			for (i in 0...texts.length) {
				texts[i].x = 15;
				texts[i].y = i * 22 + 10;
				texts[i].setBorderStyle(FlxText.BORDER_OUTLINE, 0x000000, 1, 1);
				texts[i].color = 0xFFFFFFFF;
				add(texts[i]);
			}
		}
		// set up buttons
		{
			dButton.button = new FlxButton(0, 0, "Dead", function() { Chupaclicker.attemptBuy(save.data, "D"); });
			cButton.button = new FlxButton(0, 0, "Chupacabra", function() { Chupaclicker.attemptBuy(save.data, "C"); });
			wButton.button = new FlxButton(0, 0, "Daywalker", function() { Chupaclicker.attemptBuy(save.data, "W"); });
			mButton.button = new FlxButton(0, 0, "Mother", function() { Chupaclicker.attemptBuy(save.data, "M"); });
			nButton.button = new FlxButton(0, 0, "Nest", function() { Chupaclicker.attemptBuy(save.data, "N"); });
			gButton.button = new FlxButton(0, 0, "Goat", function() { Chupaclicker.attemptBuy(save.data, "G"); });
			pButton.button = new FlxButton(0, 0, "Puppy", function() { Chupaclicker.attemptBuy(save.data, "P"); });
			buttons = [null, null, null, dButton, null, null, cButton, wButton, mButton, nButton, gButton, pButton];
			for (i in 0...buttons.length) {
				if (buttons[i] == null) continue;

				buttons[i].button.x = 80;
				buttons[i].button.y = i * 22 + 10;
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
			testText = new FlxText(200, 250, 0, null, 16);
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
		dt *= FlxG.keys.pressed.E ? 100 : 1;
		time += dt;

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
		if (FlxG.keys.pressed.W) {
			save.data.W++;
		}
		testText.text = "t=" + Std.int(time) + " b=" + Chupaclicker.formatBigNum(b);

		if (FlxG.keys.pressed.P) {
			time = save.data.timeInDay = 50;
			save.data.isDaytime = save.data.timeInDay < DAY_LENGTH;
			save.data.isNighttime = !save.data.timeInDay;
			save.data.timeToConversion = Chupaclicker.CONVERSION_INTERAL;
			save.data.L = 0.0;
			save.data.D = 0.0;
			save.data.F = 0.0;
			save.data.Z = 0.0;
			save.data.C = 0.0;
			save.data.W = 0.0;
			save.data.M = 0.0;
			save.data.N = 0.0;
			save.data.G = 0.0;
			save.data.P = 0.0;
			save.flush();
		}

		// do sky color interp
		{
			var percInDay = save.data.timeInDay / (DAY_LENGTH + NIGHT_LENGTH);
			var colorIndex = Std.int(skyColors.length * percInDay);
			var interColorLerp = (skyColors.length * percInDay) - colorIndex;

			var firstColor = skyColors[colorIndex];
			var secondColor = skyColors[(colorIndex + 1) % skyColors.length];
			skyBackground.makeGraphic(FlxG.width, SKY_HEIGHT, FlxColorUtil.interpolateColor(firstColor, secondColor, SKY_LERP_STEPS, Std.int(interColorLerp*SKY_LERP_STEPS)));
		}
		// toggle buttons based on availability
		{
			for (i in 0...buttons.length) {
				if (buttons[i] == null) continue;

				if (Chupaclicker.canBuy(save.data, buttons[i].prop)) {
					add(buttons[i].button);
				} else {
					remove(buttons[i].button);
				}
			}
		}

		save.flush();
		super.update();
		// do physics stuff after parent updates entities

		// keep sprites in the play area
		{
			everythingGroup.forEach(function(sprite) {
				if (sprite.x < 0) {
					sprite.velocity.x = Math.abs(sprite.velocity.x);
				} else if (sprite.x > FlxG.width) {
					sprite.velocity.x = -Math.abs(sprite.velocity.x);
				}
				if (sprite.y > SKY_HEIGHT) {
					sprite.y = SKY_HEIGHT;
					sprite.health -= FlxG.elapsed;
					if (sprite.health < 0) {
						sprite.velocity.y = -25 * FlxRandom.floatRanged(1, 5);
						sprite.health = FlxRandom.floatRanged(0, 5);
					}
				}
			});
		}
	}	
}