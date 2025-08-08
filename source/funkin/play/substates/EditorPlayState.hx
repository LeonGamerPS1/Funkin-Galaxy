package funkin.play.substates;

import flixel.addons.ui.FlxUISubState;

class EditorPlayState extends FlxUISubState
{
	var song:SongMap;

	public var strumlineBot:StrumLine;
	public var strumlinePlayer:StrumLine;

	public var DS:Bool = false;
	public var inst:FlxSound;

	public function new(song:SongMap)
	{
		this.song = song;
		super();
	}

	var oldTime = .0;

	public var strumLines:Array<StrumLine> = [];
    var songSpeed(default,set):Float = 1;

	override function create()
	{
		super.create();
		var Y = DS ? FlxG.height - 150 : 50;
		strumlineBot = new StrumLine(50, Y, DS);
		strumLines.push(strumlineBot);
		add(strumlineBot);

		strumlinePlayer = new StrumLine(FlxG.width / 2 + 50, Y, DS);
		strumLines.push(strumlinePlayer);
		add(strumlinePlayer);

		inst = FlxG.sound.load('assets/${song.tracks.main}');
		inst.play();
		inst.time = Conductor.instance.time;
		oldTime = Conductor.instance.time;
        songSpeed = song.speed;
        
        genC();
	}

	var started = false;

	override function update(elapsed:Float)
	{
		Conductor.instance.time = inst.time;
		if (!started)
		{
			started = true;
			return;
		}
		super.update(elapsed);
		if (Controls.instance.justPressed.UI_BACK)
		{
			FlxG.sound.list.remove(inst, true);
			inst.destroy();
			inst = null;
			Conductor.instance.time = oldTime;

			close();
		}
	}

	// stolen from playstate lol
	function genC()
	{
		//for (_ in song.events)
		//	eventNotes.push(_);
		for (noteData in song.notes)
		{
            if(Conductor.instance.time - 350  > (noteData.time + noteData.length)  )
                continue;
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

    function set_songSpeed(value:Float):Float {
        if(songSpeed == value)
            return value;
        for(i in strumLines)
            i.songSpeed = value;
        return songSpeed = value;
    }
}
