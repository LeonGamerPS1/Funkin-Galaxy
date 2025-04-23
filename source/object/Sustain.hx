package object;

class Sustain extends TiledSprite
{
	var parent:Note;

	public function new(parent:Note)
	{
		super(-3000, 0);
		this.parent = parent;
		parent.sustain = this;

		init();
	}

	function init()
	{
		normal();
	}

	inline function normal()
	{
		frames = parent.frames;
		animation.copyFrom(parent.animation);

		animation.play('hold');
		setTail('end');
		updateHitbox();

		setGraphicSize(width * parent.skin.scaleFactor * parent.strumline.scale);
		updateHitbox();

		antialiasing = parent.antialiasing;
	}

	override function update(elapsed:Float)
	{
		var length:Float = parent.noteData.length;

		if (parent.wasGoodHit)
			length -= Math.abs(parent.noteData.time - Conductor.instance.time);

		var expectedHeight:Float = (length * 0.45 * parent.speed) + tailHeight();
		if (height != expectedHeight)
			this.height = Math.max(expectedHeight, 0);

		if (alpha != parent.alpha)
			alpha = parent.alpha;

		regenPos();

		super.update(elapsed);
	}

	public inline function regenPos()
	{
		setPosition(parent.x + ((parent.width - width) * 0.5), parent.y + (parent.height * 0.5));

		var calcAngle:Float = 0;
		calcAngle += parent.sustainAngle - 90;
		if (parent.flipSustain)
		{
			angle = calcAngle + 180;
			y -= 30;
		}
		else
			angle = calcAngle;
	}
}
