package object;

class Playfield extends FlxGroup
{
	var playerStrums:Strumline;
	var opponentStrums:Strumline;

	public function new(skin:String = 'default', downScroll:Bool = false)
	{
		super();

		opponentStrums = new Strumline(50, downScroll ? FlxG.height - 150 : 50, skin);
		add(opponentStrums);

		playerStrums = new Strumline(100 + (FlxG.width / 2), downScroll ? FlxG.height - 150 : 50, skin);
		add(playerStrums);
	}
}
