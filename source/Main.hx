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
		trace(ScriptedStage.listScriptClasses());
		super();

		addChild(new FlxGame(0, 0, InitState, 124, 124));
	}
}
