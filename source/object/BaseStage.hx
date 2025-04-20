package object;

class BaseStage extends FlxBasic
{
	var parent:FlxState;
	var boyfriend(get, null):Character;
	var dad(get, null):Character;
	var gf(get, null):Character;

	public var curStep:Float = 0;
	public var curBeat:Float = 0;
	public var curSection:Float = 0;

	public function new(parentState:FlxState, autoCreate:Bool = false,?classname:String = "") // class name is for scripted stages ok
	{
		super();
		parent = parentState;
		if (parent is IStageState)
			cast(parent, IStageState).addStage(this);
		parent.add(this);

		if (autoCreate == true)
			create();
	}

	public function create() {}

	public function setStartCallback(fnc:() -> Void)
	{
		if (parent != null)
			if (parent is PlayState)
				cast(parent, PlayState).startCallback = fnc;
	}

	public function startCountdown()
	{
		if (parent != null)
			@:privateAccess
			if (parent is PlayState)
				cast(parent, PlayState).startCountdown();
	}

	public function createPost() {}

	public function add(basic:FlxBasic)
	{
		if (parent != null)
		{
			return parent.add(basic);
		}
		return null;
	}

	public function remove(basic:FlxBasic)
	{
		if (parent != null)
			parent.remove(basic);
	}

	public function updatePost(elapsed:Float) {}

	public function stepHit() {}

	public function beatHit() {}

	public function sectionHit() {}

	function get_boyfriend():Character
	{
		if (parent is PlayState)
			return cast(parent, PlayState).bf;
		return null;
	}

	function get_gf():Character
	{
		if (parent is PlayState)
			return cast(parent, PlayState).gf;
		return null;
	}

	function get_dad():Character
	{
		if (parent is PlayState)
			return cast(parent, PlayState).dad;
		return null;
	}
}
