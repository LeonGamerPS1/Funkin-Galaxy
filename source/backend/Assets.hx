package backend;

import openfl.media.Sound;
import openfl.net.URLRequest;

class Assets
{
	static var images(default, null):Map<String, FlxGraphic> = new Map();
	static var sounds(default, null):Map<String, Sound> = new Map();

	inline public static function getPath(path:String)
	{
		return getPreloadPath(path);
	}

	inline public static function getPreloadPath(path:String)
	{
		return 'assets/$path';
	}

	inline public static function font(key:String)
	{
		return getPath('fonts/$key');
	}

	inline public static function sound(key:String):Sound
	{
		var path = getPath('sounds/$key.ogg');
		if (sounds.exists(path))
			return sounds.get(path);

		if (openfl.Assets.exists(path, SOUND))
		{
			var sound:Sound = new Sound(new URLRequest(path));
			sounds.set(path, sound);
			return sound;
		}

		Log.error('Could not find Sound of ID (path: $path | key: sounds/$key.png).');
		return null;
	}

	inline public static function image(key:String):FlxGraphic
	{
		var path:String = getPath('images/$key.png');
		if (images.exists(path))
			return images.get(path);

		if (openfl.Assets.exists(path, IMAGE))
		{
			var image:FlxGraphic = FlxGraphic.fromBitmapData(openfl.Assets.getBitmapData(path));
			image.bitmap.disposeImage();
			images.set(path, image);

			return image;
		}

		Log.error('Could not find Image of ID (path: $path | key: images/$key.png).');
		return null;
	}

	public static inline function xml(key:String):String
	{
		return getPath('images/$key.xml');
	}

	public inline static function txt(key:String, ?folder:String = 'data'):String
	{
		return getPath('$folder/$key.txt');
	}

	inline static public function getPackerAtlas(key:String):FlxAtlasFrames
	{
		var imageLoaded = image(key);

		return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, getPath('images/$key.txt'));
	}

	public static inline function getSparrowAtlas(key:String)
	{
		return FlxAtlasFrames.fromSparrow(image('$key'), xml('$key'));
	}

	public static function getAtlas(key:String)
	{
		if (openfl.Assets.exists(txt(key, 'images')))
			return getPackerAtlas(key);
		if (openfl.Assets.exists(xml('$key')))
			return getSparrowAtlas(key);

		return getSparrowAtlas(key);
	}

	public static function readAssetsDirectoryFromLibrary(path:String, ?type:String, ?suffix:String = "", ?removePath:Bool = false):Array<String>
	{
		final lib = openfl.utils.Assets.getLibrary('default');
		final list:Array<String> = lib.list(type);
		path = 'assets/$path';
		var stringList:Array<String> = [];
		for (hmm in list)
		{
			if (!hmm.startsWith(path) || !hmm.endsWith(suffix))
				continue;
			var bruh:String = null;
			if (removePath)
				bruh = hmm.replace('$path/', '');
			else
				bruh = hmm;
			stringList.push(bruh);
		}
		stringList.sort(Reflect.compare);
		return stringList;
	}

	@:inheritDoc(openfl.Assets.getText)
	public static function getText(id:String)
	{
		return openfl.Assets.getText(id);
	}

	@:inheritDoc(openfl.Assets.getText)
	public static function exists(id:String)
	{
		return openfl.Assets.exists(id);
	}
}
