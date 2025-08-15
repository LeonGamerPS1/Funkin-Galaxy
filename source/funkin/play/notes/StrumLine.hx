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

	public var unspawnNotes:Array<Note> = [];
	public var cpu = true;
	public var downScroll:Bool = false;
	public var sk = null;
	public var size:Float = 1;

	public function new(x:Float = 0, y:Float = 0, downScroll:Bool = false, skin:String = "default", sc:Float = 1)
	{
		super(x, y);
		this.size = sc;

		this.sk = skin;
		this.downScroll = downScroll;

		strums = new FlxTypedSpriteGroup<Strum>();
		add(strums);

		notes = new FlxTypedSpriteGroup<Note>();
		add(notes);

		for (dirs in 0...2)
		{
			var note:Note = new Note();
			note.strumLine = this;
			note.ignoreNote = true;
			note.setup({
				data: dirs % 4,
				time: -100000,
				strumLine: 0,
				length: 0,
				type: "",
			}, skin);
			notes.add(note);
			for (i in 0...2)
			{
				var sustain:Note = new Note();
				sustain.strumLine = this;
				sustain.parent = note;
				sustain.ignoreNote = true;
				sustain.prevNote = notes.members[notes.length - 1];
				sustain.setup({
					data: 2,
					time: -100000,
					strumLine: 0,
					length: 0,
					type: "",
				}, skin, true);
				notes.add(sustain);
			}
		}

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
			var time:Float = 1500;
			if (songSpeed < 1)
				time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].noteData.time - Conductor.instance.time < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				dunceNote.setPosition(-6666, 6666); // prevent it from showing up at (0,0) for one frame then disappearing

				unspawnNotes.remove(unspawnNotes[0]);
			}
		}
		notes.sort(sortNotesByTimeHelper, FlxSort.DESCENDING);
		super.update(elapsed);

		if (!cpu)
			keyPregnancy();

		notes.forEachAlive(function(note:Note)
		{
			var strum = strums.members[note.noteData.data % strums.length];

			note.followStrumNote(strum, songSpeed);

			if (cpu
				&& (note.noteData.time <= Conductor.instance.time || note.isHold && note.prevNote.wasGoodHit && note.canBeHit)
				&& !note.ignoreNote
				&& !note.wasGoodHit)
			{
				strum.playAnim('confirm', true);

				if (character != null)
					character.sing(note, true);

				strum.r = 0.15;
				hitSignal(note);

				note.wasGoodHit = true;
				if (!note.isHold)
					invalNote(note);
			}

			if (note.noteData.time < Conductor.instance.time - (350))
			{
				if (!cpu && !note.wasGoodHit && !note.ignoreNote)
					miss(note.noteData.data);

				invalNote(note);
			}
		});
	}

	function invalNote(note:Note)
	{
		note.kill();
		notes.remove(note, true);
		note.destroy();
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
				if (strum.cover.animation.name != 'end')
					strum.cover.active = false;
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
				if (!shittNo.ignoreNote && keyPress[shittNo.noteData.data] && shittNo.canBeHit)
					playerHit(shittNo);
				if (!shittNo.ignoreNote
					&& keyHold[shittNo.noteData.data]
					&& (shittNo.canBeHit || shittNo.prevNote.wasGoodHit && shittNo.canBeHit)
					&& shittNo.isHold)
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
		if (shittNo.ignoreNote || shittNo.wasGoodHit)
			return;
		var strum = strums.members[shittNo.noteData.data % strums.length];

		strum.playAnim('confirm', true);
		if (character != null)
			character.sing(shittNo, true);

		strum.cover.active = true;
			strum.cover.animation.play('start');

		hitSignal(shittNo);

		shittNo.wasGoodHit = true;
		if (!shittNo.isHold)
			invalNote(shittNo);
	}

	public function beatHit(beat:Float)
	{
		if (character != null && (cpu || !cpu && !keyHold.contains(true)))
			character.dance(beat);
	}
}
