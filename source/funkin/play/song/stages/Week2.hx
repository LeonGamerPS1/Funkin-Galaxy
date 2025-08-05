package funkin.play.song.stages;

import flixel.addons.effects.FlxTrail;

class Week2 extends BaseStage
{
	var halloweenBG:BGSprite;

	override function create()
	{
		halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
		add(halloweenBG);
	}
}
