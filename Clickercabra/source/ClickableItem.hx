package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.plugin.MouseEventManager;

class ClickableItem extends FlxGroup
{

  public var x:Float;
  public var y:Float;

  public var dataObj:Dynamic;
  public var propertyName:String;
  public var buyable:Bool;

  public var layerLow:FlxGroup;
  public var layerMedium:FlxGroup;
  public var layerTop:FlxGroup;

  public var spriteHitbox:FlxObject;
  public var normalSprite:FlxSprite;
  public var hoverSprite:FlxSprite;
  public var clickSprite:FlxSprite;
  public var cantbuySprite:FlxSprite;

  public var countText:FlxText;
  public var rateText:FlxText;

  public var popupBG:FlxSprite;
  public var infoText:FlxText;
  public var costText:FlxText;

  public function new(x:Float, y:Float, sprite:FlxSprite, normalColor:Int, hoverColor:Int, clickColor:Int, cantbuyAlpha:Float, dataObj:Dynamic, propertyName:String) {
    super();

    this.x = x;
    this.y = y;
    this.dataObj = dataObj;
    this.propertyName = propertyName;
    this.normalSprite = sprite.clone();
    this.normalSprite.color = normalColor;
    this.hoverSprite = sprite.clone();
    this.hoverSprite.color = hoverColor;
    this.clickSprite = sprite.clone();
    this.clickSprite.color = clickColor;
    this.cantbuySprite = new FlxSprite(0, 0).loadGraphic("assets/images/cant.png");
    this.cantbuySprite.alpha = cantbuyAlpha;

    layerLow = new FlxGroup();
    layerMedium = new FlxGroup();
    layerTop = new FlxGroup();

    // mouse events
    {
      spriteHitbox = new FlxObject(0, 0, 32, 32);
      MouseEventManager.add(
        spriteHitbox,
        function(downObj) {
          if (buyable) {
            layerLow.remove(normalSprite);
            layerLow.remove(hoverSprite);
            layerLow.add(clickSprite);
          }
          layerTop.remove(popupBG);
          layerTop.remove(infoText);
          layerTop.remove(costText);
        },
        function(upObj) {
          if (buyable) {
            layerLow.remove(normalSprite);
            layerLow.add(hoverSprite);
            layerLow.remove(clickSprite);
            Clickercabra.doBuy(dataObj, propertyName);
          }
          layerTop.remove(popupBG);
          layerTop.remove(infoText);
          layerTop.remove(costText);
        },
        function(overObj) {
          if (buyable) {
            layerLow.remove(normalSprite);
            layerLow.add(hoverSprite);
            layerLow.remove(clickSprite);
          }
          layerTop.add(popupBG);
          layerTop.add(infoText);
          layerTop.add(costText);
        },
        function(outObj) {
          if (buyable) {
            layerLow.add(normalSprite);
            layerLow.remove(hoverSprite);
            layerLow.remove(clickSprite);
          }
          layerTop.remove(popupBG);
          layerTop.remove(infoText);
          layerTop.remove(costText);
        }
      );
      add(spriteHitbox);
    }
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
      popupBG.loadGraphic("assets/images/popup.png");
      infoText = new FlxText(0, 0, 120, null, 8);
      infoText.color = 0xFF000000;
      costText = new FlxText(0, 0, 120, null, 8);
      costText.color = 0xFF000000;
    }
    // add stuff using layers
    {
      add(normalSprite);
      add(countText);
      add(rateText);
      add(layerLow);
      add(layerMedium);
      add(layerTop);
    }
  }

  override public function update():Void
  {
    // TODO: position things on item position
    {
      spriteHitbox.x = normalSprite.x = hoverSprite.x = clickSprite.x = cantbuySprite.x = x + 0;
      spriteHitbox.y = normalSprite.y = hoverSprite.y = clickSprite.y = cantbuySprite.y = y + 0;

      countText.x = x + 40;
      countText.y = y + 4;
      rateText.x = x - 4;
      rateText.y = y + 32;

      popupBG.x = x + 18;
      popupBG.y = y - 86;
      infoText.x = costText.x = x + 24;
      infoText.y = y - 82;
      costText.y = y - 23;
    }
    // update sprite buyable
    {
      buyable = Clickercabra.canBuy(dataObj, propertyName);
      if (buyable) {
        layerMedium.remove(cantbuySprite);  
      } else {
        layerMedium.add(cantbuySprite);      
      }
    }
    // update texts
    {
      countText.text = Clickercabra.formatBigNum(Reflect.field(dataObj, propertyName));
      rateText.text = Clickercabra.rateString(dataObj, propertyName);
      infoText.text = Clickercabra.infoString(dataObj, propertyName);
      costText.text = Clickercabra.costString(dataObj, propertyName);
    }
    super.update();
  }
}