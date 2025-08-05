package funkin.play.song.stages;

class Week1 extends BaseStage
{
	public override function create()
	{
		trace("big balls");
		var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		add(bg);

		var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
		stageFront.scale.set(1.1, 1.1);
		stageFront.updateHitbox();
		add(stageFront);

		var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
		stageLight.scale.set(1.1, 1.1);
		stageLight.updateHitbox();
		add(stageLight);
		var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
		stageLight.scale.set(1.1, 1.1);
		stageLight.updateHitbox();
		stageLight.flipX = true;
		add(stageLight);

		var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
		stageCurtains.scale.set(0.9, 0.9);
		stageCurtains.updateHitbox();
		add(stageCurtains);
	}
}
