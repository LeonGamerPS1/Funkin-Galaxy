package;

import backend.Song.SongMap;
import flixel.text.FlxText;
import haxe.io.Bytes;
import lime.ui.FileDialog;
import moonchart.formats.fnf.legacy.FNFPsych;
import openfl.net.FileReference;

class PlayState extends FlxState implements IStageState
{
	public static var isStoryMode(default, null):Bool = false;

	public var playfield:Playfield;
	public var tracks:Map<String, FlxSound> = [];

	public var startedCountdown:Bool = false;
	public var startedSong:Bool = false;

	public static var song:SongMap;

	public var camHUD:FunkinCamera = new FunkinCamera("hud");

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var gf:Character;
	public var bf:Character;
	public var dad:Character;

	// dont mess with these
	var lastEventIndex(default, null):Int = 0;

	public static var instance(default, null):PlayState;

	public var hudCameraZoomIntensity:Float = 0.015 * 2.0;

	override public function create()
	{
		instance = this;
		if (song == null)
			song = Song.grabSong();

		FlxG.cameras.reset(new FunkinCamera("play"));
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		Conductor.instance.reset(); // reset just incase something happens
		Conductor.instance.onBeat.removeAll();
		Conductor.instance.onStep.removeAll();
		Conductor.instance.onMeasure.removeAll();
		Conductor.instance.changeBpmAt(0, song.bpm, 4, 4);
		Conductor.instance.time = -Conductor.instance.crochet * 5;
		Conductor.instance.onStep.add(stepHit);
		Conductor.instance.onMeasure.add(measureHit);
		Conductor.instance.onBeat.add(beatHit);

		parseStage();
		initChars();

		playfield = new Playfield('default', song, false);
		playfield.cameras = [camHUD];
		add(playfield);
		playfield.addIcon(bf.json.health_icon, true);
		playfield.addIcon(dad.json.health_icon);

		for (value in playfield.strumlines)
		{
			value.character = !value.cpu ? bf : dad;
		}

		forEachStage((__) -> __.createPost());
		startCallback();

		super.create();
	}

	public var stageJson:StageFile;
	public var curStage:String = "";

	function parseStage()
	{
		// path ??= "stage";
		if (song.stage == null || song.stage.length < 1)
			song.stage = StageUtil.vanillaSongStage(song.songName);

		curStage = song.stage;
		if (song.players[1] == null || song.stage.length < 1)
			song.players[1] = StageUtil.vanillaGF(song.stage);

		if (Assets.exists('assets/stages/$curStage.json'))
			stageJson = cast Json.parse(Assets.getText('assets/stages/$curStage.json'));
		else
		{
			stageJson = cast Json.parse(Assets.getText('assets/stages/Stage.json'));
			curStage = "Stage";
		}
		if (stageJson.defaultCamZoom != null)
			defaultCamZoom = stageJson.defaultCamZoom;
		if (stageJson.bfOffsets != null && stageJson.bfOffsets.length > 1)
		{
			BF_X = stageJson.bfOffsets[0];
			BF_Y = stageJson.bfOffsets[1];
		}
		if (stageJson.dadOffsets != null && stageJson.dadOffsets.length > 1)
		{
			DAD_X = stageJson.dadOffsets[0];
			DAD_Y = stageJson.dadOffsets[1];
		}
		if (stageJson.gfOffsets != null && stageJson.gfOffsets.length > 1)
		{
			GF_X = stageJson.gfOffsets[0];
			GF_X = stageJson.gfOffsets[1];
		}
		if (stageJson.cam_bf != null && stageJson.cam_bf.length > 1)
			boyfriendCameraOffset = stageJson.cam_bf;
		if (stageJson.cam_gf != null && stageJson.cam_gf.length > 1)
			girlfriendCameraOffset = stageJson.cam_gf;
		if (stageJson.cam_dad != null && stageJson.cam_dad.length > 1)
			opponentCameraOffset = stageJson.cam_dad;

		switch curStage
		{
			case "Spooky":
				add(new Spooky(this, true));

			default:
				for (scriptedStage in ScriptedStage.listScriptClasses())
				{
					trace(scriptedStage);
					trace(scriptedStage == curStage);
					if (scriptedStage == curStage)
					{
						var stage:ScriptedStage = ScriptedStage.init(scriptedStage, this, false);

						stage.create();
						addStage(stage);
					}
				}
		}
	}

