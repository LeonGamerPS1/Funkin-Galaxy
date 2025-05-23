package object.stages;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Spooky extends BaseStage
{
	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	override function create()
	{
		halloweenBG = new BGSprite('halloween_bg', -200, -100, 1, 1, ['halloweem bg0', 'halloweem bg lightning strike']);

		add(halloweenBG);

		if (PlayState.isStoryMode && PlayState.song.songName == 'monster')
			setStartCallback(monsterCutscene);
	}

	override function createPost()
	{
		halloweenWhite = new BGSprite(null, -800, -400, 0, 0);
		halloweenWhite.makeGraphic(FlxG.width * 2, FlxG.height * 2);
		halloweenWhite.alpha = 0;
		add(halloweenWhite);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Assets.sound('thunder_1'));
		halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = Math.floor(curBeat);
		lightningOffset = FlxG.random.int(8, 24);

		if (boyfriend.hasAnimation('scared'))
			boyfriend.playAnim('scared', true);

		if (dad.hasAnimation('scared'))
			dad.playAnim('scared', true);

		if (gf != null && gf.hasAnimation('scared'))
			gf.playAnim('scared', true);

		halloweenWhite.alpha = 0.4;
		FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
		FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
	}

	function monsterCutscene()
	{
		PlayState.instance.camHUD.alpha = 0;

		FlxG.camera.focusOn(new FlxPoint(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100));

		// character anims
		FlxG.sound.play(Assets.sound('thunder_1'));
		if (gf != null)
			gf.playAnim('scared', true);
		boyfriend.playAnim('scared', true);

		// white flash
		var whiteScreen:FlxSprite = new FlxSprite().makeGraphic(3333, 3333, FlxColor.WHITE);
		whiteScreen.scrollFactor.set();
		add(whiteScreen);
		FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
			startDelay: 0.1,
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				remove(whiteScreen);
				whiteScreen.destroy();

				FlxTween.tween(PlayState.instance.camHUD, {alpha: 1}, ((60 / 150) / 4) * 2 / 1000, {ease: FlxEase.linear});
				startCountdown();
			}
		});
	}
}
