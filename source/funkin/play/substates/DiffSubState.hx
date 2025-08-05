package funkin.play.substates;


import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUISubState;
import flixel.addons.ui.StrNameLabel;

class DiffSubState extends FlxUISubState
{
	public static var diffs:Array<String> = ['easy', 'normal', 'hard']; // freeplay changes this depending on what week of the song u selected

	public static var songName:String = ""; // depends on song
    public var dropdown_diff:FlxUIDropDownMenu;

	public override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite(0, 0);
		bg.makeGraphic(1, 1, 0x79000000);
		bg.scale.set(FlxG.width / 4, FlxG.width / 5);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		var txt:FlxText = new FlxText(bg.x + bg.width / 2, bg.y + bg.height / 3, 0, songName);
       
		txt.setFormat(Paths.font('vcr.ttf'), 30, FlxColor.WHITE, CENTER, OUTLINE_FAST, FlxColor.BLACK);
		txt.borderSize = 1;
         txt.x -= txt.width / 2;
		add(txt);


        var hairyTesticles = [];
        for(i in diffs)
            hairyTesticles.push(new StrNameLabel(i,i));
        dropdown_diff = new FlxUIDropDownMenu(bg.x,bg.y + bg.height * 0.8,hairyTesticles);
        dropdown_diff.width += dropdown_diff.width / 2;
        dropdown_diff.width -= bg.width / 2;
        add(dropdown_diff);

	}

    var gubby = 'spoonful gay';

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(gubby != null) {
            gubby = null;
            return;
        }
        if(Controls.instance.justPressed.UI_ACCEPT) {
            close();
            PlayState.story = false;
            PlayState.song = Song.grabSong(songName,dropdown_diff.selectedId);
            FlxG.switchState(new PlayState());
        }
    }
}
