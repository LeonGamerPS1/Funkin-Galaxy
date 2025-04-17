package object;

class Strumline extends FlxGroup
{
	public var strums:FlxTypedSpriteGroup<Strum>;
	public var notes:FlxTypedGroup<Note>;
	public var cpu:Bool = false;

	public function new(x:Float = 0, y:Float = 0, ?skin:String = 'default')
	{
		super();

		strums = new FlxTypedSpriteGroup<Strum>(x, y);
		add(strums);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		generateStrums(skin);
	}

	function generateStrums(skin:String = 'default', i:Int = 4)
	{
		for (i in 0...i)
		{
			var strum = strums.add(new Strum(i, skin));
			strum.applyPosition(strums.x + ((160 * 0.7) * i), strums.y);
		}
	}
}
