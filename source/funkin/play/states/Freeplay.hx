package funkin.play.states;

class FreeplayTXT extends FlxText
{
	public var week:WeekInfo;
}

class Freeplay extends FlxUIState
{
	public var weeksToParse = CoolUtil.coolTextFile(Paths.txt('weeks'));

	public var group:FlxTypedGroup<FreeplayTXT>;
	public var currentItem:FreeplayTXT;
	public var selected = 0;
	public var camFollow:FlxObject;

	public function change(add:Int = 0)
	{
		selected += add;
		if (selected < 0)
			selected = group.length - 1;
		else if (selected > group.length - 1)
			selected = 0;
		currentItem = group.members[selected];
		for (huh in group.keyValueIterator())
		{
			var tendrill = huh.value;
			tendrill.alpha = tendrill == currentItem ? 1 : 0.4;
		}
		camFollow.setPosition(currentItem.x + 230, currentItem.getGraphicMidpoint().y);
		FlxG.camera.follow(camFollow, LOCKON, 0.07);
	}

	public override function create()
	{
		super.create();

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		var spr:FlxSprite = cast add(new FlxSprite(0, 0, Paths.image('menu/backgrounds/menuBG')));
		spr.scrollFactor.set(0.05, 0.05);
		spr.scale.set(1.3, 1.3);
		spr.updateHitbox();
		spr.color = FlxColor.GRAY;
		spr.antialiasing = true;
		spr.screenCenter();

		group = new FlxTypedGroup<FreeplayTXT>();
		add(group);
		for (week in weeksToParse)
		{
			var weekData:WeekInfo = Week.getWeek(week);
			if (weekData == null)
				return;

			for (song in weekData.songs)
			{
				var text:FreeplayTXT = new FreeplayTXT(0, 0, 0, song);
				text.setFormat(Paths.font('FridayFunkin-Regular.ttf'), 60, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK);
				text.antialiasing = true;
				@:privateAccess
				text.week = weekData;
				text.setBorderStyle(OUTLINE_FAST, FlxColor.BLACK, 1);
				group.add(text);
			}
		}
		change();
	}

	override function update(elapsed:Float)
	{
		if (Controls.instance.justPressed.UI_UP)
			change(-1);
		else if (Controls.instance.justPressed.UI_DOWN)
			change(1);
		if (Controls.instance.justPressed.UI_ACCEPT)
		{
			if (currentItem.week.diffs != null)
				DiffSubState.diffs = currentItem.week.diffs;
            DiffSubState.songName = currentItem.text;

			FlxG.camera.scroll.set();
			FlxG.camera.target = null;
            openSubState(new DiffSubState());
		}
		super.update(elapsed);
		for (id => item in group)
		{
			item.y = FlxMath.lerp(200 + item.height * 1.6 * id, item.y, Math.exp(-elapsed * 8));
			item.x = FlxMath.lerp(25 * id + 100, item.x, Math.exp(-elapsed * 8));
		}
	}
}