	public var boyfriendCameraOffset:Array<Float> = [0, 0];
	public var opponentCameraOffset:Array<Float> = [0, 0];
	public var girlfriendCameraOffset:Array<Float> = [0, 0];

	public var camFollow:FlxObject;

	function initChars()
	{
		dad = new Character(song.players[0]);
		gf = new Character(song.players[1]);
		bf = new Character(song.players[2], true);

		bf.setPosition(BF_X, BF_Y);
		gf.setPosition(GF_X, GF_Y);
		dad.setPosition(DAD_X, DAD_Y);

		for (_ in [dad, gf, bf])
			startChar(_);

		add(gf);
		add(dad);
		add(bf);
		camFollow = new FlxObject();
		moveCamera('dad');
		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.snapToTarget();
		add(camFollow);
	}

	inline function makeFlxColor(arr:Array<Int>)
	{
		return FlxColor.fromRGB(arr[0], arr[1], arr[2], 255);
	}

	function startChar(char:Character)
	{
		char.setPosition(char.x + char.json.position[0], char.y + char.json.position[1]);
	}

	public var stages:Array<BaseStage> = [];

	public function forEachStage(func_:BaseStage->Void):Void
	{
		if (func_ == null)
			return;
		for (i in 0...stages.length)
		{
			var stage:BaseStage = stages[i];
			func_(stage);
		}
	}

	public function addStage(stage:BaseStage)
	{
		if (!stages.contains(stage))
			stages.push(stage);
		add(stage);
	}

	override public function update(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(1, playfield.iconP1.scale.x, Math.exp(-elapsed * 14));
		playfield.iconP1.scale.set(mult, mult);
		var mult:Float = FlxMath.lerp(1, playfield.iconP2.scale.x, Math.exp(-elapsed * 14));
		playfield.iconP2.scale.set(mult, mult);

		playfield.iconP2.origin.y = playfield.iconP2.height / 2;
		playfield.iconP1.origin.y = playfield.iconP1.height / 2;

		if (!startedSong)
		{
			if (startedCountdown)
			{
				Conductor.instance.time += FlxG.elapsed * 1000;
				if (Conductor.instance.time > -0)
					startSong();
			}
		}
		else
			Conductor.instance.time = tracks.get('main').time;

		for (_ in tracks)
			if (_ != tracks.get('main') && Math.abs(_.time - tracks.get('main').time) > 40)
				_.time = tracks.get('main').time;

		if (FlxG.keys.justPressed.C)
		{
			var fileRef:FileDialog = new FileDialog();
			fileRef.onOpen.add(function(yes)
			{
				var psych:FNFPsych = new FNFPsych().fromJson(yes);
				var dial:FileReference = new FileReference();
				dial.save(Bytes.ofString(Json.stringify(Song.fromPsychLegacy(psych))), 'default.json');
			});
			fileRef.open('json', null, "Legacy convert/ 0.7.3 psych");
		}

		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 5));
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 5));

		if (song.events[lastEventIndex] != null && song.events[lastEventIndex].time <= Conductor.instance.time)
		{
			triggerEvent(song.events[lastEventIndex]);
			lastEventIndex++;
		}

		super.update(elapsed);
	}

	public var defaultZoom:Float = 1;

	function startSong()
	{
		startedSong = true;

		trace(tracks);
		for (_ in tracks)
			_.play();
	}

	public dynamic function startCallback():Void
		startCountdown();

	public function triggerEvent(event:backend.Song.Event)
	{
		if (event == null)
			return;

		switch (event.name)
		{
			case "Camera Focus":
				moveCamera(event.values[0]);
		}
	}

	public function moveCamera(target:String = "dad")
	{
		switch (target.toLowerCase())
		{
			case 'dad' | 'opponent':
				if (dad == null)
					return;
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.camera_position[0] + opponentCameraOffset[0];
				camFollow.y += dad.camera_position[1] + opponentCameraOffset[1];
			case 'gf' | 'girlfriend':
				if (dad == null)
					return;
				camFollow.setPosition(gf.getMidpoint().x + 150, gf.getMidpoint().y - 100);
				camFollow.x += gf.camera_position[0] + girlfriendCameraOffset[0];
				camFollow.y += gf.camera_position[1] + girlfriendCameraOffset[1];
			case 'bf' | 'boyfriend':
				if (bf == null)
					return;

				camFollow.setPosition(bf.getMidpoint().x - 100, bf.getMidpoint().y - 100);
				camFollow.x -= bf.camera_position[0] - boyfriendCameraOffset[0];
				camFollow.y += bf.camera_position[1] + boyfriendCameraOffset[1];
		}
	}

	public var defaultCamZoom:Null<Float> = 1;

	public function startCountdown()
	{
		startedCountdown = true;
		tracks.set('main', FlxG.sound.load(Assets.getAssetPath(song.tracks.main)));
		for (track_ in song.tracks.extra)
		{
			if (!Assets.exists(Assets.getAssetPath(track_)))
				continue;
			tracks.set(track_, FlxG.sound.load(Assets.getAssetPath(track_)));
		}
	}

	public function beatHit(curBeat:Float)
	{
		if (gf != null
			&& Math.floor(curBeat) % Math.round(1 * gf.danceEveryNumBeats) == 0
			&& !gf.getAnimationName().startsWith('sing')
			&& !gf.stunned)
			gf.dance();
		playfield.iconP1.scale.set(1.2, 1.2);
		playfield.iconP2.scale.set(1.2, 1.2);
		forEachStage((_) ->
		{
			_.curBeat = curBeat;
			_.beatHit();
		});
	}

	public function measureHit(curSection:Float)
	{
		camHUD.zoom += hudCameraZoomIntensity;
		FlxG.camera.zoom += 0.015;
		forEachStage((_) ->
		{
			_.curSection = curSection;
			_.sectionHit();
		});
	}

	public function stepHit(curStep:Float)
	{
		forEachStage((_) ->
		{
			_.curStep = curStep;
			_.stepHit();
		});
	}
}

