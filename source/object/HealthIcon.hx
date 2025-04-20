package object;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var char:String = '';
	public var isPlayer:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super(0, 0);

		this.isPlayer = isPlayer;

		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public var winningIconFrame:Int = 0; // defaults to the alive/active icon, not the death or winning icon

	public function changeIcon(newChar:String):Void
	{
		if (newChar != char)
		{
			if (animation.getByName(newChar) == null)
			{
				var path = "icons/icon-" + newChar;
				if (!Assets.exists(Assets.getAssetPath('images/icons/icon-$newChar.png')))
					path = "icons/icon-questionmark";

				loadGraphic(Assets.image(path));
				var frames:Array<Int> = [];

				for (i in 0...Math.floor(width / 150))
					frames.push(i);
				trace(frames.length + ' frames found for icon $newChar');

				if (frames.contains(2))
					winningIconFrame = 2; // actually the third frame but haxe shitty starts array stuff at 0 iirc

				loadGraphic(Assets.image(path), true, 150, 150);

				animation.add(newChar, frames, 0, false, isPlayer);
				updateHitbox();
			}
			animation.play(newChar);
			char = newChar;
		}

	
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
