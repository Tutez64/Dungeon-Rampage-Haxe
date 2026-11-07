package settings.view.rows;

import brain.assetRepository.SwfAsset;
import brain.uI.UIButton;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import input.keyBindings.KeyBindings;
import input.keyBindings.KeyNames;
import settings.model.KeyBindingValue;
import settings.model.SettingDefinition;
import settings.model.SettingsModel;
import flash.display.MovieClip;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.text.TextField;

class KeyBindingSettingRow extends SettingRow {
	public static inline final LINKAGE_NAME = "multiple_input_option";

	static inline final PRIMARY_BUTTON_INSTANCE_NAME = "primary_button";

	static inline final ALTERNATE_BUTTON_INSTANCE_NAME = "alternative_button";

	static inline final RESET_BUTTON_INSTANCE_NAME = "reset_button";

	static inline final PRIMARY_CAPTION_INSTANCE_NAME = "Primary_Label";

	static inline final ALTERNATE_CAPTION_INSTANCE_NAME = "Alternate_Label";

	static inline final RESET_CAPTION_INSTANCE_NAME = "Reset_Label";

	static inline final CAPTURE_PROMPT_INSTANCE_NAME = "key_label";

	static inline final CAPTURE_LISTENER_PRIORITY = 1000;

	var mPrimaryButton:UIButton;

	var mAlternateButton:UIButton;

	var mResetButton:UIButton;

	var mResetCaption:TextField;

	var mCapturePrompt:TextField;

	var mButtonClips:Vector<MovieClip>;

	var mCapturingSlot:String;

	var mInputsWereDisabled:Bool = false;

	public function new(dbFacade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, rowIndex:Int) {
		super(dbFacade, swfAsset, "multiple_input_option", definition, model, rowIndex);
	}

	static function swallowButtonClick(event:MouseEvent) {
		event.stopPropagation();
	}

	override function bindControls() {
		mButtonClips = new Vector<MovieClip>();
		mPrimaryButton = makeButton("primary_button", capturePrimary);
		mAlternateButton = makeButton("alternative_button", captureAlternate);
		mResetButton = makeButton("reset_button", resetToDefault);
		setCaption("Primary_Label", "SETTINGS_KEY_PRIMARY");
		setCaption("Alternate_Label", "SETTINGS_KEY_ALTERNATE");
		mResetCaption = setCaption("Reset_Label", "SETTINGS_KEY_RESET");
		mCapturePrompt = setCaption("key_label", "SETTINGS_KEY_PRESS_ANY");
	}

	override public function refreshFromModel() {
		super.refreshFromModel();
		var _loc2_:ASObject = mModel.getValue(mDefinition.id);
		setButtonText(mPrimaryButton, "primary", KeyBindingValue.primary(_loc2_));
		setButtonText(mAlternateButton, "alternate", KeyBindingValue.alternate(_loc2_));
		var _loc1_ = KeyBindingValue.equals(_loc2_, mDefinition.defaultValue);
		if (mResetButton != null) {
			mResetButton.visible = !_loc1_;
		}
		if (mResetCaption != null) {
			mResetCaption.visible = !_loc1_;
		}
		if (mCapturePrompt != null) {
			mCapturePrompt.visible = mCapturingSlot != null;
		}
	}

	override public function onSelected(fromController:Bool = false) {
		capturePrimary();
	}

	override public function destroy() {
		var _loc1_:MovieClip;
		var __ax4_iter_330:Vector<MovieClip>;
		endCapture();
		if (mButtonClips != null) {
			__ax4_iter_330 = mButtonClips;
			if (checkNullIteratee(__ax4_iter_330))
				for (_tmp_ in __ax4_iter_330) {
					_loc1_ = _tmp_;
					_loc1_.removeEventListener("click", swallowButtonClick);
				}
			mButtonClips = null;
		}
		if (mPrimaryButton != null) {
			mPrimaryButton.destroy();
			mPrimaryButton = null;
		}
		if (mAlternateButton != null) {
			mAlternateButton.destroy();
			mAlternateButton = null;
		}
		if (mResetButton != null) {
			mResetButton.destroy();
			mResetButton = null;
		}
		mResetCaption = null;
		mCapturePrompt = null;
		super.destroy();
	}

