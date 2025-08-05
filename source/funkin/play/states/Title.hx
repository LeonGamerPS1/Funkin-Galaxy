package funkin.play.states;

import flixel.addons.display.FlxBackdrop;
import flixel.tile.FlxTile;

class Title extends FlxUIState
{
	var girl:BaseCharacter;
	var logo:FlxSprite;
	var enter:FlxSprite;
	var grid:FlxBackdrop;
	var grid2:FlxBackdrop;

	override function create()
	{
		FlxTransitionableState.skipNextTransOut = true;
		super.create();
		Conductor.instance.changeBpmAt(0, 102);
		Conductor.instance.onBeat.add(beat);

		grid = new FlxBackdrop(Paths.image('grid'), XY);
		grid.velocity.set(6 * 12, 2.5 * 12);
		grid.color = FlxColor.PURPLE;
		grid.alpha = 0.5;
		add(grid);

		grid2 = new FlxBackdrop(Paths.image('grid'), XY);
		grid2.velocity.set(-6 * 12, -2.5 * 12);
		grid2.color = FlxColor.CYAN;
		grid2.alpha = 0.5;
		add(grid2);

		girl = BaseCharacter.makeCharacter('gf', true);
		girl.x += 700;
		girl.y += 50;
		add(girl);
		// uhh
		logo = new FlxSprite(-150, -100);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.animation.addByPrefix('bop', 'logo bumpin0', 24, false);
		logo.animation.play('bop');
		logo.updateHitbox();
		logo.centerOffsets();
		logo.scrollFactor.set(0.7, 0.7);
		logo.centerOrigin();
		logo.antialiasing = true;
		add(logo);

		FlxG.sound.playMusic(Paths.getPath('music/freakyMenu.ogg'));
	}

	var gay = false;

	override function update(elapsed:Float)
	{
		Conductor.instance.time = FlxG.sound.music.time;
		if (Controls.instance.justPressed.UI_ACCEPT && !gay)
		{
			gay = true;
			fade(() ->
			{
				FlxG.switchState(new MainMenu());
			});
		}

		super.update(elapsed);
	}

	public function fade(call:Void->Void)
	{
		FlxG.sound.play(Paths.sound('menu/confirmMenu'));
		camera.flash();
		FlxTimer.wait(0.75, () ->
		{
			FlxTween.tween(camera, {"scroll.y": 200, alpha: 0}, 1.15, {
				ease: FlxEase.backIn,
				onComplete: (t) ->
				{
					Conductor.instance.onBeat.remove(beat);
					call();
				}
			});
		});
	}

	public function beat(b:Float)
	{
		logo.animation.play('bop', true);
		logo.centerOffsets();
		logo.centerOrigin();

		girl.dance(b);
	}
}
