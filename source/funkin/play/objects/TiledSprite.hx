package funkin.play.objects;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;

using flixel.util.FlxColorTransformUtil;

/*
 * something something made by nickngc
 */
class TiledSprite extends FlxSprite
{
	public var tailAnimName:String;

	var _tailFrame:FlxFrame;
	var tiles:Float;
	var tileCount:Int;

	override public function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{
		return super.getScreenBounds(newRect, camera).setSize(frameWidth * Math.abs(scale.x), height);
	}

	public function setTail(name:String):Void
	{
		tailAnimName = name;
		updateTail();
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// TODO: maybe add controls for the tail's animation? not sure
		if (_tailFrame != null)
		{
			updateTail();
		}
	}

	function updateTail():Void
	{
		if (animation.getByName(tailAnimName) == null)
			return;

		_tailFrame = frames.frames[animation.getByName(tailAnimName).frames[animation.curAnim.curFrame]].copyTo(_tailFrame);
		_tailFrame.sourceSize.y -= 2;
		_tailFrame.frame.height -= 2;
		_tailFrame.frame.y += 2;
	}

	override function drawComplex(camera:FlxCamera):Void
	{
		if (frames == null || tiles <= 0 || !dirty)
			return;

		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
			{
				_matrix.rotateWithTrig(_cosAngle, _sinAngle);
			}
		}

		getScreenPosition(_point, camera).subtract(offset.x, offset.y).add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

		// this is where the actual rendering begins
		final batch:FlxDrawQuadsItem = camera.startQuadBatch(_frame.parent, colorTransform?.hasRGBMultipliers(), colorTransform?.hasRGBAOffsets(), blend,
			antialiasing, shader);

		final bodyIndex:Int = flipY ? tileCount - 1 : 0;
		final tailIndex:Int = flipY ? 0 : tileCount - 1;
		final absScaleY:Float = Math.abs(scale.y);

		for (i in 0...tileCount)
		{
			final frameToDraw:FlxFrame = i == tailIndex ? _tailFrame ?? _frame : _frame;
			var offsetAmount:Float = (flipY ? _frame.frame.height : frameToDraw.frame.height) * absScaleY;

			if (i == bodyIndex && tiles < tileCount)
			{
				final originalY:Float = frameToDraw.frame.y;
				final originalHeight:Float = frameToDraw.frame.height;
				final clipReduction:Float = originalHeight * (tileCount - tiles);

				// apply clipping
				frameToDraw.frame.height -= clipReduction;
				frameToDraw.frame.y += clipReduction;

				if (flipY)
				{
					final clipOffset:Float = clipReduction * absScaleY;
					_matrix.translate(clipOffset * _sinAngle, -clipOffset * _cosAngle);
				}

				batch.addQuad(frameToDraw, _matrix, colorTransform);

				offsetAmount = frameToDraw.frame.height * absScaleY;

				// undo clipping right after rendering the clipped frame because otherwise weird shit happens????
				frameToDraw.frame.y = originalY;
				frameToDraw.frame.height = originalHeight;
			}
			else
			{
				batch.addQuad(frameToDraw, _matrix, colorTransform);
			}

			_matrix.translate(-offsetAmount * _sinAngle, offsetAmount * _cosAngle);
		}
	}

	override function set_frame(v:FlxFrame):FlxFrame
	{
		super.set_frame(v);
		if (_frame != null)
		{ // frame gap fix by RapperGF
			_frame.sourceSize.y -= 2;
			_frame.frame.height -= 2;
			_frame.frame.y += 1;
		}
		return v;
	}

	override function set_height(v:Float):Float
	{
		if (height == v || frames == null)
			return v;

		final absScaleY:Float = Math.abs(scale.y);
		final tailHeight:Float = (_tailFrame?.frame.height ?? _frame.frame.height) * absScaleY;

		tileCount = Math.ceil(tiles = v <= tailHeight ? v / tailHeight : (v - tailHeight) / (_frame.frame.height * absScaleY) + 1);

		return super.set_height(v);
	}

	override function destroy():Void
	{
		_tailFrame = FlxDestroyUtil.destroy(_tailFrame);
		super.destroy();
	}
}
