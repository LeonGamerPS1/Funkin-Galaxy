class Mac
{
	public static macro function listClassesInPackage(targetPackage:String, includeSubPackages:Bool = true):ExprOf<Iterable<Class<Dynamic>>>
	{
		if (!onGenerateCallbackRegistered)
		{
			onGenerateCallbackRegistered = true;
			Context.onGenerate(onGenerate);
		}

		var request:String = 'package~${targetPackage}~${includeSubPackages ? "recursive" : "nonrecursive"}';

		classListsToGenerate.push(request);

		return macro funkin.util.macro.CompiledClassList.get($v{request});
	}
}
