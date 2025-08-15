package modchart.backend.standalone.adapters.galaxy;

class Galaxy implements IAdapter
{
	private var __fCrochet:Float = 0;

	public function getSongPosition():Float
	{
		return Conductor.instance.time;
	}

	public function getCurrentBeat():Float
	{
		return Conductor.instance.decBeat;
	}

	public function getCurrentCrochet():Float
	{
		return Conductor.instance.crochet;
	}

	public function getCurrentScrollSpeed():Float
	{
		return FlxG.state is PlayState ? cast(FlxG.state, PlayState).songSpeed * .45 : PlayState.song.speed * .45;
	}

	public function getBeatFromStep(step:Float):Float
	{
		return step * .25;
	}

	public function getDefaultReceptorX(lane:Int, player:Int):Float
	{
		return PlayState.self.strumLines[player].strums.members[lane].x;
	}

	public function getDefaultReceptorY(lane:Int, player:Int):Float
	{
		return !getDownscroll() ? PlayState.self.strumLines[player].strums.members[lane].y : FlxG.height
			- PlayState.self.strumLines[player].strums.members[lane].y - PlayState.self.strumLines[player].strums.members[lane].height;
	}

	public function getTimeFromArrow(arrow:FlxSprite):Float
	{
		if (arrow is Note)
		{
			final note:Note = cast arrow;
			return note.noteData.time;
		}

		return 0;
	}

	public function isTapNote(sprite:FlxSprite):Bool
	{
		return (sprite is Note);
	}

	public function isHoldEnd(sprite:FlxSprite):Bool
	{
		return sprite is Note && sprite.animation.name.toLowerCase().contains('end');
	}

	public function arrowHit(arrow:FlxSprite)
	{
		if (arrow is Note)
		{
			final note:Note = cast arrow;
			return note.wasGoodHit && !note.ignoreNote;
		}
		return false;
	}

	public function getHoldParentTime(arrow:FlxSprite)
	{
		final note:Note = cast arrow;
		return note.parent.noteData.time;
	}

	public function getHoldLength(sprite:FlxSprite):Float
		return Conductor.instance.stepCrochet;

	public function onModchartingInitialization()
	{
		__fCrochet = Conductor.instance.stepCrochet;
	}

	public function getLaneFromArrow(sprite:FlxSprite):Int
	{
		if (sprite is Note)
		{
			final note:Note = cast sprite;
			return note.noteData.data;
		}
		else if (sprite is Strum)
		{
			final note:Strum = cast sprite;
			return note.data;
		}
		else if (sprite is Strum)
		{
			final note:Strum = cast sprite;
			return note.data;
		}
		else if (sprite is SustainCover)
		{
			final note:SustainCover = cast sprite;
			return note.parent.data;
		}
		return 0;
	}

	public function getPlayerFromArrow(sprite:FlxSprite):Int
	{
		if (sprite is Note)
		{
			var note:Note = cast sprite;
			if (note.strumLine == null)
				return 0;
			return PlayState.self.strumLines.indexOf(note.strumLine);
		}
		else if (sprite is Strum)
		{
			var note:Strum = cast sprite;
			if (note.strumLine == null)
				return 0;
			return PlayState.self.strumLines.indexOf(note.strumLine);
		}
		else if (sprite is SustainCover)
		{
			var note:SustainCover = cast sprite;
		
			return PlayState.self.strumLines.indexOf(note.parent.strumLine);
		}
		return 0;
	}

	public function getKeyCount(?player:Int = 0):Int
	{
		return PlayState.self.strumLines[player].strums.length - 1;
	}

	public function getPlayerCount():Int
	{
		return PlayState.self != null && PlayState.self.strumLines != null ? PlayState.self.strumLines.length : 2;
	}

	public function getArrowCamera():Array<FlxCamera>
	{
		return [PlayState.self.camHUD];
	}

	public function getHoldSubdivisions(item:FlxSprite):Int
	{
		return Main.subdivs;
	}

	public function getDownscroll():Bool
	{
		return PlayState.self.downScroll;
	}

	public function getArrowItems()
	{
		var pspr:Array<Array<Array<FlxSprite>>> = [];

		var strumLineMembers = PlayState.self.strumLines;

		for (i in 0...strumLineMembers.length)
		{
			final sl = strumLineMembers[i];

			if (!sl.visible)
				continue;

			// this is somehow more optimized than how i used to do it (thanks neeo for the code!!)
			pspr[i] = [];
			pspr[i][0] = cast sl.strums.members.copy();
			pspr[i][1] = [];
			pspr[i][2] = [];
			pspr[i][3] = [];

			var st = 0;
			var nt = 0;
			sl.notes.forEachAlive((spr) ->
			{
				spr.isHold ? st++ : nt++;
			});

			pspr[i][1].resize(nt);
			pspr[i][2].resize(st);

			var si = 0;
			var ni = 0;
			sl.notes.forEachAlive((spr) -> pspr[i][spr.isHold ? 2 : 1][spr.isHold ? si++ : ni++] = spr);

			
			sl.covers.forEachAlive((spr:SustainCover) -> if (spr.parent != null && spr.active) pspr[i][3].push(spr));
		}

		return pspr;
	}
}
