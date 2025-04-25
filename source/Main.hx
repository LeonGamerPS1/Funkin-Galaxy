package;

import flixel.FlxGame;
import modding.PolymodHandler;
import openfl.display.Sprite;
import states.InitState;

class Main extends Sprite
{
	public function new()
	{

		PolymodHandler.init(OPENFL);
		super();

		addChild(new FlxGame(0, 0, InitState, 60, 60));
	}
}
