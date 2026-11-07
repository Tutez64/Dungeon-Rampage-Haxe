package settings.view.rows;

import brain.assetRepository.SwfAsset;
import brain.uI.UIButton;
import facade.DBFacade;
import facade.Locale;
import settings.model.SettingDefinition;
import settings.model.SettingsModel;
import flash.display.MovieClip;
import flash.events.MouseEvent;

class BooleanSettingRow extends SettingRow {
	public static inline final LINKAGE_NAME = "boolean_option";

	static inline final BUTTON_INSTANCE_NAME = "boolean_button";

	var mStateButton:UIButton;

	var mButtonClip:MovieClip;

	public function new(dbFacade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, rowIndex:Int) {
		super(dbFacade, swfAsset, "boolean_option", definition, model, rowIndex);
	}

	static function swallowButtonClick(event:MouseEvent) {
		event.stopPropagation();
	}

	override function bindControls() {
		mButtonClip = clipNamed("boolean_button");
		if (mButtonClip == null) {
			return;
		}
		mStateButton = new UIButton(mDBFacade, mButtonClip);
		mStateButton.releaseCallback = toggle;
		mButtonClip.addEventListener("click", swallowButtonClick);
	}

	override public function refreshFromModel() {
		super.refreshFromModel();
		if (mValueLabel != null) {
			mValueLabel.text = stateWord();
		}
		if (mStateButton != null) {
			mStateButton.selected = mModel.getBoolean(mDefinition.id);
		}
	}

	override function updateDescription() {
		super.updateDescription();
		if (mDescriptionLabel == null || mValueLabel != null || mStateButton != null) {
			return;
		}
		var _loc1_ = mDescriptionLabel.text;
		mDescriptionLabel.text = _loc1_.length > 0 ? stateWord() + "   " + _loc1_ : stateWord();
	}

	override function get_isActivatable():Bool {
		return true;
	}

	override function onRowActivated() {
		toggle();
	}

	override public function nudgeDown() {
		mModel.setValue(mDefinition.id, false);
	}

	override public function nudgeUp() {
		mModel.setValue(mDefinition.id, true);
	}

	override public function destroy() {
		if (mButtonClip != null) {
			mButtonClip.removeEventListener("click", swallowButtonClick);
			mButtonClip = null;
		}
		if (mStateButton != null) {
			mStateButton.destroy();
			mStateButton = null;
		}
		super.destroy();
	}

	function toggle() {
		mModel.setValue(mDefinition.id, !mModel.getBoolean(mDefinition.id));
	}

	function stateWord():String {
		return Locale.getString(mModel.getBoolean(mDefinition.id) ? "SETTINGS_ON" : "SETTINGS_OFF");
	}
}
