package funkin.play.notes;

class Strum extends FlxSprite
{
	public var data:Int = 0;
	public var skin(default, set):String;
	public var downScroll:Bool = false;
	public var strumLine:StrumLine;
	public var direction:Float = 90;
	public var r:Float = 0;
	public var cover:SustainCover;
	#if mobile
	public var tapBox:FlxObject; // tap hitbox

	#end
	public function new(data:Int = 0, ?texture:String = "default", ?strumLine:StrumLine)
	{
		super();
		this.data = data;
		this.strumLine = strumLine;
		this.skin = texture;

		cover = new SustainCover(this);
		reload();
		#if mobile
		tapBox = new FlxObject(0, 0, 0, 0);
		#end
	}

	function set_skin(value:String):String
	{
		skin = value;

		return skin = value;
	}

	public static var dirs:Array<String> = ['left', 'down', 'up', 'right'];

	public var skinData:Dynamic = null;

	public function reload()
	{
		var skinData = parseSkin(skin);
		this.skinData = skinData;
		frames = Paths.getAtlas('notes/$skin/notes');
		var fps:Float = skinData.fps ?? 24;
		animation.addByPrefix('static', dirs[data % dirs.length] + '0', fps);
		animation.addByPrefix('confirm', dirs[data % dirs.length] + ' confirm0', fps, false);
		animation.addByPrefix('press', dirs[data % dirs.length] + ' press0', fps, false);

		playAnim('static');

		var size:Float = strumLine != null ? strumLine.size : 1;
		scale.set(skinData.scale, skinData.scale);
		scale.x *= size;
		scale.y *= size;
		updateHitbox();

		antialiasing = skinData.antialiasing;
		cover.setup(this);
	}

	function parseSkin(skin:String)
	{
		var path = 'assets/images/notes/$skin/_meta.json';
		var jsonRaw:String = Paths.getText(path);
		return Json.parse(jsonRaw);
	}

	public function playAnim(n:String = 'static', ?force:Bool = false)
	{
		animation.play(n, force);

		centerOffsets();
		centerOrigin();
		if (n != 'confirm')
			active = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		#if mobile
		if (tapBox.cameras != cameras)
			tapBox.cameras = cameras;
		tapBox.x = x - (tapBox.width / 2) + (width / 2);
		tapBox.y = 0;
		// tapBox.width = width * 1.5;
		tapBox.height = FlxG.height;
		#end

		if (r != 0)
		{
			r -= elapsed;
			if (r <= 0)
			{
				r = 0;
				playAnim('static');
			}
		}
	}
}
