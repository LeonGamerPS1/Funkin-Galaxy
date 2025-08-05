package funkin.backend;

class Week
{
	@:unreflective // fuck you, reflection
	static var _cache:Map<String, WeekInfo> = [];

	public static function getWeek(file:String):WeekInfo
	{
		if (_cache.exists(file))
			return _cache[file];

		if (Paths.exists(Paths.getPath('weeks/$file.json')))
		{
			var week:WeekInfo = Json.parse(Paths.getText(Paths.getPath('weeks/$file.json')));
			_cache.set(file, week);
			return week;
		}

		return null;
	}
}
