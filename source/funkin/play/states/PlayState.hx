package funkin.play.states;

import funkin.scripted.ScriptedStage;
import openfl.display.Bitmap;
import openfl.system.System;

class PlayState extends FlxUIState implements IStageState
{
	public static var self(default, null):PlayState;
	public static var daPixelZoom(default, null):Float = 6;

	public var plrStrums:StrumLine;
	public var dadStrums:StrumLine;
	public var gfStrums:StrumLine;
	public var strumLines:Array<StrumLine> = [];

	public static var song:SongMap;

	public var camHUD:FlxCamera;
	public var camOther:FlxCamera;
	public var ui:FlxGroup;

	public var startedCountdown:Bool = false;
	public var startedSong:Bool = false;
	public var songSpeed(default, set):Float = 1;
	public var downScroll:Bool = false;
	public var healthBar:FlxBar;
	public var healthBarBG:FlxSprite;
	public var health:Float = 1;
	public var scoreText:FlxText;

	public var score:Int = 0;
	public var misses:Int = 0;
	public var accuracy:Null<Float>;

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var jsStage:SceneData;
	public var defaultZoom:Float = 1.000;
	public var curStage:String = '?';
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var paused:Bool = false;
	public var playbackRate(default, set):Float = 1;

	public function stageLoad()
	{
		self = this;
		var path = Paths.getAssetPath('stages/${song.stage}.json');
		if (!Paths.exists(path))
			path = Paths.getAssetPath('stages/stage.json');

		jsStage = Json.parse(Paths.getText(path));
		BF_X = jsStage.bf.x;

		BF_Y = jsStage.bf.y;

		DAD_X = jsStage.dad.x;
		DAD_Y = jsStage.dad.y;

		GF_X = jsStage.gf.x;
		GF_Y = jsStage.gf.y;
		defaultZoom = jsStage.zoom;
		FlxG.camera.zoom = defaultZoom;
		curStage = path.replace('assets/stages/', '').replace('.json', '');
		trace(curStage);
		boyfriendCameraOffset = jsStage.bfCam;
		opponentCameraOffset = jsStage.dadCam;
		girlfriendCameraOffset = jsStage.gfCam;

		for (stage in ScriptedStage.listScriptClasses())
		{
			if (stage.toLowerCase() == curStage.toLowerCase())
			{
				var stage = ScriptedStage.init(stage, this, false);
				stage.create();
				addStage(stage);
				return;
			}
		}

		switch (curStage)
		{
			case 'stage':
				addStage(new Week1(this, true));
			case 'spooky':
				addStage(new Week2(this, true));

			case 'school':
				addStage(new Week6(this, true));
			case 'schoolErect':
				addStage(new Week6Erect(this, true));
			case 'schoolEvil':
				addStage(new Week6Evil(this, true));
		}
	}

