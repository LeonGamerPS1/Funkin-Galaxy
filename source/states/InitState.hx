package states;

import backend.controls.Controls;

class InitState extends FlxState {
    override function create() {
        Log.init();
		NoteSkinConfig.init();
		Controls.instance = new Controls('funkincontrols');
		FlxG.inputs.addInput(Controls.instance);

        FlxG.switchState(new PlayState());
    }
}