package funkin.play.objects;


class MenuItem extends FlxSprite
{
	public function new(img:String = "story-mode")
	{
		super();
		frames = Paths.getSparrowAtlas('menu/mainmenu/$img');
		animation.addByPrefix('idle', img.replace('-', ' ') + ' basic', 24);
		animation.addByPrefix('selected', img.replace('-', ' ') + ' white', 24);
		kiss('idle');
		updateHitbox();
        antialiasing = true;
		kiss('idle');
        scrollFactor.set(1,0.7);
	}

	public function kiss(a:String)
	{
		animation.play(a, true);
		centerOffsets();
		centerOrigin();
	}
}
