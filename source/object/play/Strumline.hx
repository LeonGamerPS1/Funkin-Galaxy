package object.play;

import backend.controls.Controls;
import lime.app.Event;

class Strumline extends FlxGroup
{
	public var unspawnNotes:Array<Note> = [];
	public var strums:FlxTypedSpriteGroup<Strum>;
	public var notes:FlxTypedGroup<Note>;
	public var sustains:FlxTypedGroup<Sustain>;

	public var cpu:Bool = false;
	public var character:Character;
	public var scale:Float = 1;

	public function new(x:Float = 0, y:Float = 0, ?skin:String = 'default', scale:Float = 1,)
	{
		super();

		this.scale = scale;
		sustains = new FlxTypedGroup<Sustain>();
		add(sustains);

		strums = new FlxTypedSpriteGroup<Strum>(x, y);
		add(strums);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		hitSignal.add((note) ->
		{
			if (character != null)
				character.singAnimation(note, !note.sustainHit);
		});

		generateStrums(skin);
		Conductor.instance.onBeat.add(beat);
	}

	function generateStrums(skin:String = 'default', i:Int = 4)
	{
		for (i in 0...i)
		{
			var strum = strums.add(new Strum(i, this, skin));
			strum.applyPosition(strums.x + ((160 * 0.7 * scale) * i), strums.y);
		}
	}

	public var songSpeed:Float = 1;

	override function update(elapsed:Float)
	{
		if (!cpu)
			keyFunction(elapsed);

		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if (songSpeed < 1)
				time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].noteData.time - Conductor.instance.time < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}
		super.update(elapsed);

		for (note in notes)
		{
			if (note == null || !note.alive || !note.exists)
				return;
			var strum = strums.members[note.noteData.data];
			note.followStrum(strum, songSpeed);

			if (cpu && note.wasGoodHit)
			{
				strum.resetAnim = Conductor.instance.stepCrochet * 1.5 / 1000;
				hitSignal.dispatch(note);
				if (!note.sustainHit)
				{
					strum.playAnim('confirm', true);
				}
				note.sustainHit = true;
			}
			if (note.noteData.time + note.noteData.length < Conductor.instance.time && note.wasGoodHit)
			{
				if (cpu && note.noteData.length > 0)
					strum.playAnim('static');
				destroyNote(note);
			}
			if (releasedSustain(note)) // returns false if cpu is true
			{
				missSignal.dispatch(note, null);
				destroyNote(note);
			}

			if (note.noteData.time < Conductor.instance.time - (350 / songSpeed)) // note misses when it is too late foryou to hit
			{
				if (!cpu && !note.wasGoodHit && !note.ignoreNote && !note.handledMiss)
				{
					missSignal.dispatch(note, null);
					note.handledMiss = true;
					note.multAlpha = 0.5;
				}
			}

			if (note.noteData.time + note.noteData.length < Conductor.instance.time - (350 / songSpeed))
				destroyNote(note);
		}
	}

	function releasedSustain(note:Note):Bool
		return note != null && note.wasGoodHit && !cpu && !holding[note.noteData.data];

	public var missSignal:Event<Null<Note>->Null<Int>->Void> = new Event<Null<Note>->Null<Int>->Void>();
	public var hitSignal:Event<Note->Void> = new Event<Note->Void>();

	function destroyNote(note:Note)
	{
		if (note.sustain != null)
			note.sustain.destroy();
		sustains.remove(note.sustain, true);
		note.sustain = null;
		note.destroy();
		notes.remove(note, true);
	}

	public var holding = [];

	var hitNotes:Array<Note> = [];
	var directions:Array<Int> = [];
	var dumbNotes:Array<Note> = [];

	public function keyFunction(elapsed:Float)
	{
		var c = Controls.instance;

		// Reuse arrays instead of creating new ones every frame
		if (hitNotes == null)
			hitNotes = [];
		else
			hitNotes.resize(0);

		if (directions == null)
			directions = [];
		else
			directions.resize(0);

		// Cache input arrays
		var pressed = [
			c.justPressed.NOTE_LEFT,
			c.justPressed.NOTE_DOWN,
			c.justPressed.NOTE_UP,
			c.justPressed.NOTE_RIGHT
		];

		var released = [
			c.justReleased.NOTE_LEFT,
			c.justReleased.NOTE_DOWN,
			c.justReleased.NOTE_UP,
			c.justReleased.NOTE_RIGHT
		];

		this.holding = [
			c.pressed.NOTE_LEFT,
			c.pressed.NOTE_DOWN,
			c.pressed.NOTE_UP,
			c.pressed.NOTE_RIGHT
		];
		// Handle strum press/release animations

		strums.forEachAlive((strum:Strum) ->
		{
			if (pressed[strum.id])
				strum.playAnim('press');
			if (released[strum.id])
				strum.playAnim('static');
		});
		// Collect hittable notes + directions
		for (note in notes.members)
		{
			if (note != null && note.inHitZone)
			{
				hitNotes.push(note);
				directions.push(note.noteData.data);
			}
		}

		if (!holding.contains(true))
			playerDance();

		// Handle actual keypress hit detection
		if (pressed.indexOf(true) != -1)
		{
			for (i in 0...pressed.length)
			{
				if (pressed[i] && !directions.contains(i) && hitNotes.length > 0)
				{
					missSignal.dispatch(null, i);
				}
			}

			for (note in hitNotes)
			{
				if (pressed[note.noteData.data])
				{
					playerHit(note);
				}
			}
		}
	}

	function playerHit(note:Note)
	{
		var strum = strums.members[note.noteData.data];

		strum.playAnim('confirm');
		hitSignal.dispatch(note);
		note.wasGoodHit = true;
		note.sustainHit = true;

		if (note.noteData.time + note.noteData.length < Conductor.instance.time && note.wasGoodHit)
		{
			if (cpu && note.noteData.length > 0)
				strum.playAnim('static');
			destroyNote(note);
		}
	}

	public function beat(e:Float)
	{
		characterBopper(Math.floor(e));
	}

	inline public function characterBopper(beat:Int):Void
	{
		switch (character.dancer)
		{
			case false:
				if (character != null
					&& beat % character.danceEveryNumBeats == 0
					&& !character.getAnimationName().startsWith('sing')
					&& !character.stunned)
					character.dance();
			case true:
				if (character != null
					&& beat % Math.round(1 * character.danceEveryNumBeats) == 0
					&& !character.getAnimationName().startsWith('sing')
					&& !character.stunned)
					character.dance();
		}
	}

	inline public function playerDance():Void
	{
		var anim:String = character.getAnimationName();
		if (character.holdTimer > Conductor.instance.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.timeScale #end) * character.singDuration
			&& anim.startsWith('sing'))
			character.dance();
	}
}
