package;

import flixel.FlxState;
import object.ReceptorStrumNote;

class PlayState extends FlxState
{
	override public function create()
	{
		super.create();
		trace('fuck');
		add(new ReceptorStrumNote());

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
