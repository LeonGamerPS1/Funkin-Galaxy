package object;

class Strum extends FlxSprite {
	public var id = 0;
	public var skin:NoteSkinData;
	public var downScroll:Bool = false;
	public var strumline:Strumline; // only for stuff. bitch

	public function new(id:Int = 0, ?skin:String = "default") {
		super();
		this.id = id;
		trace(id);
		this.skin = NoteSkinConfig.getSkin(skin);

		applySkin();
	}

	public static var directions:Array<String> = ["left", "down", "up", "right"];

	public function applySkin() {
		var img = Assets.getAtlas(skin.image);
		frames = img;

		animation.addByPrefix('static', '${directions[id]} static', 24, false);
		animation.addByPrefix('confirm', '${directions[id]} confirm', 24, false);
		animation.addByPrefix('press', '${directions[id]} press', 24, false);
		antialiasing = true;
		playAnim('static');
		updateHitbox();

		setGraphicSize(width * skin.scaleFactor);
		updateHitbox();
	}

	public function playAnim(name:String = "static", ?force:Bool = false) {
		animation.play(name, force);

		centerOffsets();
		centerOrigin();
	}

	public function applyPosition(x:Float = 0, y:Float = 0):Strum { // exists because setPosition  stinky.. hehh...
		setPosition(x, y);
		return this;
	}
	public var resetAnim:Float = 0;

	override function update(elapsed:Float) {
		if (resetAnim > 0) {
			resetAnim -= elapsed;
			if (resetAnim < 0) {
				resetAnim = 0;
				playAnim('static');
			}
		}
		super.update(elapsed);
	}
}
