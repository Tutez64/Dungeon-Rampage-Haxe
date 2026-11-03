package settings.view.rows;

import brain.assetRepository.SwfAsset;
import brain.uI.UIButton;
import brain.uI.UISlider;
import facade.DBFacade;
import settings.model.SettingDefinition;
import settings.model.SettingsModel;

class SliderSettingRow extends SettingRow {
	public static inline final LINKAGE_NAME = "slider_option";

	static inline final STEP_PRECISION_DIGITS = 6;

	var mSlider:UISlider;

	var mLeftButton:UIButton;

	var mRightButton:UIButton;

	public function new(dbFacade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, rowIndex:Int) {
		super(dbFacade, swfAsset, "slider_option", definition, model, rowIndex);
	}

	override function bindControls() {
		var _loc2_ = clipNamed("slider");
		if (_loc2_ != null) {
			mSlider = new UISlider(mDBFacade, _loc2_, (0 : UInt));
			mSlider.minimum = mDefinition.minimum;
			mSlider.maximum = mDefinition.maximum;
			mSlider.tick = mDefinition.step;
			mSlider.value = mModel.getNumber(mDefinition.id);
			mSlider.updateCallback = onSliderMoved;
		}
		var _loc1_ = clipNamed("leftarrow");
		if (_loc1_ != null) {
			mLeftButton = new UIButton(mDBFacade, _loc1_);
			mLeftButton.releaseCallback = nudgeDown;
		}
		var _loc3_ = clipNamed("rightarrow");
		if (_loc3_ != null) {
			mRightButton = new UIButton(mDBFacade, _loc3_);
			mRightButton.releaseCallback = nudgeUp;
		}
	}

	override public function refreshFromModel() {
		super.refreshFromModel();
		var _loc1_ = mModel.getNumber(mDefinition.id);
		if (mSlider != null) {
			mSlider.value = _loc1_;
		}
		if (mValueLabel != null) {
			mValueLabel.text = formatValue(_loc1_);
		}
	}

	override public function nudgeDown() {
		step(-mDefinition.step);
	}

	override public function nudgeUp() {
		step(mDefinition.step);
	}

	override public function destroy() {
		if (mSlider != null) {
			mSlider.destroy();
			mSlider = null;
		}
		if (mLeftButton != null) {
			mLeftButton.destroy();
			mLeftButton = null;
		}
		if (mRightButton != null) {
			mRightButton.destroy();
			mRightButton = null;
		}
		super.destroy();
	}

	function step(delta:Float) {
		var _loc2_ = mModel.getNumber(mDefinition.id) + delta;
		_loc2_ = Math.max(mDefinition.minimum, Math.min(mDefinition.maximum, _loc2_));
		mModel.setValue(mDefinition.id, roundToStep(_loc2_));
	}

	function onSliderMoved(value:Float) {
		mModel.setValue(mDefinition.id, roundToStep(value));
	}

	function roundToStep(value:Float):Float {
		if (mDefinition.step <= 0) {
			return value;
		}
		var _loc2_ = Math.fround(value / mDefinition.step) * mDefinition.step;
		return ASCompat.toNumber(ASCompat.toFixed(_loc2_, (6 : UInt)));
	}

	function formatValue(value:Float):String {
		var _loc2_ = value * mDefinition.displayScale;
		if (mDefinition.decimals > 0) {
			return ASCompat.toFixed(_loc2_, (mDefinition.decimals : UInt));
		}
		return Std.string(Math.fround(_loc2_));
	}
}
