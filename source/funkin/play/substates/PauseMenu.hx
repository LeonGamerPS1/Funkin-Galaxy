package funkin.play.substates;

import flixel.addons.ui.FlxUISubState;
import openfl.display.BitmapData;

class PauseMenu extends FlxUISubState
{
	var cam = null;
	var texts:FlxTypedGroup<FlxText>;
	var items:Array<String> = ["Resume", "Restart", "Bot", "Exit"];

	var infoText:FlxText;

	public function new(cam)
	{
		super();
		this.cam = cam;
		cameras = [cam];
	}

	var cur = 0;

	public function change(add:Int = 0)
	{
		cur += add;
		if (cur < 0)
			cur = 0;
		if (cur > texts.length - 1)
			cur = texts.length - 1;

		for (_ in texts)
			_.alpha = _ == texts.members[cur] ? 1 : 0.5;
	}

	public override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite(0, 0);
		bg.makeGraphic(1, 1, 0x79000000);
		bg.scale.set(FlxG.width + 1, FlxG.height + 1);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		texts = new FlxTypedGroup();
		add(texts);

		for (butt in items)
		{
			var text:FlxText = new FlxText(0, 0, 0, butt.toUpperCase());
			text.setFormat(Paths.font('vcr.ttf'), 36, FlxColor.WHITE);
			text.screenCenter();
			text.antialiasing = true;
			text.y += text.height * items.indexOf(butt);
			texts.add(text);
		}
		change();

		infoText = new FlxText(20, 20, 0, '', 36, true);
		infoText.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		infoText.text += PlayState.song.displayName + '\nComposer: ' + PlayState.song.composer + '\nCharter: ' + PlayState.song.charter;
		add(infoText);
	}

	var butt = false;

	override function update(elapsed:Float)
	{
		if (!butt)
		{
			butt = true;
			return;
		}
		super.update(elapsed);

		if (Controls.instance.justPressed.UI_BACK)
		{
			close();
		}

		if (Controls.instance.justPressed.UI_UP)
			change(-1);
		if (Controls.instance.justPressed.UI_DOWN)
			change(1);

		if (Controls.instance.justPressed.UI_ACCEPT)
		{
			switch (texts.members[cur].text.toLowerCase())
			{
				case 'resume':
					close();
				case 'bot':
					PlayState.self.plrStrums.cpu = !PlayState.self.plrStrums.cpu;

				case 'restart':
					close();
					FlxG.resetState();
				case 'exit':
					close();
					if (PlayState.story)
						FlxG.switchState(new MainMenu());
					else
						FlxG.switchState(new Freeplay());
			}
		}
	}
}
