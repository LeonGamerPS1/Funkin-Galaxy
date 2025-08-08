package funkin.play.song.data;

import moonchart.formats.fnf.legacy.FNFPsych;

typedef SongMap =
{
	var displayName:String; // name of the song to be displayed
	var players:Array<String>; // dad is first, gf is second and bf is third
	var songName:String; // name of the song
	var stage:String; // name of the stage

	var speed:Float; // speed of the song
	var bpm:Float; // beats per minute

	var composer:String; // who composed the song
	var charter:String; // who charted the song
	var tracks:T_trackdata_;

	var notes:Array<NoteData>;
	var events:Array<Event>; // events that happen in the song like camera movement, etc
	@:optional var skin:String;
}

typedef BPMChange =
{
	var bpm:Float; // beats per minute
	var time:Float; // time in ms telling  the game when the bpm change happens

	var denominator:Float; // beatcount of the measure
	var numerator:Float; // stepcount of the beat :3 both this and denominator are 4 by default
}

typedef T_trackdata_ =
{
	var main:String;
	@:optional var extra:Array<String>;
}

typedef NoteData =
{
	var time:Float; // time of the note
	var data:Int; // direction of the note duh
	var length:Float; // length of the note
	var type:String; // type of the note
	var strumLine:Int; // the strumline of the note
}

typedef Event =
{
	var time:Float; // time of the event
	var values:Array<Dynamic>;
	var name:String; // name of the event
}

class Song
{
	public static function grabSong(songID:String = 'Bopeebo', jsonName:String = 'erect'):SongMap
	{
		final songPath:String = Paths.getAssetPath('songs/$songID/$jsonName.json'); // assets/song/thing.json for example

		var id:String = '$songID-$jsonName';

		if (Paths.exists(songPath))
		{
			var fuckingRaw = Paths.getText(songPath);
			var raw = Json.parse(Paths.getText(songPath));
			var json:SongMap = null;
			if (raw.song != null && !(raw.song is String))
				json = fromPsychLegacy(new FNFPsych().fromJson(fuckingRaw));
			else
				json = cast raw;
			raw = null;
			fuckingRaw = null;
			json.events.sort(function(event1, event2) return Math.floor(event1.time - event2.time));
			json.players[1] ??= 'gf';
			return json;
		}
		return {
			displayName: 'Unknown',
			players: ['dead', 'dead', 'dead'],
			songName: 'UK',
			speed: 2.3,
			bpm: 180,
			composer: 'VOID',
			charter: 'empty',
			tracks: {main: 'music/poop.ogg', extra: []},
			notes: [],
			stage: '',
			events: []
		};
	}

	public static function fromPsychLegacy(legacyJson:moonchart.formats.fnf.legacy.FNFPsych)
	{
		// uwu~
		var raw = Json.parse(legacyJson.stringify().data);

		var tracks = raw.tracks ?? { // i fucking hate this chart converter thing
			main: 'songs/${legacyJson.data.song.song}/Inst.ogg',
			extra: ['songs/${legacyJson.data.song.song}/Voices.ogg']
		};
		var output:SongMap = {
			displayName: legacyJson.data.song.song,
			songName: legacyJson.data.song.song,
			players: [
				legacyJson.data.song.player2,
				legacyJson.data.song.gfVersion,
				legacyJson.data.song.player1
			],
			composer: null,
			charter: null,
			stage: legacyJson.data.song.stage,

			bpm: legacyJson.data.song.bpm,
			speed: legacyJson.data.song.speed,
			tracks: tracks,

			notes: [],
			events: [],
			skin: legacyJson.data.song.arrowSkin
		};

		var time:Float = 0;
		var currentBPM:Float = output.bpm;

		for (section in legacyJson.data.song.notes)
		{
			var intendedBPM:Null<Float> = (section.changeBPM) ? section.bpm : null;

			if (intendedBPM != null && intendedBPM != currentBPM)
				currentBPM = intendedBPM;

			output.events.push({
				time: time,
				name: 'Camera Focus',
				values: [section.mustHitSection ? 'bf' : 'dad']
			});

			for (note in section.sectionNotes)
			{
				var mustHit = section.mustHitSection;
				if (note.lane > 3)
					mustHit = !section.mustHitSection;

				var direction = note.lane % 4;
				var type = 'normal';

				if (section.altAnim)
					type = 'Alt Note';

				output.notes.push({
					time: note.time,
					data: direction,
					length: note.length,
					strumLine: !mustHit ? 0 : 1, // yes i do allow more than 2 strumlines or smth
					type: type
				});
			}
			if (section.changeBPM == true)
				output.events.push({name: "Change BPM", values: [section.bpm, 4, 4], time: time});
			time += (60 / currentBPM) * 4000;
		}

		for (i in legacyJson.getEvents())
		{
			output.events.push({time: i.time, values: [i.data.VALUE_1, i.data.VALUE_2], name: i.name});
		}

		return output;
	}

	public static function fromVslice(legacyJson:moonchart.formats.fnf.FNFVSlice)
	{
		// TODO: Finish chart converter for  vslice to hyper
		// totally didnt steal this file from my other project
	}
}
