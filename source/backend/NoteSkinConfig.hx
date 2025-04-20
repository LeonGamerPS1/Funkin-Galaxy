package backend;

import haxe.io.Path;

typedef NoteSkinData =
{
	var image:String;
	var scaleFactor:Float;
	var name:String;
	@:optional var antialiasing:Bool;
}

class NoteSkinConfig
{
	public static var noteSkins(default, null):Map<String, NoteSkinData> = new Map();

	public static inline function init():Void
	{
		final skinPaths = Assets.readAssetsDirectoryFromLibrary('images/noteSkins', 'TEXT', '.json');

		for (skinPath in skinPaths)
		{
			var rawSkinData = Assets.getText(skinPath);

			try
			{
				var skin = cast Json.parse(rawSkinData);
				noteSkins.set(skin.name, skin);
			}
			catch (e:Dynamic)
			{
				Log.error('Failed to parse skin $skinPath: $e');
			}
		}
	}

	public static inline function getSkin(name:String):NoteSkinData
	{
		return noteSkins.exists(name) ? noteSkins.get(name) : getDefaultSkin(name);
	}

	private static inline function getDefaultSkin(missingName:String):NoteSkinData
	{
		Log.warn('Skin '$missingName ' not found. Reverting to default.');
		return {
			image: 'noteSkins/note',
			scaleFactor: 0.7,
			name: 'Default',
			antialiasing: true
		};
	}
}
