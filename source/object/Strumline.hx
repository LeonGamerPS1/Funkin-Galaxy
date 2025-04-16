package object;

class Strumline extends FlxGroup
{
	public var strums:FlxTypedSpriteGroup<Strum>;

	public function new(x:Float = 0, y:Float = 0, ?skin:Int = 0)
	{
		super();

		strums = new FlxTypedSpriteGroup<Strum>(x, y);
		add(strums);

		generateStrums();
	}

	function generateStrums(skin:String = 'default', i:Int = 4)
	{
		for (i in 0...i)
			strums.add(new Strum(i, skin).applyPosition(strums.x + 160 * NoteSkinConfig.getSkin(skin).scaleFactor * i, strums.y));
	}
}
