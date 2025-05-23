package object;

import flixel.addons.display.FlxBackdrop;

class BackgroundGirls extends FlxSprite
{
	var isPissed:Bool = true;
	var thing:FlxBackdrop;

	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = Assets.getAtlas('weeb/bgFreaks');
		antialiasing = false;
		swapDanceType();

		setGraphicSize(Std.int(width * 6));
		updateHitbox();
		animation.play('danceLeft');
	}

	var danceDir:Bool = false;

	public function swapDanceType():Void
	{
		isPissed = !isPissed;
		if (!isPissed)
		{ // Gets unpissed
			animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), '', 24, false);
			animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), '', 24, false);
		}
		else
		{ // Pisses
			animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), '', 24, false);
			animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), '', 24, false);
		}
		dance();
	}

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