	override public function create()
	{
		FlxG.sound.music.fadeOut(0.4, 0);
		super.create();

		song ??= Song.grabSong();
		Conductor.instance.reset(true);
		Conductor.instance.changeBpmAt(0, song.bpm, 4, 4);
		Conductor.instance.time = -Conductor.instance.crochet * 5;
		Conductor.instance.onBeat.add(beat);
		Conductor.instance.onStep.add(step);
		Conductor.instance.onMeasure.add(section);

		var skin = 'default';
		if (song.skin != null && song.skin.length > 0)
			skin = song.skin;

		camHUD = new FlxCamera();
		camHUD.zoom = 1;
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		camOther = new FlxCamera();
		camOther.zoom = 1;
		camOther.bgColor.alpha = 0;
		FlxG.cameras.add(camOther, false);

		stageLoad();
		initchar();

		ui = new FlxGroup();
		ui.cameras = [camHUD];
		add(ui);

		#if android downScroll = true; #end

		dadStrums = new StrumLine(50, !downScroll ? 50 : FlxG.height - 150, downScroll, skin, #if (android) 0.5 #end);
		strumLines.push(dadStrums);
		ui.add(dadStrums);

		plrStrums = new StrumLine(FlxG.width / 2 + 50, dadStrums.y, downScroll, skin);
		strumLines.push(plrStrums);
		plrStrums.cpu = false;
		ui.add(plrStrums);

		gfStrums = new StrumLine((160 * 0.7 / 2) + 5044, !downScroll ? 50 : FlxG.height - 150, downScroll, skin);
		strumLines.push(gfStrums);
		gfStrums.visible = false;
		ui.add(gfStrums);

		#if (android)
		dadStrums.notes.visible = false;
		dadStrums.sustains.visible = false;
		dadStrums.covers.visible = false;

		dadStrums.x = 50;
		dadStrums.y = 100;

		for (i in plrStrums.strums)
		{
			if (i.data == 0)
				i.x -= i.width * 0.7;
			if (i.data == 3)
				i.x += i.width * 0.7;
			i.tapBox.width = (160) * 1.25;
			if (i.data < Math.floor(plrStrums.members.length / 2))
				continue;
			i.x += (160 * 0.5) * 2;
		}
		plrStrums.screenCenter(X);
		plrStrums.x += (160 * 0.5);
		#end

		healthBarBG = new FlxSprite(0, !downScroll ? FlxG.height * 0.89 : 100, Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		ui.add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x, healthBarBG.y, RIGHT_TO_LEFT, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this, 'health', 0, 2);
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		ui.insert(ui.members.indexOf(healthBarBG), healthBar);

		iconP2 = new HealthIcon(dad.json.icon);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.x = healthBar.x + healthBar.width / 2 - iconP2.frameWidth - 10;
		ui.add(iconP2);

		iconP1 = new HealthIcon(bf.json.icon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.x = healthBar.x + healthBar.width / 2 + 10;
		ui.add(iconP1);

		scoreText = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, '', 20);
		scoreText.setFormat(Paths.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.scrollFactor.set();

		ui.add(scoreText);

		songSpeed = song.speed;

		for (iss in strumLines)
		{
			iss.missSignal = miss;
			iss.hitSignal = hit;
			Conductor.instance.onBeat.add(iss.beatHit);
		}
		plrStrums.character = bf;
		dadStrums.character = dad;
		gfStrums.character = gf;

		forEachStage((_) ->
		{
			_.createPost();
		});
		genC();

		startCallback();
	}

	public var bf:BaseCharacter;
	public var dad:BaseCharacter;
	public var gf:BaseCharacter;

	public var eventNotes:Array<Event> = [];

	public function checkEventNote()
	{
		while (eventNotes.length > 0)
		{
			var leStrumTime:Float = eventNotes[0].time;
			if (Conductor.instance.time < leStrumTime)
				return;

			triggerEvent(eventNotes[0]);
			eventNotes.shift();
		}
	}

	function initchar()
	{
		gf = BaseCharacter.makeCharacter(song.players[1], true);
		gf.setPosition(GF_X, GF_Y);
		gf.scrollFactor.set(0.95, 0.95);
		add(gf);

		dad = BaseCharacter.makeCharacter(song.players[0], false);
		dad.setPosition(DAD_X, DAD_Y);
		add(dad);

		bf = BaseCharacter.makeCharacter(song.players[2], true);
		bf.setPosition(BF_X, BF_Y);
		add(bf);

		if (gf.curCharacter == dad.curCharacter)
		{
			dad.setPosition(gf.x, gf.y);
			dad.flipX = false;
			dad.json = gf.json;
			gf.kill();
		}

		camFollow = new FlxObject(bf.x, bf.y);

		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 0.06);
		for (so in [dad, gf, bf])
		{
			so.x += so.json.positionOffset.x;
			so.y += so.json.positionOffset.y;
		}
		cam('dad');
		FlxG.camera.snapToTarget();
	}

	public function cam(target:String = 'dad')
	{
		switch (target.toLowerCase())
		{
			case 'dad' | 'opponent':
				if (dad == null)
					return;
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.json.cameraOffset.x + opponentCameraOffset[0];
				camFollow.y += dad.json.cameraOffset.y + opponentCameraOffset[1];
			case 'gf' | 'girlfriend':
				if (dad == null)
					return;
				camFollow.setPosition(gf.getMidpoint().x + 150, gf.getMidpoint().y - 100);
				camFollow.x += gf.json.cameraOffset.x + girlfriendCameraOffset[0];
				camFollow.y += gf.json.cameraOffset.y + girlfriendCameraOffset[1];
			case 'bf' | 'boyfriend':
				if (bf == null)
					return;

				camFollow.setPosition(bf.getMidpoint().x - 100, bf.getMidpoint().y - 100);
				camFollow.x -= bf.json.cameraOffset.x - boyfriendCameraOffset[0];
				camFollow.y += bf.json.cameraOffset.y + boyfriendCameraOffset[1];
		}
	}

	public var boyfriendCameraOffset:Array<Float> = [0, 0];
	public var opponentCameraOffset:Array<Float> = [0, 0];
	public var girlfriendCameraOffset:Array<Float> = [0, 0];

	public var camFollow:FlxObject;

	public static var songs:Array<String> = [];
	public static var story = false;
	public static var diff = 'normal';

	public function endSong()
	{
		if (story)
		{
			if (songs.length > 0)
			{
				songs.remove(song.songName);
				song = Song.grabSong(songs[0], diff);
				FlxG.resetState();
			}
			else
				FlxG.switchState(new MainMenu());
		}
		else
			FlxG.switchState(new Freeplay());
	}

	function triggerEvent(event:Event)
	{
		if (event.name == 'Camera Focus')
		{
			cam(event.values[0]);
		}
		if (event.name == 'Change Scroll Speed')
		{
			FlxTween.cancelTweensOf(this);
			FlxTween.tween(this, {songSpeed: event.values[0]}, event.values[1], {ease: FlxEase.sineInOut});
		}

		if (event.name == 'Change BPM')
			Conductor.instance.changeBpmAt(Conductor.instance.time, event.values[0], event.values[1], event.values[2]);
		if (event.name == 'Camera Zoom')
		{
			var fp1:Float = event.values[0] is String ? Std.parseFloat(event.values[0]) : event.values[0]; // event values are fucking strings sobbbbbb if you use legacy format like psych 0.7.3
			if (Math.isNaN(fp1))
				fp1 = 1; // jsStage.zoom;

			defaultZoom = fp1;
		}

		if (event.name == 'Add Camera Zoom')
		{
			var fp1:Float = event.values[0] is String ? Std.parseFloat(event.values[0]) : event.values[0]; // event values are fucking strings sobbbbbb if you use legacy format like psych 0.7.3
			if (Math.isNaN(fp1) || fp1 == 0)
				fp1 = 0.015;

			FlxG.camera.zoom += fp1;

			var fp2:Float = event.values[1] is String ? Std.parseFloat(event.values[1]) : event.values[1]; // event values are fucking strings sobbbbbb if you use legacy format like psych 0.7.3
			if (Math.isNaN(fp2) || fp2 == 0)
				fp2 = 0.03;

			camHUD.zoom += fp2;
		}

		if (event.name == 'Play Animation')
		{
			var char:BaseCharacter = dad;
			switch (event.values[1])
			{
				case 'dad' | 'Dad' | 'DAD' | 'opponent' | 'Opponent' | 'OPPONENT':
					char = dad;
				case 'bf' | 'Bf' | 'BF' | 'boyfriend' | 'Boyfriend' | 'BOYFRIEND':
					char = bf;
				case 'gf' | 'GF' | 'girlfriend' | 'Girlfriend' | 'GIRLFRIEND' | 'spectator' | 'Spectator':
					char = gf;
			}
			char.playAnim(event.values[0], true);
			char.holdTimer = char.animation.numFrames / char.animation.curAnim.frameRate;
		}
	}

	public function miss(id:Int = 0)
	{
		misses++;
		score -= 150;
		health -= 0.05;
		bf.playAnim('singLEFT', true);
	}

	public function hit(note:Note)
	{
		if (note.strumLine != null && !note.strumLine.cpu && !note.wasGoodHit)
		{
			score += 150;
			health += 0.04;
		}
	}

	function genC()
	{
		for (_ in song.events)
			eventNotes.push(_);
		for (noteData in song.notes)
		{
			var line = strumLines[noteData.strumLine];
			line.unspawnNotes.push(noteData);
		}
		for (_ in strumLines)
		{
			_.unspawnNotes.sort((d_, d_2) ->
			{
				return Math.floor(d_.time - d_2.time);
			});
		}
	}

	public var tracks:Map<String, FlxSound> = [];

	public dynamic function startCallback():Void
		startCountdown();

	public var screenshotSPR:Bitmap;
	public var g = false;

	override public function update(elapsed:Float)
	{
		#if (desktop)
		if (Controls.instance.justPressed.CHART)
		{
			FlxG.switchState(() -> new NoteEditor());
			return;
		}
		#end
		health = FlxMath.bound(health, 0, 2);
		var scoreString:String = !plrStrums.cpu ? 'Score: $score' : 'Bot Play Enabled';
		scoreText.text = scoreString;
		// scoreText.screenCenter(X);
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 5));
		FlxG.camera.zoom = FlxMath.lerp(defaultZoom, FlxG.camera.zoom, Math.exp(-elapsed * 5));

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

		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0; // If health is under 20%, change player icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0; // If health is over 80%, change opponent icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		checkEventNote();
		for (_ in tracks)
			if (_ != tracks.get('main') && Math.abs(_.time - tracks.get('main').time) > 40 && tracks.get('main').playing)
				_.time = tracks.get('main').time;
		super.update(elapsed);
		var wid:Float = FlxMath.lerp(1, iconP1.scale.x, 0.825);
		iconP1.scale.set(wid, wid);
		iconP1.updateHitbox();

