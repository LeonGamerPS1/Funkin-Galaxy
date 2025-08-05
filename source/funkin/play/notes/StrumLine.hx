package funkin.play.notes;

import flixel.util.FlxColorTransformUtil;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSort;

using flixel.util.FlxArrayUtil;

class StrumLine extends FlxSpriteGroup
{
	public var songSpeed:Float = 1;

	public var strums:FlxTypedSpriteGroup<Strum>;

	public var notes:FlxTypedSpriteGroup<Note>;
	public var covers:FlxTypedSpriteGroup<SustainCover>;
	public var splashes:FlxTypedSpriteGroup<NoteSplash>;

	public var unspawnNotes:Array<NoteData> = [];
	public var cpu = true;
	public var downScroll:Bool = false;
	public var sk = null;
	public var size:Float = 1;
	public var sustains:FlxTypedSpriteGroup<Sustain>;

	public function new(x:Float = 0, y:Float = 0, downScroll:Bool = false, skin:String = "default", sc:Float = 1)
	{
		super(x, y);
		this.size = sc;

		this.sk = skin;
		this.downScroll = downScroll;

		strums = new FlxTypedSpriteGroup<Strum>();
		add(strums);

		sustains = new FlxTypedSpriteGroup<Sustain>();
		add(sustains);

		notes = new FlxTypedSpriteGroup<Note>();
		add(notes);

		covers = new FlxTypedSpriteGroup<SustainCover>();
		add(covers);

		splashes = new FlxTypedSpriteGroup<NoteSplash>();
		add(splashes);
		for (i in 0...4)
			spawnSplash(i);

		generate();
	}

	public function spawnSplash(id:Int = 0)
	{
		var strum:Strum = strums.members[id];
		if (strum == null)
			return; // cancel splash function if said strum is null
		var noteSplash:NoteSplash = splashes.recycle(NoteSplash).play(id);
		noteSplash.setPosition(strum.x, strum.y);
		noteSplash.revive();
	}

	function generate()
	{
		for (i in strums)
		{
			i.destroy();
			strums.remove(i, true);
			i = null;
		}

		for (i in covers)
		{
			i.destroy();
			covers.remove(i, true);
			i = null;
		}

		for (i in 0...4)
		{
			var strum:Strum = new Strum(i, sk, this);
			strum.downScroll = downScroll;

			strums.add(strum);
			strum.x = strum.x + (160 * 0.7) * i * size;
			strum.y = strums.y;
			strum.strumLine = this;
			covers.add(strum.cover);
			strum.cover.scale.set(strum.cover.scale.x * size, strum.cover.scale.y * size);
		}
	}

	public var character:BaseCharacter;

