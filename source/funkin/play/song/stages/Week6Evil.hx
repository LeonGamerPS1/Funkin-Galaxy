package funkin.play.song.stages;

import flixel.addons.effects.FlxTrail;

class Week6Evil extends BaseStage
{
	var bg:BGSprite;

	override function create()
	{
		var posX = 400;
		var posY = 200;

		bg = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
		bg.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		bg.antialiasing = false;
		add(bg);
	}

	override function createPost()
	{
		var trail:FlxTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
		remove(dad);
		add(trail);
		add(dad);
	}
}
