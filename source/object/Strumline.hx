package object;

import backend.controls.Controls;
import lime.app.Event;

class Strumline extends FlxGroup
{
	public var unspawnNotes:Array<Note> = [];
	public var strums:FlxTypedSpriteGroup<Strum>;
	public var notes:FlxTypedGroup<Note>;
	public var sustains:FlxTypedGroup<Sustain>;

	public var cpu:Bool = false;

	public function new(x:Float = 0, y:Float = 0, ?skin:String = 'default')
	{
		super();

		sustains = new FlxTypedGroup<Sustain>();
		add(sustains);

		strums = new FlxTypedSpriteGroup<Strum>(x, y);
		add(strums);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		generateStrums(skin);
	}

	function generateStrums(skin:String = 'default', i:Int = 4)
	{
		for (i in 0...i)
		{
			var strum = strums.add(new Strum(i, skin));
			strum.applyPosition(strums.x + ((160 * 0.7) * i), strums.y);
			strum.strumline = this;
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

			if (note.noteData.time + note.noteData.length < Conductor.instance.time - (350 / songSpeed))
			{
				if (!cpu && !note.wasGoodHit && !note.ignoreNote)
					missSignal.dispatch(note, null);
				destroyNote(note);
			}
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

		if (note.noteData.time + note.noteData.length < Conductor.instance.time && note.wasGoodHit)
		{
			if (cpu && note.noteData.length > 0)
				strum.playAnim('static');
			destroyNote(note);
		}
	}
}
