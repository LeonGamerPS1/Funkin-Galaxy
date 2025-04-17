package object;

import backend.Song.NoteData;

class Note extends FlxSprite
{
	public var noteData:NoteData;
	public var skin:NoteSkinData;

	public var wasGoodHit:Bool = false;
	public var inHitZone:Bool = false;

	public function new(noteData:NoteData, ?skin:String = "default")
	{
		super();
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

		animation.addByPrefix('static', '${Strum.directions[noteData.data]}', 24, false);
		animation.addByPrefix('confirm', '${Strum.directions[noteData.data]}', 24, false);
		antialiasing = true;
		playAnim('static');
		updateHitbox();

		setGraphicSize(width * skin.scaleFactor);
		updateHitbox();
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
}
