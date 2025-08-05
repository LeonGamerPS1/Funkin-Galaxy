package funkin.shaders;

import flixel.addons.display.FlxRuntimeShader;

@:nullSafety
class GrayScale extends FlxRuntimeShader
{
	public function new()
	{
		super(Paths.getText(Paths.frag('grayscale')));
		setAmount(1);
	}

	public function setAmount(v:Float)
	{
		setFloatArray("_amount", [v]);
	}
}
