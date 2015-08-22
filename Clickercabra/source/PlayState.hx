package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxTimer;
import flixel.util.FlxMath;


class PlayState extends FlxState
{
	var testText:FlxText;
	var time:FlxTimer = new FlxTimer(100);
	var x:Int;
	var b:BigNum = new BigNum();

	override public function create():Void
	{
		FlxG.autoPause = false; // it's an idler, so let it always play

		//make border
		{
			var borderSize = 10;
			var border = new FlxSprite(0, 0);
			border.makeGraphic(FlxG.width, FlxG.height, 0xFFFF0000);
			add(border);
			var background = new FlxSprite(borderSize, borderSize);
			background.makeGraphic(FlxG.width - (borderSize*2), FlxG.height - (borderSize*2), 0x80000000);
			add(background);
		}
		// thing
		{
			add(new FlxSprite(100, 100).makeGraphic(10, 20, 0xFF00FF00));
		}
		// grid
		{
			var cellSize = 10;
			for (x in 0...Std.int(FlxG.width/cellSize)) {
				var vertLine = new FlxSprite(x * cellSize, 0);
				vertLine.makeGraphic(1, FlxG.height, 0xFFFFFFFF);
				add(vertLine);
			}
			for (y in 0...Std.int(FlxG.height/cellSize)) {
				var horizLine = new FlxSprite(0, y * cellSize);
				horizLine.makeGraphic(FlxG.width, 1, 0xFFFFFFFF);
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
		var val = FlxG.keys.pressed.G ? 921070 : 500;
		val *= FlxG.keys.pressed.T ? 100 : 1;
		var sign = FlxG.keys.pressed.F ? -1 : 1;
		b = b.addNum(val * sign);
		this.testText.text = b.toString();

		super.update();
	}	
}