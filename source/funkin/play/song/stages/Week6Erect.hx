package funkin.play.song.stages;

import flixel.addons.display.FlxBackdrop;
#if !flash
import funkin.shaders.DropShadowShader;
#end
class Week6Erect extends BaseStage
{
	var bgSky:FlxBackdrop = new FlxBackdrop(Paths.image('weeb/erect/weebSky'), XY);

	override function create()
	{
		bgSky.scrollFactor.set(0.1, 0.1);
		add(bgSky);
		bgSky.antialiasing = false;

		var repositionShit = -200;

		var bgSchool:BGSprite = new BGSprite('weeb/erect/weebSchool', -400, 12, 0.95, 0.95);
		add(bgSchool);
		bgSchool.antialiasing = false;

		var bgStreet:BGSprite = new BGSprite('weeb/erect/weebStreet', repositionShit, -6 * 2, 0.95, 0.95);
		add(bgStreet);
		bgStreet.antialiasing = false;

		var widShit = Std.int(bgSky.width * PlayState.daPixelZoom);

		var treeLeaves:BGSprite = new BGSprite('weeb/erect/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
		treeLeaves.setGraphicSize(widShit);
		treeLeaves.updateHitbox();
		add(treeLeaves);
		treeLeaves.antialiasing = false;

		bgSky.setGraphicSize(widShit);
		bgSchool.setGraphicSize(widShit);
		bgStreet.setGraphicSize(widShit);

		bgSky.updateHitbox();
		bgSchool.updateHitbox();
		bgStreet.updateHitbox();
	}

	override function createPost()
	{
		// i hope this works
		dropShadow(dad, 0);
		dropShadow(boyfriend, 1);
		dropShadow(gf, 2);
	}

	// this adds the dropshadow, the variable named "type" is for deciding what mask it should use i think????
	static public function dropShadow(character:BaseCharacter, type:Int)
	{
		#if !flash
		var rim:DropShadowShader = new DropShadowShader();
		rim.setAdjustColor(-66, -10, 24, -23);
		rim.color = 0xFF52351d;
		rim.antialiasAmt = 0;
		rim.attachedSprite = character;
		rim.distance = 5;
		character.shader = rim;

		character.animation.onFrameChange.add(function(anim:String, frame:Int, frameIndex:Int)
		{
			rim.updateFrameInfo(character.frame);
		});

		switch (type)
		{
			case 0:
				rim.angle = 90;
				character.shader = rim;

				rim.loadAltMask(Paths.getPath('weeb/erect/masks/senpai_mask.png'));
				rim.maskThreshold = 1;
				rim.useAltMask = true;
			case 1: // bf
				rim.setAdjustColor(-66, -10, 24, -23);
				rim.angle = 90;
				character.shader = rim;

				rim.loadAltMask(Paths.getPath('weeb/erect/masks/bfPixel_mask.png'));
				rim.maskThreshold = 1;
				rim.useAltMask = true;
			case 2: // gf
				rim.setAdjustColor(-42, -10, 5, -25);
				rim.angle = 90;
				character.shader = rim;
				rim.distance = 3;
				rim.threshold = 0.3;

				rim.loadAltMask(Paths.getPath('weeb/erect/masks/gfPixel_mask.png'));
				rim.maskThreshold = 1;
				rim.useAltMask = true;
		}
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		bgSky.x += 0.6;
	}
}
