package funkin.play.character;

import animate.FlxAnimate;
import animate.FlxAnimateFrames;
import funkin.scripted.ScriptedCharacter.ScriptedBaseCharacter;
import haxe.ui.navigation.INavigatableView;
#if polymod
import polymod.hscript.HScriptable.Script;
#end

typedef CharacterData =
{
	var icon:String;
	var texture:String;

	var cameraOffset:{x:Float, y:Float};
	var positionOffset:{x:Float, y:Float};
	var scale:Float;

	var flipX:Bool;
	var dancer:Bool;
	var antialiasing:Bool;

	var holdSteps:Float;
	var animations:Array<CharacterAnimation>;
}

typedef CharacterAnimation = AnimationData &
{
	var offset:{x:Float, y:Float};
}

class BaseCharacter extends FlxSprite
{
	public var offsets:Map<String, {x:Float, y:Float}> = [];
	public var curCharacter = '';
	public var isPlayer:Bool = false;
	public var json:CharacterData;
	public var dancer = false;
	public var holdTimer:Float = 0;

	public function new(char:String = 'default', isPlayer:Bool = false)
	{
		super();
		this.curCharacter = char;
		this.isPlayer = isPlayer;
		loadJSON(char);
	}

	public var atlas:FlxAnimate;

	public function loadJSON(char:String = 'default')
	{
		this.json = null;
		frames = null;
		offsets.clear();

		if (Paths.exists(Paths.getPath('images/characters/$char/Animation.json')))
			initAtlas(char);

		var path = Paths.getPath('characters/$char.json');

		if (!Paths.exists(path))
			path = Paths.getPath('characters/bf.json');
		trace(path);

		this.json = cast Json.parse(Paths.getText(path));

		this.dancer = json.dancer;
		this.antialiasing = json.antialiasing;

		if (atlas == null)
			frames = Paths.getAtlas(json.texture);

		for (animData in json.animations)
		{
			if (animData.indices != null && animData.indices.length > 0)
			{
				animation.addByIndices(animData.name, animData.prefix, animData.indices, '', animData.fps, animData.looped, animData.flipX, animData.flipY);
				try
				{
					if (atlas != null)
						atlas.anim.addBySymbolIndices(animData.name, animData.prefix, animData.indices, animData.fps, animData.looped, animData.flipX,
							animData.flipY);
				}
				catch (e:Dynamic) {}
			}
			else
			{
				animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped, animData.flipX, animData.flipY);
				try
				{
					if (atlas != null)
						atlas.anim.addBySymbol(animData.name, animData.prefix, animData.fps, animData.looped, animData.flipX, animData.flipY);
				}
				catch (e:Dynamic) {}
			}

			offsets.set(animData.name, animData.offset);
		}
		playAnim(!dancer ? 'idle' : 'danceLeft');
		scale.set(json.scale, json.scale);
		updateHitbox();
		playAnim(!dancer ? 'idle' : 'danceLeft');
		flipX = (json.flipX != isPlayer);
		// load();
	}

	function initAtlas(char:String)
	{
		atlas = new FlxAnimate(x, y);
		atlas.frames = FlxAnimateFrames.fromAnimate(Paths.getPath('images/characters/$char'));
	}

	public function playAnim(anim:String = "idle", ?force:Bool = false)
	{
		animation.play(anim, force);
		if (offsets.exists(anim))
			offset.set(offsets[anim].x, offsets[anim].y);
		if (atlas != null)
		{
			atlas.anim.play(anim, force);
			atlas.offset.set(offsets[anim].x, offsets[anim].y);
		}
	}

	public static var SingAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	// execute this shit before wasgoodhit becomes true
	public function sing(note:Note, force:Bool = true, ?play:Bool = true)
	{
		if (note != null && play)
			playAnim(SingAnimations[note.noteData.data % SingAnimations.length], force);
		holdTimer = Conductor.instance.stepCrochet * json.holdSteps / 1000;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (atlas != null)
			atlas.update(elapsed);
		if (holdTimer > 0)
		{
			holdTimer -= elapsed;
			if (holdTimer < 0.01)
			{
				holdTimer = 0;
				playAnim(!dancer ? 'idle' : 'danceLeft');
			}
		}
	}

	public function load(arg:Int)
	{
		trace(this);
	}

	public function dance(beat:Float)
	{
		if (dancer)
		{
			if (animation.name != 'danceLeft' && holdTimer == 0)
				playAnim('danceLeft', true);
			else if (animation.name == 'danceLeft' && holdTimer == 0)
				playAnim('danceRight', true);
		}
		else
		{
			if ((animation.finished) && holdTimer == 0)
				playAnim('idle', true);
		}
	}

	override function draw()
	{
		@:privateAccess
		if (atlas != null)
		{
			atlas.setPosition(x, y);
			atlas.scale = scale;
			atlas.width = width;
			atlas.height = height;
			atlas.offset = offset;
			atlas.origin = origin;
			atlas.alpha = alpha;
			atlas.visible = visible;
			atlas.alive = this.alive;
			atlas.exists = exists;
			atlas.antialiasing = antialiasing;
			atlas.blend = blend;
			atlas.colorTransform = colorTransform;
			atlas.active = active;
			atlas.angle = angle;
			atlas.flipX = flipX;
			atlas.flipY = flipY;
			atlas.draw();
		}
		else
			super.draw();
	}

	public static function makeCharacter(char:String, isPlayer:Bool = false):BaseCharacter
	{
		#if polymod
		for (char2 in ScriptedBaseCharacter.listScriptClasses())
		{
			if (char.replace('-', '').toLowerCase() == char2.toLowerCase())
				return ScriptedBaseCharacter.init(char2, char, isPlayer);
			else
				continue;
		}
		#end
		var character:BaseCharacter = new BaseCharacter(char, isPlayer);

		return character;
	}
}
