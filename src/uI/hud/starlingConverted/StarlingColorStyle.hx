package uI.hud.starlingConverted;

import starling.rendering.MeshEffect;
import starling.rendering.RenderState;
import starling.styles.MeshStyle;

class StarlingColorStyle extends MeshStyle {
	var mValues:Vector<Float> = Vector.ofArray(([1, 1, 1, 1, 0, 0, 0, 0] : Array<Float>));

	public function new() {
		super();
	}

	public function setTransform(red:Float, green:Float, blue:Float, offsetRed:Float, offsetGreen:Float, offsetBlue:Float) {
		mValues[0] = red;
		mValues[1] = green;
		mValues[2] = blue;
		mValues[4] = offsetRed / 255;
		mValues[5] = offsetGreen / 255;
		mValues[6] = offsetBlue / 255;
		setRequiresRedraw();
	}

	override public function copyFrom(style:MeshStyle) {
		var _loc2_ = 0;
		super.copyFrom(style);
		var _loc3_ = ASCompat.reinterpretAs(style, StarlingColorStyle);
		if (_loc3_ != null) {
			_loc2_ = 0;
			while (_loc2_ < mValues.length) {
				mValues[_loc2_] = _loc3_.mValues[_loc2_];
				_loc2_++;
			}
		}
	}

	override public function canBatchWith(style:MeshStyle):Bool {
		var _loc2_ = 0;
		if (!super.canBatchWith(style)) {
			return false;
		}
		var _loc3_ = ASCompat.reinterpretAs(style, StarlingColorStyle);
		_loc2_ = 0;
		while (_loc2_ < mValues.length) {
			if (mValues[_loc2_] != _loc3_.mValues[_loc2_]) {
				return false;
			}
			_loc2_++;
		}
		return true;
	}

	override public function createEffect():MeshEffect {
		return new StarlingColorEffect();
	}

	override public function updateEffect(effect:MeshEffect, state:RenderState) {
		super.updateEffect(effect, state);
		cast(effect, StarlingColorEffect).values = mValues;
	}
}
