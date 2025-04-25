package states;

import backend.Song.NoteData;
import backend.Song.SongMap;
import backend.controls.Controls;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.ui.FlxUIState;
import flixel.util.FlxColorTransformUtil;
import object.play.Character.CharacterData;

class ChartingState extends FlxUIState
{
	public static inline var GRID_SIZE:Int = 40;

	public var gridBG:FlxSprite;

	public var strumLineone:Strumline;
	public var strumLinetwo:Strumline;

	public static var _song:SongMap;

	public var line:FlxSprite;
	public var inst:FlxSound;
	public var paused:Bool = true;
	public var destroyOnReload:FlxGroup = new FlxGroup();

	public override function create():Void
	{
		Conductor.instance.time = 0;
		if (_song == null)
			_song = Song.grabSong('Test', 'hard');

		var skin = 'default';

		var enemySkin = _song.skinEnemy ?? skin;
		var playerSkin = _song.skinPlayer ?? skin;

		inst = FlxG.sound.load('assets/${_song.tracks.main}');

		var bg:FlxSprite = new FlxSprite().loadGraphic(Assets.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = FlxColor.GRAY;
		add(bg);

		gridBG = new FlxTiledSprite(FlxGridOverlay.createGrid(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, Math.floor(GRID_SIZE * 16), true, 0xFF616060, 0xFF252525),
			GRID_SIZE * 8, GRID_SIZE * 16);
		gridBG.graphic.bitmap.disposeImage();
		gridBG.screenCenter(X);
		gridBG.scrollFactor.x = 0;
		add(gridBG);

		iconP1 = new HealthIcon('bf', true);
		iconP2 = new HealthIcon('dad');

		add(iconP2);
		add(iconP1);

		iconP2.x = gridBG.x - iconP1.frameWidth * 0.3571 * (GRID_SIZE / 40) - 10;
		iconP1.x = gridBG.x + gridBG.width + 10;

		iconP1.y += FlxG.height / 2;
		iconP2.y += FlxG.height / 2;

		add(destroyOnReload); // for beat lines :3

		dummybox = new FlxSprite();
		dummybox.makeGraphic(GRID_SIZE, GRID_SIZE);
		dummybox.graphic.bitmap.disposeImage();
		dummybox.offset.x -= 0.5;
		add(dummybox);

		seperator = new FlxTiledSprite(null, Std.int(GRID_SIZE / 8), Std.int(gridBG.height));
		seperator.makeGraphic(Std.int(GRID_SIZE / 8), Std.int(gridBG.height), 0xFF000000);
		seperator.screenCenter(X);
		seperator.scrollFactor.x = 0;
		seperator.y = gridBG.y;
		seperator.graphic.bitmap.disposeImage();
		add(seperator);

		regenGridVisuals();

		line = new FlxSprite(gridBG.x, gridBG.y);
		line.scrollFactor.x = 0;
		line.makeGraphic(Std.int(gridBG.width), Std.int(GRID_SIZE / 8));
		line.graphic.bitmap.disposeImage();
		add(line);

		add(renderedSustains);
		add(renderedNotes);

		strumLineone = new Strumline(line.x, line.y, enemySkin, 0.3571 * (GRID_SIZE / 40));
		strumLineone.strums.scrollFactor.x = 0;
		add(strumLineone);

		strumLinetwo = new Strumline(line.x + GRID_SIZE * 4, line.y, playerSkin, 0.3571 * (GRID_SIZE / 40));
		strumLinetwo.strums.scrollFactor.x = 0;
		add(strumLinetwo);

		for (ii in [strumLineone, strumLinetwo])
			ii.cpu = true;

		Conductor.instance.reset(true);
		Conductor.instance.onBeat.add(beat);
		Conductor.instance.changeBpmAt(0, _song.bpm);

		for (track_ in _song.tracks.extra)
		{
			if (!Assets.exists(Assets.getAssetPath(track_)))
				continue;
			tracks.set(track_, FlxG.sound.load(Assets.getAssetPath(track_)));
		}

		openfl.system.System.gc();

		regenGrid();
		updateIcons();
		FlxG.camera.follow(camFollow);

		super.create();
	}

	function beat(beatFuckVariableForLife:Float)
	{
		iconP1.scale.set(0.7, 0.7);
		iconP2.scale.set(0.7, 0.7);
		iconP1.updateHitbox();
		iconP2.updateHitbox();
	}

	public function updateIcons()
	{
		var charDad:CharacterData = Json.parse(!Assets.exists('assets/characters/${_song.players[0]}.json') ? Assets.getText('assets/characters/dad.json') : Assets.getText('assets/characters/${_song.players[0]}.json'));
		var charBf:CharacterData = Json.parse(!Assets.exists('assets/characters/${_song.players[2]}.json') ? Assets.getText('assets/characters/bf.json') : Assets.getText('assets/characters/${_song.players[2]}.json'));

		iconP1.changeIcon(charBf.health_icon);
		iconP2.changeIcon(charDad.health_icon);
	}

	public var renderedNotes:FlxTypedGroup<Note> = new FlxTypedGroup();
	public var renderedSustains:FlxTypedGroup<Sustain> = new FlxTypedGroup();

	var seperator:FlxTiledSprite;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public function regenGridVisuals():Void
	{
		var sectionCount:Float = inst.length / Conductor.instance.measureCrochet;

		seperator.height = GRID_SIZE * 16 * sectionCount;
		gridBG.height = GRID_SIZE * 16 * sectionCount;
		for (i in destroyOnReload)
			destroyOnReload.remove(i);

		for (i in 0...Math.floor(sectionCount * 4))
		{
			var isSectionHit:Bool = i % 4 == 0;
			var line = new FlxSprite(gridBG.x, getYfromStrum(Conductor.instance.crochet * i));
			line.scrollFactor.x = 0;
			line.makeGraphic(Std.int(gridBG.width), Std.int(GRID_SIZE / 8), !isSectionHit ? FlxColor.BLACK : 0xFFFFFFFF);
			line.graphic.bitmap.disposeImage();
			destroyOnReload.add(line);
		}
	}

	function regenGrid():Void
	{
		while (renderedNotes.length > 0)
			for (i in renderedNotes)
				renderedNotes.remove(i, true);

		while (renderedSustains.length > 0)
			for (i in renderedSustains)
				renderedSustains.remove(i, true);

		for (note in _song.notes)
		{
			var strumline = note.strumLine < 1 ? strumLineone : strumLinetwo;
			var noteObject:Note = new Note(note, strumline, strumline.strums.members[note.data].skin.name);
			noteObject.x = (GRID_SIZE * note.data) + (GRID_SIZE * 4 * note.strumLine) + gridBG.x;
			noteObject.y = getYfromStrum(note.time);
			renderedNotes.add(noteObject);
			noteObject.inEditor = true;
			noteObject.speed = 1;

			if (note.length > 0)
			{
				var sustain:Sustain = new Sustain(noteObject);
				noteObject.sustain = sustain;
				renderedSustains.add(sustain);
				sustain.scrollFactor.set(0, 1);
			}
		}
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + (GRID_SIZE * 16), 0, 16 * Conductor.instance.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.instance.stepCrochet, gridBG.y, gridBG.y + (GRID_SIZE * 16));
	}

