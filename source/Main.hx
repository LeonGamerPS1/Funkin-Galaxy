package;

import haxe.io.Path;
import openfl.display.Sprite;
#if (!mobile)
import haxe.ui.Toolkit;
import haxe.ui.themes.Theme;
#elseif (android)
import extension.androidtools.content.Context;
#end

class Main extends Sprite
{
	public static var subdivs(default, null):Int = 1;

	public function new()
	{
		super();

		#if android
		NativeAndroid.request();
		#end

		#if android
		Sys.setCwd(Path.addTrailingSlash(Context.getExternalFilesDir()));
		#elseif ios
		Sys.setCwd(LimeSystem.applicationStorageDirectory);
		#end

		#if (!mobile)
		Toolkit.theme = "dark";
		Toolkit.init();
		#end
		addChild(new FlxGame(0, 0, InitState, 120, 120));
		#if polymod
		Poly.reload();
		#end
		addChild(new openfl.display.FPS(10, 0, 0xFFFFFFFF));
	}
}
