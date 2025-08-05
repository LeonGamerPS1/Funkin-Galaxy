package funkin.play.song.data;

typedef CharacterPosition =
{
	var x:Float;
	var y:Float;
};

typedef SceneData =
{
	var dad:CharacterPosition;
	var gf:CharacterPosition;
	var bf:CharacterPosition;

	var bfCam:Array<Float>;
	var gfCam:Array<Float>;
	var dadCam:Array<Float>;
	var zoom:Float;
};
