package funkin.play.song.data;

typedef AnimationData =
{
	var name:String;
	var prefix:String;

	@:optional var fps:Float;
	@:optional var looped:Bool;
	@:optional @:optional var flipX:Bool;
	@:optional var flipY:Bool;
	@:optional var indices:Array<Int>;
}
