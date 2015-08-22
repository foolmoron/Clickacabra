package;

import flixel.FlxG;
import flixel.text.FlxText;

class DataText<T> extends FlxText
{
	public var dataObj:Dynamic;
	public var propertyName:String;
	public var textGenerator:T->String;

	public function new(dataObj:Dynamic, propertyName:String, textGenerator:T->String, x:Float = 0, y:Float = 0, fieldWidth:Float = 0, size:Int = 8, embeddedFont:Bool = true) {
		super(x, y, fieldWidth, textGenerator(Reflect.field(dataObj, propertyName)), size, embeddedFont);
		this.dataObj = dataObj;
		this.propertyName = propertyName;
		this.textGenerator = textGenerator;
	}

	override public function update():Void
	{
		text = textGenerator(Reflect.field(dataObj, propertyName));
		super.update();
	}
}