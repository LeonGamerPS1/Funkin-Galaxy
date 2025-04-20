package backend;

typedef SongMap = {
	var displayName:String; // name of the song to be displayed
	var players:Array<String>; // dad is first, gf is second and bf is third
	var songName:String; // name of the song
	var stage:String; // name of the stage

	var speed:Float; // speed of the song
	var bpm:Float; // beats per minute

	var composer:String; // who composed the song
	var charter:String; // who charted the song
	var tracks:T_trackdata_;

	var bpmMap:Array<BPMChange>; // silly goober bpm changes

	var notes:Array<NoteData>;
	var events:Array<Event>; // events that happen in the song like camera movement, etc
	@:optional var skinPlayer:String;
	@:optional var skinEnemy:String;
}

typedef BPMChange = {
	var denominator:Float; // beatcount of the measure
	var numerator:Float; // stepcount of the beat :3 both this and denominator are 4 by default

	var bpm:Float; // beats per minute
	var time:Float; // time in ms telling  the game when the bpm change happens
}

typedef T_trackdata_ = {
	var main:String;
	@:optional var extra:Array<String>;
}

typedef NoteData = {
	var time:Float; // time of the note
	var data:Int; // direction of the note
	var length:Float; // length of the note
	var type:String; // type of the note
	var strumLine:Int; // the strumline of the note
}

typedef Event = {
	var time:Float; // time of the event
	var values:Array<Dynamic>;
	var name:String; // name of the event
}

class Song {
	private static var _cache(default, null):Map<String, SongMap> = new Map<String, SongMap>();

	public static function grabSong(songID:String = 'Duality', jsonName:String = 'hard'):SongMap
	{
		final songPath:String = Assets.getAssetPath('songs/$songID/$jsonName.json');

		var id:String = '$songID-$jsonName';
		if (_cache.exists(id))
			return Reflect.copy(_cache.get(id));
		if (Assets.exists(songPath))
		{
			var json = Json.parse(Assets.getText(songPath));
			_cache.set(id, json);

			return Reflect.copy(json);
		}
		return {
			displayName: 'Unknown',
			players: ['dead', 'dead', 'dead'],
			songName: 'UK',
			speed: 2.3,
			bpm: 180,
			composer: 'VOID',
			charter: 'empty',
			tracks: {main: 'music/poop.ogg'},
			notes: [],
			bpmMap: [],
			stage: '',
			events: []
		};
	}

	public static function fromPsychLegacy(legacyJson:moonchart.formats.fnf.legacy.FNFPsych) {
		// uwu~
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
			bpmMap: [],
			stage: legacyJson.data.song.stage,

			bpm: legacyJson.data.song.bpm,
			speed: legacyJson.data.song.speed,
			tracks: {
				main: 'songs/${legacyJson.data.song.song}/Inst.ogg',
				extra: ['songs/${legacyJson.data.song.song}/Voices.ogg']
			},

			notes: [],
			events: []
		};

		var beatLength:Float = 60 / output.bpm;
		beatLength *= 1000;

		for (section in legacyJson.data.song.notes) {
			var sectionTime:Float = (beatLength * 4) * (legacyJson.data.song.notes.indexOf(section));
			if (section.changeBPM == true) {
				beatLength = 60 / output.bpm;
				beatLength *= 1000;
				sectionTime = (beatLength * 4) * (legacyJson.data.song.notes.indexOf(section));

				output.bpmMap.push({
					time: sectionTime,
					denominator: 4,
					numerator: 4,
					bpm: section.bpm
				});
			}

			output.events.push({
				time: sectionTime,
				name: 'Camera Focus',
				values: [section.mustHitSection ? 'bf' : 'dad']
			});

			for (note in section.sectionNotes) {
				var mustHit = section.mustHitSection;
				if (note.lane > 3)
					mustHit = !section.mustHitSection;

				var data = note.lane % 4;
				var type = 'normal';

				if (section.altAnim)
					type = 'Alt Note';

				output.notes.push({
					time: note.time,
					data: data,
					length: note.length,
					strumLine: !mustHit ? 0 : 1,
					type: type
				});
			}
		}

		return output;
	}

	public static function fromVslice(legacyJson:moonchart.formats.fnf.FNFVSlice) {
		// TODO: Finish chart converter for  vslice to galaxy
	}
}
