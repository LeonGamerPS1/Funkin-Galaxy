package funkin.play.character;

class HealthIcon extends FlxSprite
{
	public var isPlayer:Bool = false;

	public function new(id:String = 'default', ?isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(id, isPlayer);
		antialiasing = true;
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(id:String = 'default', ?isPlayer:Bool = false)
	{
		this.isPlayer = isPlayer;
		var img = Paths.image('icons/icon-$id');

		antialiasing = !(id.contains("-pixel") || id.contains("pixel"));
		if (img == null)
			img = Paths.image('icons/icon-face');

		loadGraphic(img);
		var iSize:Float = Math.round(img.width / img.height);
		loadGraphic(img, true, Math.floor(width / 2), Math.floor(height));
		animation.add(id, [0, 1], 0, false);
		animation.play(id);
		flipX = isPlayer;

		iconOffsets[0] = (width - 150) / iSize;
		iconOffsets[1] = (height - 150) / iSize;
		updateHitbox();
		lerpIconSize(true);
	}

	public var autoAdjustOffset:Bool = true;

	override function updateHitbox()
	{
		super.updateHitbox();
		if (autoAdjustOffset)
		{
			offset.x = iconOffsets[0];
			offset.y = iconOffsets[1];
		}
		origin.y = 0;
		// poop
	}

	public function getCharacter():String
	{
		return animation.name;
	}
	public var HEALTH_ICON_SIZE = 150.0;
	public var size = FlxPoint.get(1, 1);

	public function lerpIconSize(force:Bool = false):Void
	{
		// Lerp the health icon back to its normal size,
		// while maintaining aspect ratio.
		if (this.width > this.height)
		{
			// Apply linear interpolation while accounting for frame rate.
			var targetSize:Int = Std.int(MathUtil.smoothLerpPrecision(this.width, HEALTH_ICON_SIZE * this.size.x, FlxG.elapsed, 0.512));

			if (force)
				targetSize = Std.int(HEALTH_ICON_SIZE * this.size.x);

			setGraphicSize(targetSize, 0);
		}
		else
		{
			var targetSize:Int = Std.int(MathUtil.smoothLerpPrecision(this.height, HEALTH_ICON_SIZE * this.size.y, FlxG.elapsed, 0.512));

			if (force)
				targetSize = Std.int(HEALTH_ICON_SIZE * this.size.y);

			setGraphicSize(0, targetSize);
		}

		this.updateHitbox();
	}
}