@:publicFields
class StageUtil
{
	static function vanillaGF(s:String):String
	{
		trace(s);
		switch (s)
		{
			case "school":
				return "gf-pixel";
			case "schoolEvil":
				return "gf-pixel";
			case 'mall':
				return 'gf-christmas';
			case 'mallEvil':
				return 'gf-christmas';
			case 'spooky':
				return 'gf';
			case 'philly':
				return 'gf';
			case 'limo':
				return 'gf-car';
			case 'tank':
				return 'gf-tankman';
			default:
				return 'gf';
		}
		return 'gf';
	}

	public static function vanillaSongStage(songName):String
	{
		var songName = StringTools.replace(Std.string(songName), ' ', '-').toLowerCase();

		switch (songName)
		{
			case 'spookeez' | 'south' | 'monster':
				return 'Spooky';
			case 'pico' | 'blammed' | 'philly' | 'philly-nice':
				return 'Philly';
			case 'milf' | 'satin-panties' | 'high':
				return 'Limo';
			case 'cocoa' | 'eggnog':
				return 'Mall';
			case 'winter-horrorland':
				return 'MallEvil';
			case 'senpai' | 'roses':
				return 'School';
			case 'thorns':
				return 'SchoolEvil';
			case 'ugh' | 'guns' | 'stress':
				return 'Tank';
			default:
				return 'Stage';
		}
		return 'Stage';
	}
}

typedef StageFile =
{
	public var bfOffsets:Null<Array<Float>>;
	public var gfOffsets:Null<Array<Float>>;
	public var dadOffsets:Array<Float>;

	public var cam_dad:Null<Array<Float>>;
	public var cam_bf:Null<Array<Float>>;
	public var cam_gf:Null<Array<Float>>;

	public var camSPEED:Null<Float>;

	public var defaultCamZoom:Null<Float>;
}
