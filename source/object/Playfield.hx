package object;

import backend.Song.SongMap;
import flixel.text.FlxText;
import flixel.util.FlxStringUtil;

class Playfield extends FlxGroup
{
	var playerStrums:Strumline;
	var opponentStrums:Strumline;

	public var strumlines:Array<Strumline> = [];
	public var songSpeed(default, set):Float = 1;
	public var healthBar:Bar;
	public var health:Float = 1;

	public var iconP1:FlxTypedSpriteGroup<HealthIcon>;
	public var iconP2:FlxTypedSpriteGroup<HealthIcon>;
	public var scoreText:FlxText;
	public var score:Float = 0;

	public function new(skin:String = 'default', song:SongMap, downScroll:Bool = false)
	{
		super();
		var last = skin;
		var enemySkin = song.skinEnemy ?? skin;
		var playerSkin = song.skinPlayer ?? skin;

		opponentStrums = new Strumline(50, downScroll ? FlxG.height - 150 : 50, enemySkin);
		opponentStrums.cpu = true;
		add(opponentStrums);
		strumlines.push(opponentStrums);

		playerStrums = new Strumline(100 + (FlxG.width / 2), downScroll ? FlxG.height - 150 : 50, playerSkin);
		add(playerStrums);

		strumlines.push(playerStrums);

		healthBar = new Bar(0, !downScroll ? FlxG.height - 80 : FlxG.height * 0.09, 'healthBar', () -> return health, 0, 2);
		healthBar.screenCenter(X);
		add(healthBar);

		scoreText = new FlxText(healthBar.x + healthBar.width - 190, healthBar.y + 30, 0, 'Score: 0', 20);
		scoreText.setFormat(Assets.font('vcr.ttf'), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreText.scrollFactor.set();
		add(scoreText);

		iconP1 = new FlxTypedSpriteGroup<HealthIcon>();
		iconP2 = new FlxTypedSpriteGroup<HealthIcon>();
		add(iconP2);
		add(iconP1);

		for (_ in strumlines)
		{
			_.missSignal.add(onMiss);
			_.hitSignal.add(onHit);
			for (gay in _.strums)
				gay.downScroll = downScroll;
		}

		songSpeed = song.speed;
		generateNotes(song);
	}

	public function addIcon(id:String = 'dad', ?player:Bool = false)
	{
		var icon = new HealthIcon(id, player);
		var group = player ? iconP1 : iconP2;
		group.add(icon);
		group.origin.set(group.origin.x, group.origin.y);
	}

	dynamic public function onMiss(note:Note, miss:Int)
	{
		health -= 0.05;
		score -= 150;
	}

	public function onHit(note:Note)
	{
		var strumline = note.strumline;
		strumline.character.confirmAnimation(note, !note.sustainHit);
		if (!note.wasGoodHit && note.strumline.cpu == false)
		{
			health += 0.05;
			var timing:Float = Math.abs(Conductor.instance.time - note.noteData.time);
			var quantizedTiming:Float = Math.floor(timing * 5) / 5;
			var ratio:Float = 1 - (quantizedTiming / Conductor.safeZoneOffset);

			score += Math.floor(350 * ratio);
		}
	}

	function generateNotes(song:SongMap)
	{
		song.notes.sort((one, two) -> return Math.floor(one.time - two.time));
		for (note in song.notes)
		{
			if (strumlines[note.strumLine] == null)
				continue;
			var noteObject:Note = new Note(note, strumlines[note.strumLine].strums.members[note.data].skin.name);
			strumlines[note.strumLine].unspawnNotes.push(noteObject);
			noteObject.strumline = strumlines[note.strumLine];

			if (note.length > 0)
			{
				noteObject.sustain = new Sustain(noteObject);
				@:privateAccess
				noteObject.sustain.parent = noteObject;
				noteObject.strumline.sustains.add(noteObject.sustain);
			}
		}
	}

	function set_songSpeed(value:Float):Float
	{
		var prev = songSpeed;
		songSpeed = value;

		if (songSpeed != prev)
			for (_ in strumlines)
				_.songSpeed = value;

		return songSpeed = value;
	}

	public override function update(elapsed:Float)
	{
		scoreText.text = 'Score: ${FlxStringUtil.formatMoney(score, true, false).replace(',00', '')}'; // because i dont want ,00
		iconP1.x = healthBar.barCenter + (150) - 150 - 24;
		iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		for (icon in iconP1)
		{
			var i = iconP1.members.indexOf(icon);
			icon.setPosition(iconP1.x + ((i < 1 ? 150 : 70) * i));
			icon.y = iconP1.y;
			if (healthBar.percent > 80)
				icon.animation.curAnim.curFrame = icon.winningIconFrame;
			else if (healthBar.percent < 20)
				icon.animation.curAnim.curFrame = 1;
			else
				icon.animation.curAnim.curFrame = 0;
		}

		for (icon in iconP2)
		{
			var i = iconP2.members.indexOf(icon);
			icon.setPosition(iconP2.x - ((i < 1 ? 150 : 70) * i));

			icon.y = iconP2.y;
			if (healthBar.percent > 80)
				icon.animation.curAnim.curFrame = 1;
			else if (healthBar.percent < 20)
				icon.animation.curAnim.curFrame = icon.winningIconFrame;
			else
				icon.animation.curAnim.curFrame = 0;
		}
		health = FlxMath.bound(health, 0, 2);
		super.update(elapsed);
	}
}