	override function update(elapsed:Float)
	{
		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;
			if (songSpeed < 1)
				time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].time - Conductor.instance.time < time)
			{
				var dunceNote:Note = notes.recycle(Note);
				dunceNote.strumLine = this;
				dunceNote.setup(unspawnNotes[0], strums.members[unspawnNotes[0].data % strums.length].skin);
				dunceNote.setPosition(-6666, 6666); // prevent it from showing up at (0,0) for one frame then disappearing

				if (dunceNote.noteData.length > 2)
				{
					var sustain:Sustain = sustains.recycle(Sustain).init(dunceNote);
				}

				unspawnNotes.remove(unspawnNotes[0]);
				notes.sort(sortNotesByTimeHelper, FlxSort.DESCENDING);
			}
		}

		super.update(elapsed);

		if (!cpu)
			keyPregnancy();

		notes.forEachAlive(function(note:Note)
		{
			var strum = strums.members[note.noteData.data % strums.length];

			note.followStrumNote(strum, songSpeed);

			if (cpu && (note.noteData.time <= Conductor.instance.time) && !note.ignoreNote)
			{
				strum.playAnim('confirm', !note.wasGoodHit);

				// if (!note.wasGoodHit)
				//	spawnSplash(note.noteData.data);
				if (character != null)
					character.sing(note, !note.wasGoodHit);

				strum.r = 0.15;
				hitSignal(note);
				if (note.noteData.length > 0)
				{
					strum.cover.visible = true;
					strum.cover.animation.play('start');
				}

				note.wasGoodHit = true;
			}

			if (note.noteData.time < Conductor.instance.time - (350 / songSpeed) && !note.wasGoodHit)
			{
				if (!cpu && !note.wasGoodHit && !note.ignoreNote)
					miss(note.noteData.data);

				invalNote(note);
			}

			if (note.wasGoodHit && !note.ignoreNote)
			{
				if (note.noteData.length > 0)
					note.setPosition(strum.x, strum.y);
				note.visible = false;

				if (!cpu && !keyHold[note.noteData.data])
					invalNote(note);
				else if (!cpu && keyHold[note.noteData.data])
				{
					playerHit(note);
				}
			}

			if (note.noteData.time + note.noteData.length < Conductor.instance.time && note.wasGoodHit && !note.ignoreNote)
			{
				if (note.noteData.length > 0)
				{

					strum.active = true;
					strum.cover.visible = !cpu;
					if (!cpu)
						strum.cover.animation.play('end', true);
				}
				invalNote(note);
			}
		});
	}

	function invalNote(note:Note)
	{
		if (note.sustain != null)
			note.sustain.kill();

		note.kill();
	}

	public var hitNotes:Array<Note> = [];
	public var directions:Array<Int> = [];

	inline public static function sortNotesByTimeHelper(Order:Int, Obj1:Note, Obj2:Note)
		return FlxSort.byValues(Order, Obj1.noteData.time, Obj2.noteData.time);

	var keyPress:Array<Bool> = [];
	var keyHold:Array<Bool> = [];
	var keyReleased:Array<Bool> = [];

	public function keyPregnancy():Void
	{
		for (i in hitNotes)
			hitNotes.remove(i);
		for (i in directions)
			directions.remove(i);
		
		// fuck this  shitty function name!
		keyPress = [
			Controls.instance.justPressed.NOTE_LEFT,
			Controls.instance.justPressed.NOTE_DOWN,
			Controls.instance.justPressed.NOTE_UP,
			Controls.instance.justPressed.NOTE_RIGHT
		];
		keyHold = [
			Controls.instance.pressed.NOTE_LEFT,
			Controls.instance.pressed.NOTE_DOWN,
			Controls.instance.pressed.NOTE_UP,
			Controls.instance.pressed.NOTE_RIGHT
		];

		keyReleased = [
			Controls.instance.justReleased.NOTE_LEFT,
			Controls.instance.justReleased.NOTE_DOWN,
			Controls.instance.justReleased.NOTE_UP,
			Controls.instance.justReleased.NOTE_RIGHT
		];

		if (keyHold.contains(true) && character != null && character.holdTimer < 0.04)
			character.holdTimer = 0.04;

		strums.forEachAlive(function(strum:Strum)
		{
			#if mobile
			for (touch in FlxG.touches.list)
			{
				if (touch == null)
					continue;
				if (touch.overlaps(strum.tapBox, PlayState.self.camHUD))
				{
					var strumID = strum.data;
					keyReleased[strumID] = touch.justPressed || keyReleased[strumID];
					keyHold[strumID] = touch.pressed || keyHold[strumID];
					keyPress[strumID] = touch.justPressed || keyPress[strumID];
				}
			}
			#end
			if (keyPress[strum.data])
				strum.playAnim('press', true);
			else if (!keyHold[strum.data])
			{
				strum.cover.visible = false;
				strum.playAnim('static', false);
			}
		});

		for (note in notes.members.filter((n:Note) -> return (n.canBeHit && n.alive)))
		{
			hitNotes.push(note);
			directions.push(note.noteData.data);
		}

		if (hitNotes.length > 0)
		{
			for (shit in 0...keyPress.length)
				if (keyPress[shit] && !directions.contains(shit))
					miss(shit);

			for (shittNo in hitNotes)
			{
				if (!shittNo.ignoreNote && keyPress[shittNo.noteData.data])
					playerHit(shittNo);
			}
		}
	}

	public var missSignal = function(id:Int = 0) {};
	public var hitSignal = function(n:Note) {};

	function miss(shit:Int = 0)
	{
		missSignal(shit);
	}

	function playerHit(shittNo:Note)
	{
		var strum = strums.members[shittNo.noteData.data % strums.length];
		strum.playAnim('confirm', !shittNo.wasGoodHit);

		if (character != null)
			character.sing(shittNo, !shittNo.wasGoodHit);

		if (shittNo.noteData.length > 0)
		{
			strum.cover.visible = true;
			strum.cover.animation.play('start');
		}
		hitSignal(shittNo);

		shittNo.wasGoodHit = true;
	}

	public function beatHit(beat:Float)
	{
		if (character != null && (cpu || !cpu && !keyHold.contains(true)))
			character.dance(beat);
		notes.sort(sortNotesByTimeHelper, FlxSort.DESCENDING);
	}
}
