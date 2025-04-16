package object;

class Strum extends FlxSprite
{
	var id = 0;

	public var skin:NoteSkinData;

	public function new(id:Int = 0, ?skin:String = "default")
	{
		super();
		this.id = id;
		this.skin = NoteSkinConfig.getSkin(skin);

		applySkin();
	}

	public static var directions:Array<String> = ["left", "down", "up", "right"];

	public function applySkin()
	{
		var img = Assets.getAtlas(skin.image);
		if (img == null)
			skin = NoteSkinConfig.getSkin('default');

		frames = img;

		animation.addByPrefix('static', '${directions[id]} static', 24, false);
		animation.addByPrefix('confirm', '${directions[id]} confirm', 24, false);
		antialiasing = true;

		setGraphicSize(width * skin.scaleFactor);
		updateHitbox();

		playAnim('static');
	}

	public function playAnim(name:String = "static", ?force:Bool = false)
	{
		animation.play(name, force);

		centerOffsets();
		centerOrigin();
	}

	public function applyPosition(x:Float = 0, y:Float = 0):Strum
	{ // exists because setPosition  stinky.. hehh...
		setPosition(x, y);
		return this;
	}
}
