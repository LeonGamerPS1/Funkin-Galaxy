package backend;

interface IStageState
{
	public var stages:Array<BaseStage>;

	public function addStage(stage:BaseStage):Void;
	public function forEachStage(func_:BaseStage->Void):Void;
}
