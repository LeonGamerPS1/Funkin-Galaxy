package funkin.play.notes;

import funkin.play.objects.TiledSprite;

class Sustain extends TiledSprite
{
	var parent:Note;

	public function new(parent:Note)
	{
		super(-3000, -3000);
		this.parent = parent;

		init(parent);
	}

	public function init(parent:Note):Sustain
	{
		this.parent = parent;

		if (parent != null)
		{
			parent.sustain = this;
			normal();
		}
		return this;
	}

	inline function normal()
	{
		frames = parent.frames;
		animation.copyFrom(parent.animation);

		animation.play('hold');
		setTail('end');
		updateHitbox();

		var mult:Float = parent.strumLine != null ? parent.strumLine.size : 1;
		scale.set(parent.skinData.sustainScale * mult, parent.skinData.sustainScale * mult);
		updateHitbox();

		antialiasing = parent.antialiasing;
	}

	var custom:Float = 0;

	override function draw()
	{
		offset.y = 0;
		origin.y = 0;
		var length:Float = parent.noteData.length;

		if (parent.wasGoodHit)
			length -= Math.abs(parent.noteData.time - Conductor.instance.time);

		var expectedHeight:Float = (length * 0.45 * parent.speed);
		if (custom > 0)
			expectedHeight = custom;

		if (height != expectedHeight)
			this.height = Math.max(expectedHeight, 0);

		if (alpha != parent.alpha)
			alpha = parent.alpha;

		regenPos();

		super.draw();
	}

	public inline function regenPos()
	{
		setPosition(parent.x + ((parent.width - width) * 0.5), parent.y + (parent.height / 2)); // because i modify offset.y, i must do this

		var calcAngle:Float = -90;
		calcAngle += parent.sustainAngle;
		if (parent.downScroll)
		{
			angle = calcAngle + 180;
		}
		else
			angle = calcAngle;
	}

	override function kill():Void
	{
		parent = null;
		super.kill();
	}
}
