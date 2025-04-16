package;

import flixel.FlxState;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();
		trace('fuck');
		add(new Strumline());

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