		var wid:Float = FlxMath.lerp(1, iconP2.scale.x, 0.825);
		iconP2.scale.set(wid, wid);
		iconP2.updateHitbox();

		var barCenter:Float = get_center();
		var iconOffset:Int = 26;
		iconP1.x = barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		forEachStage((_) ->
		{
			_.updatePost(elapsed);
		});

		if (Controls.instance.justPressed.UI_ACCEPT)
		{
			paused = true;
			for (poop in tracks)
				if (poop.playing)
					poop.pause();
			openSubState(new PauseMenu(camOther));
		}
	}

	override function closeSubState()
	{
		super.closeSubState();
		for (poop in tracks)
			if (poop.time > -1 && !poop.playing)
				poop.resume();
		subState = null;
		System.gc();
	}

	override function destroy()
	{
		self = null;
		super.destroy();
	}

	function startSong()
	{
		startedSong = true;

		trace(tracks);
		for (_ in tracks)
			_.play();
	}

	public function startCountdown()
	{
		startedCountdown = true;
		tracks.set('main', FlxG.sound.load(Paths.getAssetPath(song.tracks.main)));
		tracks.get('main').onComplete = endSong;
		for (track_ in song.tracks.extra)
		{
			if (!Paths.exists(Paths.getAssetPath(track_)))
				continue;
			tracks.set(track_, FlxG.sound.load(Paths.getAssetPath(track_)));
		}
	}

	function set_songSpeed(value:Float):Float
	{
		for (i in strumLines)
			i.songSpeed = value;
		return songSpeed = value;
	}

	public function step(val:Float)
	{
		forEachStage((_) ->
		{
			_.curStep = val;
			_.stepHit();
		});
	}

	public function beat(val:Float)
	{
		iconP1.scale.set(1.2, 1.2);
		iconP1.updateHitbox();

		iconP2.scale.set(1.2, 1.2);
		iconP2.updateHitbox();

		forEachStage((_) ->
		{
			_.curBeat = val;
			_.beatHit();
		});
	}

	public function section(val:Float)
	{
		FlxG.camera.zoom += 0.02;
		camHUD.zoom += 0.04;

		forEachStage((_) ->
		{
			_.curSection = val;
			_.sectionHit();
		});
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

	function get_center():Float
	{
		return (healthBar != null ? healthBar.x - (healthBar.width * (healthBar.percent / 100)) + healthBar.width : 0);
	}

	public function reboot() // empty
	{
		return null;
	}

	function set_playbackRate(value:Float):Float
	{
		for (i in tracks)
			i.pitch = value;
		Conductor.rate = value;
		FlxG.timeScale = value;
		return playbackRate = value;
	}
}
