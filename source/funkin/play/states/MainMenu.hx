package funkin.play.states;

import flixel.effects.FlxFlicker;

class MainMenu extends FlxUIState
{
	public var items:FlxTypedGroup<MenuItem>;
	public var camFollow:FlxObject;
	public var selected:Int = 0;
	public var currentItem:MenuItem;

	static var its = ['story-mode', 'freeplay', 'donate', 'options'];

	public function s(add:Int = 0)
	{
		selected += add;
		if (selected < 0)
			selected = items.length - 1;
		else if (selected > items.length - 1)
			selected = 0;
		currentItem = items.members[selected];
		for (item in items)
		{
			item.kiss(item == currentItem ? 'selected' : 'idle');
		}
		camFollow.setPosition(currentItem.getGraphicMidpoint().x, currentItem.getGraphicMidpoint().y);
		FlxG.sound.play(Paths.sound('menu/scrollMenu'));
	}

	override function create()
	{
		super.create();

		var spr:FlxSprite = cast add(new FlxSprite(0, 0, Paths.image('menu/backgrounds/menuBG')));
		spr.scrollFactor.set(0.1, 0.1);
		spr.scale.set(1.3, 1.3);
		spr.updateHitbox();
		spr.antialiasing = true;
		spr.screenCenter();
		items = new FlxTypedGroup<MenuItem>();
		add(items);

		generate(its);
		FlxG.camera.flash(FlxColor.BLACK, 0.75);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 0.06);

		s();
	}

	function generate(arr:Array<String>)
	{
		for (i in arr)
		{
			var kissed:MenuItem = new MenuItem(i);
			kissed.screenCenter();
			kissed.y -= kissed.height;
			kissed.y += (160 * items.length - 1);
			items.add(kissed);
		}
	}

	var ss = false;

	override function update(elapsed:Float)
	{
		if (Controls.instance.justPressed.UI_UP && !ss)
			s(-1);
		else if (Controls.instance.justPressed.UI_DOWN && !ss)
			s(1);
		if (Controls.instance.justPressed.UI_ACCEPT && !ss)
		{
			ss = true;
			FlxG.sound.play(Paths.sound('menu/confirmMenu'));
			FlxFlicker.flicker(currentItem, 1, 0.04, true, true, (fl) ->
			{
				switch (its[selected])
				{
					default:
						FlxG.sound.play(Paths.sound('menu/cancelMenu'));
						ss = false;
					case 'story-mode':
						FlxG.switchState(() -> new PlayState());
					case 'freeplay':
						FlxG.switchState(() -> new Freeplay());
				}
			});
		}
		super.update(elapsed);
	}
}
