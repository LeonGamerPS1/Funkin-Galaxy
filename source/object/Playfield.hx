package object;

import backend.Song.SongMap;

class Playfield extends FlxGroup {
	var playerStrums:Strumline;
	var opponentStrums:Strumline;

	public var strumlines:Array<Strumline> = [];
	public var songSpeed(default, set):Float = 1;

	public function new(skin:String = 'default', song:SongMap, downScroll:Bool = false) {
		super();

		opponentStrums = new Strumline(50, downScroll ? FlxG.height - 150 : 50, skin);
		opponentStrums.cpu = true;
		add(opponentStrums);
		strumlines.push(opponentStrums);

		playerStrums = new Strumline(100 + (FlxG.width / 2), downScroll ? FlxG.height - 150 : 50, skin);
		add(playerStrums);
		strumlines.push(playerStrums);

		for (_ in strumlines)
			_.missSignal.add(onMiss);

		songSpeed = song.speed;
		generateNotes(song, skin);
	}

	function onMiss(note:Note) {
		trace('missed note');
	}

	function generateNotes(song:SongMap, ?skin:String = "default") {
		song.notes.sort((one, two) -> return Math.floor(one.time - two.time));
		for (note in song.notes) {
			if (strumlines[note.strumLine] == null)
				continue;
			var noteObject:Note = new Note(note, skin);
			strumlines[note.strumLine].unspawnNotes.push(noteObject);
			noteObject.strumline = strumlines[note.strumLine];

			if (note.length > 0) {
				noteObject.sustain = new Sustain(noteObject);
				@:privateAccess
				noteObject.sustain.parent = noteObject;

				noteObject.strumline.sustains.add(noteObject.sustain);
			}
		}
	}

	function set_songSpeed(value:Float):Float {
		var prev = songSpeed;
		songSpeed = value;

		if (songSpeed != prev)
			for (_ in strumlines)
				_.songSpeed = value;

		return songSpeed = value;
	}
}