	function makeButton(instanceName:String, onRelease:ASFunction):UIButton {
		var _loc4_ = clipNamed(instanceName);
		if (_loc4_ == null) {
			return null;
		}
		var _loc3_ = new UIButton(mDBFacade, _loc4_);
		_loc3_.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		_loc3_.selectedFilter = DBGlobal.UI_SELECTED_FILTER;
		_loc3_.releaseCallback = onRelease;
		_loc4_.addEventListener("click", swallowButtonClick);
		mButtonClips.push(_loc4_);
		return _loc3_;
	}

	function setCaption(instanceName:String, localeKey:String):TextField {
		var _loc3_ = fieldNamed(instanceName);
		if (_loc3_ == null) {
			return null;
		}
		_loc3_.text = Locale.getString(localeKey);
		_loc3_.mouseEnabled = false;
		return _loc3_;
	}

	function setButtonText(button:UIButton, slotName:String, keyCode:Int) {
		if (button == null) {
			return;
		}
		var _loc4_ = mCapturingSlot == slotName;
		button.selected = _loc4_;
		if (button.label == null) {
			return;
		}
		if (_loc4_ && mCapturePrompt == null) {
			button.label.text = Locale.getString("SETTINGS_KEY_PRESS_ANY");
			return;
		}
		var _loc5_ = KeyNames.displayName(keyCode);
		button.label.text = _loc5_.length > 0 ? _loc5_ : Locale.getString("SETTINGS_KEY_UNBOUND");
	}

	function capturePrimary() {
		beginCapture("primary");
	}

	function captureAlternate() {
		beginCapture("alternate");
	}

	function resetToDefault() {
		endCapture();
		mModel.resetKeyBinding(mDefinition.id);
	}

	function beginCapture(slotName:String) {
		if (mCapturingSlot != null) {
			return;
		}
		mCapturingSlot = slotName;
		mInputsWereDisabled = mDBFacade.inputManager.disableInputs;
		if (!mInputsWereDisabled) {
			mDBFacade.inputManager.disableControls();
		}
		mDBFacade.stageRef.addEventListener("keyDown", onCaptureKeyDown, false, 1000);
		mDBFacade.stageRef.addEventListener("mouseDown", onCaptureMouseDown, true, 1000);
		mDBFacade.stageRef.addEventListener("mouseDown", onCaptureMouseDown, false, 1000);
		refreshFromModel();
	}

	function endCapture() {
		if (mCapturingSlot == null) {
			return;
		}
		mCapturingSlot = null;
		if (mDBFacade != null) {
			mDBFacade.stageRef.removeEventListener("keyDown", onCaptureKeyDown);
			mDBFacade.stageRef.removeEventListener("mouseDown", onCaptureMouseDown, true);
			mDBFacade.stageRef.removeEventListener("mouseDown", onCaptureMouseDown);
			if (!mInputsWereDisabled) {
				mDBFacade.inputManager.enableControls();
			}
		}
		if (mModel != null && mRoot != null) {
			refreshFromModel();
		}
	}

	function onCaptureKeyDown(event:KeyboardEvent) {
		event.stopImmediatePropagation();
		event.preventDefault();
		var _loc3_:Int = event.keyCode;
		if (_loc3_ == 27) {
			endCapture();
			return;
		}
		if (!KeyBindings.isBindable(_loc3_)) {
			return;
		}
		var _loc2_ = mCapturingSlot;
		endCapture();
		mModel.assignKey(mDefinition.id, _loc2_, _loc3_);
	}

	function onCaptureMouseDown(event:MouseEvent) {
		endCapture();
	}
}
