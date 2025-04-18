package;

import backend.Song.SongMap;
import haxe.io.Bytes;
import lime.ui.FileDialog;
import moonchart.formats.fnf.legacy.FNFPsych;
import openfl.net.FileReference;

class PlayState extends FlxState
{
	public var playfield:Playfield;
	public var tracks:Map<String, FlxSound> = [];

	public var startedCountdown:Bool = false;
	public var startedSong:Bool = false;

	public static var song:SongMap;

	public var camHUD:FunkinCamera = new FunkinCamera("hud");

	override public function create()
	{
		if (song == null)
			song = Song.grabSong('Duality');
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

		playfield = new Playfield('default', song, false);
		playfield.cameras = [camHUD];
		add(playfield);

		startCallback();

		super.create();
	}

	override public function update(elapsed:Float)
	{
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
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, Math.exp(-elapsed * 5));

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

	public function startCountdown()
	{
		startedCountdown = true;
		tracks.set('main', FlxG.sound.load(Assets.getPreloadPath(song.tracks.main)));
		for (track_ in song.tracks.extra)
		{
			if (!Assets.exists(Assets.getPreloadPath(track_)))
				continue;
			tracks.set(track_, FlxG.sound.load(Assets.getPreloadPath(track_)));
		}
	}

	public function beatHit(curBeat:Float) {}

	public function measureHit(curBeat:Float)
	{
		camHUD.zoom += 0.05;
		FlxG.camera.zoom += 0.03;
	}

	public function stepHit(curBeat:Float) {}
}
