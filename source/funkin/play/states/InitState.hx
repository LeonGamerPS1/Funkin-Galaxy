package funkin.play.states;


import openfl.filters.ShaderFilter;

// init state or some shit
@:access(Main)
@:unreflective
class InitState extends FlxUIState
{
	override function create():Void
	{
		if (Controls.instance == null)
			FlxG.inputs.addUniqueType(Controls.instance = new Controls('galaxyfnf_'));
		FlxG.save.bind('galaxyfnf', 'galaxy');

		#if html5 lime.app.Application.current.window.element.style.setProperty("image-rendering", "pixelated"); #end
		FlxG.switchState(() -> new Title()); 
	}
}
