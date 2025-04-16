package states;

class InitState extends FlxState {
    override function create() {
        Log.init();
		NoteSkinConfig.init();
        super.create();
        FlxG.switchState(new PlayState());
    }
}