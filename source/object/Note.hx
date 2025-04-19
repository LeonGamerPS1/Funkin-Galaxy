package object;

import backend.Song.NoteData;

class Note extends FlxSprite
{
	public var noteData:NoteData;
	public var skin:NoteSkinData;

	public var wasGoodHit:Bool = false;
	public var inHitZone:Bool = false;
	public var sustainAngle:Float = 90;

	public function new(noteData:NoteData, ?skin:String = "default")
	{
		super(0, -6000);
		this.noteData = noteData;
		this.noteData = noteData;
		this.skin = NoteSkinConfig.getSkin(skin);

		applySkin();
	}

	public function applySkin()
	{
		var img = Assets.getAtlas(skin.image);
		if (img == null)
			skin = NoteSkinConfig.getSkin('default');

		frames = img;

		animation.addByPrefix('static', '${Strum.directions[noteData.data]}0', 24, false);
		animation.addByPrefix('hold', '${Strum.directions[noteData.data]} hold piece0', 24, false);
		animation.addByPrefix('end', '${Strum.directions[noteData.data]} hold end0', 24, false);

		antialiasing = skin.antialiasing;
		playAnim('static');
		updateHitbox();

		setGraphicSize(width * skin.scaleFactor);
		updateHitbox();
	}

	public var speed:Float = 0;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var ignoreNote:Bool = false;
	public var multAlpha:Float = 1;
	public var flipSustain:Bool = false;

	public var sustain:Sustain;

	public function followStrum(strum:Strum, ?speed:Float = 1)
	{
		this.speed = speed;
		alpha = strum.alpha * multAlpha;

		if (!wasGoodHit)
		{
			x = strum.x + offsetX;
			y = strum.y + (noteData.time - Conductor.instance.time) * (0.45 * (!strum.downScroll ? speed : -speed));
		}
		else
			setPosition(strum.x + offsetX, strum.y + offsetY);
		visible = !wasGoodHit;
		flipSustain = strum.downScroll;
	}

	public function playAnim(name:String = "static", ?force:Bool = false)
	{
		animation.play(name, force);

		centerOffsets();
		centerOrigin();
	}

	public function applyPosition(x:Float = 0, y:Float = 0):Note
	{ // exists because setPosition  stinky.. hehh...
		setPosition(x, y);
		return this;
	}

	public var strumline:Strumline; // mainly used for hit stuff
	public var sustainHit:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (strumline == null)
			return;

		if (strumline.cpu)
		{
			if (noteData.time <= Conductor.instance.time)
				wasGoodHit = true;
		}
		else
		{
			if (noteData.time > Conductor.instance.time - Conductor.safeZoneOffset
				&& noteData.time < Conductor.instance.time + (Conductor.safeZoneOffset * 0.5))
				inHitZone = true;
			else
				inHitZone = false;
		}
	}
}
