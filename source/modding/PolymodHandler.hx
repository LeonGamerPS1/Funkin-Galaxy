package modding;

import polymod.Polymod;
import polymod.format.ParseRules.TextFileFormat;
import polymod.fs.ZipFileSystem;

class PolymodHandler
{
	static final MOD_FOLDER:String =
		#if (REDIRECT_ASSETS_FOLDER && macos)
		'../../../../../../../example_mods'
		#elseif REDIRECT_ASSETS_FOLDER
		'../../../../example_mods'
		#else
		'mods'
		#end;

	static final CORE_FOLDER:Null<String> =
		#if (REDIRECT_ASSETS_FOLDER && macos)
		'../../../../../../../assets'
		#elseif REDIRECT_ASSETS_FOLDER
		'../../../../assets'
		#else
		null
		#end;

	public static var loadedMods:Array<ModMetadata> = [];

	// Use SysZipFileSystem on desktop and MemoryZipFilesystem on web.
	static var modFileSystem:Null<ZipFileSystem> = null;

	public static function init(?framework:Null<Framework>)
	{
		#if (!android)
		#if sys // fix for crash on sys platforms
		if (!sys.FileSystem.exists('./mods'))
			sys.FileSystem.createDirectory('./mods');
		#end
		var dirs:Array<String> = [];
		var polyMods = Polymod.scan({modRoot: './mods/'});
		for (i in 0...polyMods.length)
		{
			var value = polyMods[i];
			dirs.push(value.modPath.split("./mods/")[1]);
			loadedMods.push(value);
		}
		framework ??= FLIXEL;

		Polymod.addDefaultImport(Assets);

		// Add import aliases for certain classes.
		// NOTE: Scripted classes are automatically aliased to their parent class.
		Polymod.addImportAlias('flixel.math.FlxPoint', flixel.math.FlxPoint.FlxBasePoint);

		// `lime.utils.Assets` literally just has a private `resolveClass` function for some reason? so we replace it with our own.
		Polymod.addImportAlias('lime.utils.Assets', Assets);
		Polymod.addImportAlias('openfl.utils.Assets', Assets);

		// Add blacklisting for prohibited classes and packages.

		// `Sys`
		// Sys.command() can run malicious processes
		Polymod.blacklistImport('Sys');

		// `Reflect`
		// Reflect.callMethod() can access blacklisted packages, but some functions are whitelisted
		Polymod.addImportAlias('Reflect', Reflect);

		Polymod.addImportAlias('CoolUtil', CoolUtil);

		Polymod.addImportAlias('BackgroundGirls', BackgroundGirls);
		Polymod.addImportAlias('PlayState', PlayState);

		// `Type`
		// Type.createInstance(Type.resolveClass()) can access blacklisted packages, but some functions are whitelisted
		Polymod.addImportAlias('Type', Type);

		// `cpp.Lib`
		// Lib.load() can load malicious DLLs
		Polymod.blacklistImport('cpp.Lib');

		// `Unserializer`
		// Unserializer.DEFAULT_RESOLVER.resolveClass() can access blacklisted packages
		Polymod.blacklistImport('Unserializer');

		// `lime.system.CFFI`
		// Can load and execute compiled binaries.
		Polymod.blacklistImport('lime.system.CFFI');

		// `lime.system.JNI`
		// Can load and execute compiled binaries.
		Polymod.blacklistImport('lime.system.JNI');

		// `lime.system.System`
		// System.load() can load malicious DLLs
		Polymod.blacklistImport('lime.system.System');

		// `lime.utils.Assets`
		// Literally just has a private `resolveClass` function for some reason?
		Polymod.blacklistImport('lime.utils.Assets');
		Polymod.blacklistImport('openfl.utils.Assets');
		Polymod.blacklistImport('openfl.Lib');
		Polymod.blacklistImport('openfl.system.ApplicationDomain');
		Polymod.blacklistImport('openfl.net.SharedObject');

		// `openfl.desktop.NativeProcess`
		// Can load native processes on the host operating system.
		Polymod.blacklistImport('openfl.desktop.NativeProcess');


		Polymod.init({
			framework: framework,
			modRoot: "./mods/",
			dirs: dirs,
			parseRules: buildParseRules(),
			errorCallback: function(err:PolymodError)
			{
				trace('[${err.severity}] ${err.message}');
			}
		});
		Polymod.registerAllScriptClasses();

		// forceReloadAssets();
		#end
	}

	public static function createModRoot():Void
	{
		if (!FileSystem.exists('./mods/'))
			FileSystem.createDirectory('./mods/');
	}

	static function buildParseRules():polymod.format.ParseRules
	{
		var output:polymod.format.ParseRules = polymod.format.ParseRules.getDefault();
		// Ensure TXT files have merge support.
		output.addType('txt', TextFileFormat.LINES);
		output.addType('json', TextFileFormat.JSON);
		// Ensure script files have merge support.
		output.addType('hscript', TextFileFormat.PLAINTEXT);
		output.addType('hxs', TextFileFormat.PLAINTEXT);
		output.addType('hxc', TextFileFormat.PLAINTEXT);
		output.addType('hx', TextFileFormat.PLAINTEXT);

		return output;
	}

	public static function forceReloadAssets():Void
	{
		// WeekData.reload();
		Polymod.clearScripts();

		Polymod.reload();
		Polymod.registerAllScriptClasses();
		// init(FLIXEL);
	}
}
