package backend;

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

	var bpmMap:Array<BPMChange>; // silly goober bpm changes

	var notes:Array<NoteData>;
	var events:Array<Event>; // events that happen in the song like camera movement, etc
}

typedef BPMChange =
{
	var denominator:Float; // beatcount of the measure
	var numerator:Float; // stepcount of the beat :3 both this and denominator are 4 by default

	var bpm:Float; // beats per minute
	var time:Float; // time in ms telling  the game when the bpm change happens
}

typedef T_trackdata_ =
{
	var main:String;
	@:optional var extra:Array<String>;
}

typedef NoteData =
{
	var time:Float; // time of the note
	var data:Int; // direction of the note
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
	private static var _cache(default, null):Map<String, SongMap> = new Map<String, SongMap>();

	public static function grabSong(songID:String = "Test", jsonName:String = "hard"):SongMap
	{
		var id:String = songID + '-$jsonName';
		if (_cache.exists(id))
			return Reflect.copy(_cache.get(id));
		if (Assets.exists('assets/songs/$songID/$jsonName.json'))
		{
			var json = Json.parse(Assets.getText('assets/songs/$songID/$jsonName.json'));
			_cache.set(id, json);

			return Reflect.copy(json);
		}
		return {
			displayName: "Unknown",
			players: ["dead", "dead", "dead"],
			songName: "UK",
			speed: 2.3,
			bpm: 180,
			composer: "VOID",
			charter: "empty",
			tracks: {main: "music/poop.ogg"},
			notes: [],
			bpmMap: [],
			stage: "",
			events: []
		};
	}

	public static function fromPsychLegacy(legacyJson:moonchart.formats.fnf.legacy.FNFPsych)
	{
		// TODO: Finish chart converter for legacy psych to galaxy
	}

	public static function fromPsych(legacyJson:moonchart.formats.fnf.FNFVSlice)
	{
		// TODO: Finish chart converter for  vslice to galaxy

	}
}
