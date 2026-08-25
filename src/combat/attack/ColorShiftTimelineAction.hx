package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.clock.GameClock;
import brain.workLoop.Task;
import facade.DBFacade;
import flash.geom.ColorTransform;
import flash.geom.Vector3D;

class ColorShiftTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "color";

	var mDuration:UInt = 0;

	var mColorMul:Vector3D;

	var mColorAdd:Vector3D;

	var mAlphaMul:Float = Math.NaN;

	var mAlphaAdd:Float = Math.NaN;

	var mOldColorTransform:ColorTransform;

	var mColorTransformTask:Task;

	var mFramesElapsed:Float = 0;

	var mOffsets:ColorTransform;

	var mTransitionDuration:Float = Math.NaN;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, duration:UInt, color_mul:Vector3D, color_add:Vector3D,
			filter_alpha:Float, add_alpha:Float, transitionDur:Float) {
		mDuration = duration;
		mColorMul = new Vector3D(color_mul.x, color_mul.y, color_mul.z);
		mColorAdd = new Vector3D(color_add.x, color_add.y, color_add.z);
		mAlphaMul = filter_alpha;
		mAlphaAdd = add_alpha;
		mTransitionDuration = transitionDur;
		super(actorGameObject, actorView, dbFacade);
		mOldColorTransform = new ColorTransform();
		mOffsets = new ColorTransform();
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject):ColorShiftTimelineAction {
		var _loc5_ = ASCompat.toNumber(actionObj.duration);
		var _loc10_ = new Vector3D(ASCompat.toNumberField(actionObj, "filter_r"), ASCompat.toNumberField(actionObj, "filter_g"),
			ASCompat.toNumberField(actionObj, "filter_b"));
		var _loc7_ = new Vector3D(ASCompat.toNumberField(actionObj, "add_r"), ASCompat.toNumberField(actionObj, "add_g"),
			ASCompat.toNumberField(actionObj, "add_b"));
		var _loc6_ = ASCompat.toNumber(actionObj.filter_alpha);
		var _loc9_ = ASCompat.toNumber(actionObj.add_alpha);
		var _loc8_ = ASCompat.toNumber(actionObj.transitionDur);
		return new ColorShiftTimelineAction(actorGameObject, actorView, dbFacade, (Std.int(_loc5_) : UInt), _loc10_, _loc7_, _loc6_, _loc9_, _loc8_);
	}

	function CopyColorTransform(color_src:ColorTransform):ColorTransform {
		var _loc2_ = new ColorTransform();
		_loc2_.alphaMultiplier = color_src.alphaMultiplier;
		_loc2_.alphaOffset = color_src.alphaOffset;
		_loc2_.blueMultiplier = color_src.blueMultiplier;
		_loc2_.blueOffset = color_src.blueOffset;
		_loc2_.redMultiplier = color_src.redMultiplier;
		_loc2_.redOffset = color_src.redOffset;
		_loc2_.greenMultiplier = color_src.greenMultiplier;
		_loc2_.greenOffset = color_src.greenOffset;
		return _loc2_;
	}

	function CalculateColorTransformOffsets(color_src:ColorTransform, color_target:ColorTransform, duration:Float) {
		mOffsets.alphaMultiplier = (color_target.alphaMultiplier - color_src.alphaMultiplier) / duration;
		mOffsets.alphaOffset = (color_target.alphaOffset - color_src.alphaOffset) / duration;
		mOffsets.blueMultiplier = (color_target.blueMultiplier - color_src.blueMultiplier) / duration;
		mOffsets.blueOffset = (color_target.blueOffset - color_src.blueOffset) / duration;
		mOffsets.redMultiplier = (color_target.redMultiplier - color_src.redMultiplier) / duration;
		mOffsets.redOffset = (color_target.redOffset - color_src.redOffset) / duration;
		mOffsets.greenMultiplier = (color_target.greenMultiplier - color_src.greenMultiplier) / duration;
		mOffsets.greenOffset = (color_target.greenOffset - color_src.greenOffset) / duration;
	}

	function AddColorTransformOffsets(scale:Float):ColorTransform {
		var _loc1_ = new ColorTransform();
		var _loc2_ = mActorView.body.transform.colorTransform;
		_loc1_.alphaMultiplier = _loc2_.alphaMultiplier + mOffsets.alphaMultiplier * scale;
		_loc1_.alphaOffset = _loc2_.alphaOffset + mOffsets.alphaOffset * scale;
		_loc1_.blueMultiplier = _loc2_.blueMultiplier + mOffsets.blueMultiplier * scale;
		_loc1_.blueOffset = _loc2_.blueOffset + mOffsets.blueOffset * scale;
		_loc1_.redMultiplier = _loc2_.redMultiplier + mOffsets.redMultiplier * scale;
		_loc1_.redOffset = _loc2_.redOffset + mOffsets.redOffset * scale;
		_loc1_.greenMultiplier = _loc2_.greenMultiplier + mOffsets.greenMultiplier * scale;
		_loc1_.greenOffset = _loc2_.greenOffset + mOffsets.greenOffset * scale;
		return _loc1_;
	}

	function SubtractColorTransformOffsets(scale:Float):ColorTransform {
		var _loc1_ = new ColorTransform();
		var _loc2_ = mActorView.body.transform.colorTransform;
		_loc1_.alphaMultiplier = _loc2_.alphaMultiplier - mOffsets.alphaMultiplier * scale;
		_loc1_.alphaOffset = _loc2_.alphaOffset - mOffsets.alphaOffset * scale;
		_loc1_.blueMultiplier = _loc2_.blueMultiplier - mOffsets.blueMultiplier * scale;
		_loc1_.blueOffset = _loc2_.blueOffset - mOffsets.blueOffset * scale;
		_loc1_.redMultiplier = _loc2_.redMultiplier - mOffsets.redMultiplier * scale;
		_loc1_.redOffset = _loc2_.redOffset - mOffsets.redOffset * scale;
		_loc1_.greenMultiplier = _loc2_.greenMultiplier - mOffsets.greenMultiplier * scale;
		_loc1_.greenOffset = _loc2_.greenOffset - mOffsets.greenOffset * scale;
		return _loc1_;
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		if (mFramesElapsed != 0) {
			ResetColorTransform();
		}
		mFramesElapsed = 0;
		mOldColorTransform = CopyColorTransform(new ColorTransform());
		var _loc2_ = new ColorTransform(mColorMul.x, mColorMul.y, mColorMul.z, mAlphaMul, mColorAdd.x, mColorAdd.y, mColorAdd.z, mAlphaAdd);
		CalculateColorTransformOffsets(mOldColorTransform, _loc2_, mTransitionDuration);
		if (mColorTransformTask != null) {
			mColorTransformTask.destroy();
			mColorTransformTask = null;
		}
		if (mWorkComponent != null) {
			mColorTransformTask = mWorkComponent.doEveryFrame(UpdateColorShift);
		}
	}

	public function UpdateColorShift(clock:GameClock) {
		if (mActorView != null && mActorView.body != null) {
			var _loc1_ = clock.tickLength / GameClock.ANIMATION_FRAME_DURATION;
			mFramesElapsed += _loc1_;
			if (mFramesElapsed <= mTransitionDuration) {
				mActorView.body.transform.colorTransform = AddColorTransformOffsets(_loc1_);
			} else if (mFramesElapsed >= mDuration - mTransitionDuration) {
				mActorView.body.transform.colorTransform = SubtractColorTransformOffsets(_loc1_);
			}
			if (mFramesElapsed > mDuration) {
				ResetColorTransform();
				return;
			}
			return;
		}
		ResetColorTransform();
	}

	function ResetColorTransform() {
		mFramesElapsed = 0;
		if (mActorView != null && mActorView.body != null) {
			mActorView.body.transform.colorTransform = CopyColorTransform(mOldColorTransform);
		}
		if (mColorTransformTask != null) {
			mColorTransformTask.destroy();
			mColorTransformTask = null;
		}
	}

	override public function destroy() {
		if (mColorTransformTask != null) {
			mColorTransformTask.destroy();
			mColorTransformTask = null;
		}
		super.destroy();
	}
}
