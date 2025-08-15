package funkin.play.notes;

class SustainCover extends FlxSprite
{
	public var parent:Strum;

	public function new(strum:Strum)
	{
		super();
		this.parent = strum;
		setup(strum);
	}

	public function setup(s)
	{
		var skinPath = 'notes/${parent.skin}/cover/${Note.dirs[parent.data % Note.dirs.length]}';

		if (Paths.exists('assets/images/notes/${parent.skin}/cover/cover.png'))
			skinPath = 'notes/${parent.skin}/cover/cover';
		var name = Note.dirs[parent.data % Note.dirs.length];
		frames = Paths.getAtlas(skinPath);
		animation.addByPrefix('start', 'start', 24);
		animation.addByPrefix('end', 'end', 30, false);
		animation.play('start');
		active = false;
		animation.onFinish.add((_) ->
		{
			if (_ == 'end')
			{
				animation.play('start', true);
				active = false;
			}
		});
	}

	override function update(elapsed:Float)
	{
		visible = active;
		super.update(elapsed);
	}
	override function draw()
	{
		if (!active)
			return;
		centerOffsets();
		centerOrigin();


		scale.set(parent.skinData.cover.scaleX, parent.skinData.cover.scaleY);
		setPosition(parent.x + parent.skinData.cover.offsetX, parent.y + parent.skinData.cover.offsetY);
		super.draw();
	}
}
