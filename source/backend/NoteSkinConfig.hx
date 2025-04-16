package backend;

import haxe.io.Path;

typedef NoteSkinData =
{
	var image:String;
	var scaleFactor:Float;
	var name:String;
}

class NoteSkinConfig
{
	static public var noteSkins(default,
		null):Map<String, NoteSkinData> = []; // unsafe get is noteSkins.get, safe is getSkin(). (returns default/fallback sometimes)

	public static inline function init()
	{
		for (skinPath in Assets.readAssetsDirectoryFromLibrary('images/noteSkins', 'TEXT', '.json'))
		{
			var rawSkinData:String = Assets.getText(skinPath);
			var skin:NoteSkinData;
			try
			{
				skin = cast Json.parse(rawSkinData);
                trace('parsed skin ${skin.name}');
			}
			catch (e_:Dynamic)
			{
				Log.error('Failed to parse skin $skinPath');
				continue;
			}
			noteSkins.set(skin.name, skin);
		}
	}

	public static inline function getSkin(_):NoteSkinData
	{
		var skin = noteSkins.get(_);
		if (skin == null) {
			skin = {image: "noteSkins/note", scaleFactor: 0.7, name: "Default"};
            Log.warn('Skin $_ not found. Reverting...');
        }

		return skin;
	}
}
