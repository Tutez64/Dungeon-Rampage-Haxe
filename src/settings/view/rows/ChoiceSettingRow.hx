package settings.view.rows;

import brain.assetRepository.SwfAsset;
import brain.uI.UIButton;
import facade.DBFacade;
import facade.Locale;
import settings.model.SettingChoice;
import settings.model.SettingDefinition;
import settings.model.SettingsModel;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.text.TextField;

class ChoiceSettingRow extends SettingRow {
	public static inline final LINKAGE_NAME = "preset_option";

	static inline final NAME_LABEL_INSTANCE_NAME = "Name_Label";

	static inline final DOWN_ARROW_INSTANCE_NAME = "downarrow";

	static inline final UP_ARROW_INSTANCE_NAME = "uparrow";

	static inline final DEAD_ARROW_ALPHA:Float = 0.35;

	var mDownArrowClip:MovieClip;

	var mUpArrowClip:MovieClip;

	var mDownButton:UIButton;

	var mUpButton:UIButton;

	var mSelectableChoices:Vector<SettingChoice>;

	public function new(dbFacade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, rowIndex:Int) {
		super(dbFacade, swfAsset, "preset_option", definition, model, rowIndex);
	}

	static function compareTopToBottom(a:TextField, b:TextField):Float {
		return a.y - b.y;
	}

	static function setArrowLive(arrow:UIButton, live:Bool) {
		if (arrow == null || arrow.root == null) {
			return;
		}
		arrow.enabled = live;
		arrow.root.alpha = live ? 1 : 0.35;
	}

	static function swallowArrowClick(event:MouseEvent) {
		event.stopPropagation();
	}

	override function bindControls() {
		splitNameFromValue();
		mDownArrowClip = clipNamed("downarrow");
		if (mDownArrowClip != null) {
			mDownButton = new UIButton(mDBFacade, mDownArrowClip);
			mDownButton.releaseCallback = nudgeDown;
			mDownArrowClip.addEventListener("click", swallowArrowClick);
		}
		mUpArrowClip = clipNamed("uparrow");
		if (mUpArrowClip != null) {
			mUpButton = new UIButton(mDBFacade, mUpArrowClip);
			mUpButton.releaseCallback = nudgeUp;
			mUpArrowClip.addEventListener("click", swallowArrowClick);
		}
	}

	override public function refreshFromModel() {
		super.refreshFromModel();
		var _loc1_ = mDefinition.findChoice(mModel.getValue(mDefinition.id));
		var _loc2_ = mValueLabel ?? mNameLabel;
		if (_loc2_ != null && _loc1_ != null) {
			_loc2_.text = _loc1_.labelKey != null ? Locale.getString(_loc1_.labelKey) : ASCompat.toString(_loc1_.value);
		}
		updateArrowStates();
	}

	override function get_isActivatable():Bool {
		return true;
	}

	override function onRowActivated() {
		nudgeUp();
	}

	override public function nudgeDown() {
		cycle(-1);
	}

	override public function nudgeUp() {
		cycle(1);
	}

	override public function destroy() {
		if (mDownArrowClip != null) {
			mDownArrowClip.removeEventListener("click", swallowArrowClick);
			mDownArrowClip = null;
		}
		if (mUpArrowClip != null) {
			mUpArrowClip.removeEventListener("click", swallowArrowClick);
			mUpArrowClip = null;
		}
		if (mDownButton != null) {
			mDownButton.destroy();
			mDownButton = null;
		}
		if (mUpButton != null) {
			mUpButton.destroy();
			mUpButton = null;
		}
		mSelectableChoices = null;
		super.destroy();
	}

	function cycle(direction:Int) {
		var _loc3_ = selectableChoices;
		if (_loc3_.length == 0) {
			return;
		}
		var _loc2_ = indexOfCurrentChoice();
		var _loc4_ = _loc2_ < 0 ? (direction > 0 ? 0 : _loc3_.length - 1) : _loc2_ + direction;
		if (_loc4_ < 0 || _loc4_ >= _loc3_.length) {
			return;
		}
		mModel.setValue(mDefinition.id, _loc3_[_loc4_].value);
	}

	function splitNameFromValue() {
		var _loc2_ = 0;
		var _loc1_:TextField = null;
		if (mValueLabel != null) {
			return;
		}
		var _loc3_ = new Vector<TextField>();
		_loc2_ = 0;
		while (_loc2_ < mRoot.numChildren) {
			_loc1_ = ASCompat.reinterpretAs(mRoot.getChildAt(_loc2_), TextField);
			if (_loc1_ != null && _loc1_.name == "Name_Label") {
				_loc3_.push(_loc1_);
			}
			_loc2_++;
		}
		if (_loc3_.length < 2) {
			return;
		}
		ASCompat.ASVector.sort(_loc3_, compareTopToBottom);
		mNameLabel = _loc3_[0];
		mValueLabel = _loc3_[_loc3_.length - 1];
		mNameLabel.text = nameText();
	}

	function updateArrowStates() {
		var _loc4_ = selectableChoices;
		var _loc1_ = indexOfCurrentChoice();
		var _loc3_ = _loc4_.length == 0 || _loc1_ == 0;
		var _loc2_ = _loc4_.length == 0 || _loc1_ == _loc4_.length - 1;
		setArrowLive(mDownButton, !_loc3_);
		setArrowLive(mUpButton, !_loc2_);
	}

	@:isVar var selectableChoices(get, never):Vector<SettingChoice>;

	function get_selectableChoices():Vector<SettingChoice> {
		var _loc2_:SettingChoice;
		mSelectableChoices = new Vector<SettingChoice>();
		var _loc1_ = mDefinition.choices;
		if (_loc1_ != null) {
			if (checkNullIteratee(_loc1_))
				for (_tmp_ in _loc1_) {
					_loc2_ = _tmp_;
					if (!_loc2_.derived) {
						mSelectableChoices.push(_loc2_);
					}
				}
		}
		return mSelectableChoices;
	}

	function indexOfCurrentChoice():Int {
		var _loc2_ = 0;
		var _loc1_:ASAny = mModel.getValue(mDefinition.id);
		var _loc3_ = selectableChoices;
		_loc2_ = 0;
		while (_loc2_ < _loc3_.length) {
			if (_loc3_[_loc2_].value == _loc1_) {
				return _loc2_;
			}
			_loc2_++;
		}
		return -1;
	}
}
