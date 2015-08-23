package;

import flixel.FlxG;
import flixel.text.FlxText;

class DataText<T> extends FlxText
{
	public var data:Void->T;
	public var textGenerator:T->String;

	public function new(data:Void->T, textGenerator:T->String, x:Float = 0, y:Float = 0, fieldWidth:Float = 0, size:Int = 8, embeddedFont:Bool = true) {
		super(x, y, fieldWidth, textGenerator(data()), size, embeddedFont);
		this.data = data;
		this.textGenerator = textGenerator;
	}

	override public function update():Void
	{
		text = textGenerator(data());
		super.update();
	}
}