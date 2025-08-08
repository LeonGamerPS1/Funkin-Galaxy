package funkin.play.notes;

import flixel.system.FlxAssets;

class Note extends FlxSprite
{
	public var noteData:NoteData = null;
	public var skin(default, set):String;
	public var downScroll:Bool = false;
	public var set:FlxPoint = FlxPoint.get();
	public var strumLine:StrumLine;

	public var parent(default, default):Note;
	public var sustainAngle(get, default):Float = 90;
	public var flipSustain:Bool = false;
	public var speed:Float = 1;
	public var sustain:Sustain;
	public var selected:Bool = false;

	public function new(?noteData:NoteData, ?texture:String = "default", ?strumLine:StrumLine)
	{
		super(-500);
		this.noteData = noteData;
		this.strumLine = strumLine;
		this.skin = texture;
		this.noteData = noteData;

		reload();
	}

	function set_skin(value:String):String
	{
		skin = value;

		return skin = value;
	}

	public static var dirs:Array<String> = ['purple', 'blue', 'green', 'red'];

	public var editing = false;

	public function reload(?skin:String)
	{
		if (noteData == null)
			return this;
		skin ??= this.skin;
		var skinData = parseSkin(skin);
		var data = noteData.data;
		this.skinData = skinData;
		frames = Paths.getAtlas('notes/$skin/notes');
		animation.addByPrefix('arrow', dirs[data % dirs.length] + '0');
		animation.addByPrefix('hold', dirs[data % dirs.length] + ' hold piece0', 24, false);
		animation.addByPrefix('end', dirs[data % dirs.length] + ' hold end0', 24, false);

		var sizeMult:Float = strumLine != null ? strumLine.size : 1;
		playAnim('arrow');

		scale.set(skinData.scale, skinData.scale);
		scale.x *= sizeMult;
		scale.y *= sizeMult;
		updateHitbox();
		antialiasing = skinData.antialiasing;
		return this;
	}

	public var skinData(default, null):Dynamic;

	static function parseSkin(skin:String)
	{
		var path = 'assets/images/notes/$skin/_meta.json';
		var jsonRaw:String = Paths.getText(path);
		return Json.parse(jsonRaw);
	}

	public function playAnim(n:String = 'arrow', ?force:Bool = false)
	{
		animation.play(n, force);

		centerOffsets();
		centerOrigin();
	}

	public var wasGoodHit:Bool = false;
	public var multAlpha:Float = 1;
	public var ignoreNote:Bool = false;
	public var canBeHit:Bool = false;
	public var holdTime:Float = 0;

	override function destroy()
	{
		set.put();
		super.destroy();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (wasGoodHit)
			holdTime += elapsed;

		canBeHit = (noteData.time <= Conductor.instance.time + Conductor.safeZoneOffset * 0.5
			&& !(noteData.time <= Conductor.instance.time - Conductor.safeZoneOffset * 0.5));
	}

	var distance:Float = 3000;
	var multSpeed:Float = 1;

	public function followStrumNote(myStrum:Strum, songSpeed:Float = 1)
	{
		var strumX:Float = myStrum.x;
		var strumY:Float = myStrum.y;
		var strumAngle:Float = myStrum.angle;
		var strumAlpha:Float = myStrum.alpha;
		var strumDirection:Float = myStrum.direction;

		speed = songSpeed * multSpeed;
		distance = (0.45 * (Conductor.instance.time - noteData.time) * speed);

		downScroll = myStrum.downScroll;
		if (!myStrum.downScroll)
			distance *= -1;

		var angleDir = strumDirection * Math.PI / 180;

		angle = strumAngle;
		alpha = strumAlpha * multAlpha;
		x = strumX + set.x + Math.cos(angleDir) * distance;
		y = strumY + set.y + Math.sin(angleDir) * distance;
	}

	function get_sustainAngle():Float
	{
		return (sustainAngle + (strumLine != null ? strumLine.strums.members[noteData.data].direction : 0)) - 90;
	}

	override function kill()
	{
		sustain = null;
		super.kill();
	}

	public function setup(noteData:NoteData, ?skinName:String = "default")
	{
		visible = true;
		revive();
		wasGoodHit = false;
		this.noteData = noteData;
		editing = false;
		flipSustain = false;

		speed = 1;
		selected = false;
		holdTime = 0;
		downScroll = false;
		set.set();

		return reload(skinName);
	}
}