	var first = true;
	var section = 0;
	var camFollow:FlxObject = new FlxObject(0, 0, 1, 1);

	public var tracks:Map<String, FlxSound> = [];
	public var dummybox:FlxSprite;
	

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.overlaps(gridBG))
		{
			dummybox.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummybox.y = FlxG.mouse.y;
			else
				dummybox.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;

			if (FlxG.mouse.justPressed)
			{
				if (FlxG.mouse.overlaps(renderedNotes))
				{
					for (note in renderedNotes.members.filter((_) -> return _.isOnScreen()))
					{
						if (FlxG.mouse.overlaps(note))
						{
							if (!FlxG.keys.pressed.CONTROL)
								removeNote(note.noteData);
							else
								selectNote(note.noteData);
						}
					}
				}
				else
				{
					addNote();
				}
			}
		}

		for (_ in tracks)
			if (Math.abs(_.time - inst.time) > 40)
				_.time = inst.time;

		for (note in renderedNotes)
		{
			if (note.noteData == __selected)
			{
				FlxColorTransformUtil.setMultipliers(note.colorTransform, 1.5, 1.5, 1.5, note.alpha);
			}
			else
				FlxColorTransformUtil.setMultipliers(note.colorTransform, 1, 1, 1, note.alpha);

			if (note.noteData.time <= Conductor.instance.time && note.alpha > 0.999)
			{
				note.alpha = 0.999;
				if (!paused)
				{
					note.strumline.strums.members[note.noteData.data].playAnim('confirm', true);
					note.strumline.strums.members[note.noteData.data].resetAnim = FlxMath.bound(note.noteData.length / 1000,
						Conductor.instance.stepCrochet * 1.5 / 1000);
				}
			}
			else if (!(note.noteData.time <= Conductor.instance.time))
			{
				note.alpha = 1;
			}
		}
		if (Controls.instance.pressed.UI_UP && paused)
			inst.time -= elapsed * Conductor.instance.crochet * 3;

		if (Controls.instance.pressed.UI_DOWN && paused)
			inst.time += elapsed * Conductor.instance.crochet * 3;

		Conductor.instance.time = inst.time;

		if (FlxG.keys.justPressed.E)
			adjustSustain(Conductor.instance.stepCrochet);

		if (FlxG.keys.justPressed.Q)
			adjustSustain(-Conductor.instance.stepCrochet);

		if (FlxG.keys.justPressed.SPACE) // shitty pausing logic but it works
		{
			paused = !paused;

			if (!paused && first)
			{
				first = false;
				inst.play();
				inst.time = Conductor.instance.time;
				for (_ in tracks)
					_.play();
			}
			else
			{
				if (paused)
				{
					inst.pause();
					for (_ in tracks)
						_.pause();
				}
				else
				{
					inst.resume();
					for (_ in tracks)
						_.resume();
				}
			}
		}

		line.y = getYfromStrum(inst.time);
		strumLineone.strums.y = line.y;
		strumLinetwo.strums.y = line.y;
		camFollow.y = line.y;

		var mult:Float = FlxMath.lerp(0.5, iconP1.scale.x, Math.exp(-elapsed * 55));

		iconP1.scale.set(mult, mult);
		iconP2.scale.set(mult, mult);
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		iconP2.centerOffsets();
		iconP1.centerOffsets();

		iconP2.centerOrigin();
		iconP1.centerOrigin();

		if ((inst.time == 0) && !first && !paused)
		{
			inst.play();
			for (_ in tracks)
				_.play();
		}

		if (Controls.instance.justPressed.UI_ACCEPT)
		{
			PlayState.song = _song;
			FlxG.switchState(new PlayState());
		}
	}

	public var __selected:NoteData = null;

	public function adjustSustain(msAdjust:Float = 0)
	{
		if (__selected != null)
		{
			__selected.length += msAdjust;
			if (__selected.length > 0)
				regenGrid();
		}
	}

	public function selectNote(arg:NoteData)
	{
		__selected = arg;
		trace('note selected: ' + arg);
	}

	function removeNote(arg:NoteData)
	{
		_song.notes.remove(arg);
		regenGrid();
	}

	function addNote()
	{
		var time:Float = getStrumTime(dummybox.y);
		var rawDirection = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE) + 5;
		var direction = rawDirection % 4;
		var strumLine = Math.floor(rawDirection / 4);
		var type:String = 'normal';

		var noteData:NoteData = {
			time: time,
			data: direction,
			strumLine: strumLine,
			type: type,
			length: 0
		};

		_song.notes.push(noteData);
		selectNote(noteData);
		regenGrid();
	}
}
