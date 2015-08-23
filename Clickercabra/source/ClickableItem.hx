package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

class ClickableItem extends FlxGroup
{

  public var x:Float;
  public var y:Float;

  public var normalSprite:FlxSprite;
  public var hoverSprite:FlxSprite;
  public var clickSprite:FlxSprite;

  public var countStringGenerator:Void->String;
  public var rateStringGenerator:Void->String;
  public var infoStringGenerator:Void->String;
  public var costStringGenerator:Void->String;

  public var countText:FlxText;
  public var rateText:FlxText;

  public var popupBG:FlxSprite;
  public var infoText:FlxText;
  public var costText:FlxText;

  public function new(x:Float, y:Float, sprite:FlxSprite, normalColor:Int, hoverColor:Int, clickColor:Int, countStringGenerator:Void->String, rateStringGenerator:Void->String, infoStringGenerator:Void->String, costStringGenerator:Void->String) {
    super();

    this.x = x;
    this.y = y;
    this.normalSprite = sprite.clone();
    this.normalSprite.color = normalColor;
    this.hoverSprite = sprite.clone();
    this.hoverSprite.color = hoverColor;
    this.clickSprite = sprite.clone();
    this.clickSprite.color = clickColor;
    this.countStringGenerator = countStringGenerator;
    this.rateStringGenerator = rateStringGenerator;
    this.infoStringGenerator = infoStringGenerator;
    this.costStringGenerator = costStringGenerator;


    // make display texts
    {
      countText = new FlxText(0, 0);
      countText.size = 16;
      countText.setBorderStyle(FlxText.BORDER_OUTLINE, 0x000000, 2, 1);
      countText.color = 0xFFFFFFFF;
      rateText = new FlxText(0, 0);
      rateText.size = 8;
      rateText.setBorderStyle(FlxText.BORDER_OUTLINE, 0x000000, 1, 1);
      rateText.color = 0xFFFFFFFF;
    }
    // make info popup
    {
      popupBG = new FlxSprite(0, 0);
      infoText = new FlxText(0, 0);
      costText = new FlxText(0, 0);
    }
    // add stuff
    {
      add(countText);
      add(rateText);
      add(popupBG);
      add(infoText);
      add(costText);
    }
  }

  override public function update():Void
  {
    // TODO: position things on item position
    {
      normalSprite.x = hoverSprite.x = clickSprite.x = x + 0;
      normalSprite.y = hoverSprite.y = clickSprite.y = y + 0;

      countText.x = x + 40;
      countText.y = y + 4;
      rateText.x = x - 4;
      rateText.y = y + 32;

      popupBG.x = x + 0;
      popupBG.y = y + 0;
      infoText.x = costText.x = x + 0;
      infoText.y = y + 0;
      costText.y = y + 0;
    }
    // update texts
    {
      countText.text = countStringGenerator();
      rateText.text = rateStringGenerator();
      infoText.text = infoStringGenerator();
      costText.text = costStringGenerator();
    }
    // TODO: show correct sprite based on mouse state
    {
      add(normalSprite);
      remove(hoverSprite);
      remove(clickSprite);
    }
    // TODO: show popup based on mouse state
    {
      remove(popupBG);
      remove(infoText);
      remove(costText);
    }
    super.update();
  }
}