package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxGradient;
import flixel.util.FlxTimer;
import flixel.util.FlxMath;
import flixel.util.FlxColorUtil;

class PlayState extends FlxState
{
	var time:Float = 0.0;

	var background:FlxSprite;

	public static inline var SKY_HEIGHT = 60;
	public static inline var DAY_LENGTH = 60;
	public static inline var NIGHT_LENGTH = 30;
	public static inline var SKY_LERP_STEPS = 100;
	var skyBackground:FlxSprite;
	var skyColors:Array<Int> = [
		//sunrise
		0xFFFFBB00, 
		//day
		0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF, 0xFF00B8FF,
		//dusk
		0xFF6600FF,
		//night
		0xFF4D2C80, 0xFF4D2C80, 0xFF4D2C80, 0xFF4D2C80,
	];

	var testText:FlxText;
	var b:BigNum = new BigNum();

	override public function create():Void
	{
		FlxG.autoPause = false; // it's an idler, so let it always play

		//make background
		{
			background = new FlxSprite(0, 0);
			background.loadGraphic("assets/images/bg.png");
			add(background);
		}
		//make sky
		{
			skyBackground = new FlxSprite(0, 0);
			add(skyBackground);
		}
		// grid
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
		// text
		{
			this.testText = new FlxText(30, 150, 0, null, 16);
			this.testText.setBorderStyle(FlxText.BORDER_OUTLINE, 0x000000, 2, 1);
			this.testText.color = 0xFFFFFFFF;
			add(this.testText);
		}

		super.create();
	}

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		time += FlxG.elapsed;

		var val = FlxG.keys.pressed.G ? 921070 : 500;
		val *= FlxG.keys.pressed.T ? 100 : 1;
		var sign = FlxG.keys.pressed.F ? -1 : 1;
		b = b.addNum(val * sign);
		this.testText.text = b.toString();

		// do sky color interp
		{
			var inDayTime = this.time % (DAY_LENGTH + NIGHT_LENGTH);
			var inDayPerc = inDayTime / (DAY_LENGTH + NIGHT_LENGTH);
			var colorIndex = Std.int(this.skyColors.length * inDayPerc);
			var interColorLerp = (this.skyColors.length * inDayPerc) - colorIndex;

			var firstColor = this.skyColors[colorIndex];
			var secondColor = this.skyColors[(colorIndex + 1) % this.skyColors.length];
			skyBackground.makeGraphic(FlxG.width, SKY_HEIGHT, FlxColorUtil.interpolateColor(firstColor, secondColor, SKY_LERP_STEPS, Std.int(interColorLerp*SKY_LERP_STEPS)));
		}

		super.update();
	}	
}