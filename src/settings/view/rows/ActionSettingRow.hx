package settings.view.rows;

import brain.assetRepository.SwfAsset;
import brain.uI.UIButton;
import facade.DBFacade;
import facade.Locale;
import settings.model.SettingDefinition;
import settings.model.SettingsModel;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormat;

class ActionSettingRow extends SettingRow {
	public static inline final LINKAGE_NAME = "boolean_option";

	static inline final BUTTON_INSTANCE_NAME = "boolean_button";

	static inline final BUTTON_WIDTH_MULTIPLIER:Float = 1.2;

	static inline final BUTTON_HEIGHT_MULTIPLIER:Float = 1.7;

	static inline final BUTTON_FONT_SIZE = 30;

	var mStateButton:UIButton;

	var mSwfAsset:SwfAsset;

	var mButtonClip:MovieClip;

	public function new(dbFacade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, rowIndex:Int) {
		super(dbFacade, swfAsset, "boolean_option", definition, model, rowIndex);
		mSwfAsset = swfAsset;
	}

	static function swallowButtonClick(event:MouseEvent) {
		event.stopPropagation();
	}

	override function bindControls() {
		var _loc14_:MovieClip = null;
		var _loc2_:TextFormat = null;
		mButtonClip = clipNamed("boolean_button");
		if (mButtonClip == null) {
			return;
		}
		var _loc10_ = mButtonClip.getBounds(mRoot);
		var _loc3_ = ASCompat.reinterpretAs(mButtonClip.getChildByName("up"), MovieClip);
		var _loc8_ = _loc3_ != null ? _loc3_.getBounds(mRoot) : _loc10_;
		var _loc12_ = mRoot.getBounds(mRoot);
		mButtonClip.visible = false;
		var _loc7_ = mSwfAsset.getClass("multiple_input_option");
		if (_loc7_ == null) {
			return;
		}
		var _loc4_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc7_, []), MovieClip);
		_loc4_.stop();
		mButtonClip = ASCompat.reinterpretAs(_loc4_.getChildByName("primary_button"), MovieClip);
		if (mButtonClip == null) {
			return;
		}
		_loc4_.removeChild(mButtonClip);
		mRoot.addChild(mButtonClip);
		mButtonClip.scaleX = mButtonClip.scaleY = 1;
		var _loc1_ = mButtonClip.getBounds(mButtonClip);
		var _loc13_ = _loc1_.x + _loc1_.width / 2;
		var _loc11_ = _loc1_.y + _loc1_.height / 2;
		var _loc15_ = _loc10_.width * 1.2;
		var _loc6_ = _loc15_ / _loc1_.width;
		var _loc9_:String;
		final __ax4_iter_332:Array<ASAny> = ["up", "over", "down", "disabled", "selected", "hit"];
		if (checkNullIteratee(__ax4_iter_332))
			for (_tmp_ in __ax4_iter_332) {
				_loc9_ = _tmp_;
				_loc14_ = ASCompat.reinterpretAs(mButtonClip.getChildByName(_loc9_), MovieClip);
				if (_loc14_ != null) {
					_loc14_.x = _loc13_ + (_loc14_.x - _loc13_) * _loc6_;
					_loc14_.y = _loc11_ + (_loc14_.y - _loc11_) * 1.7;
					_loc14_.scaleX *= _loc6_;
					_loc14_.scaleY *= 1.7;
				}
			}
		var _loc5_ = ASCompat.reinterpretAs(mButtonClip.getChildByName("label"), TextField);
		if (_loc5_ != null) {
			_loc5_.width = Math.max(1, _loc15_ - 8);
			_loc5_.x = _loc13_ - _loc5_.width / 2;
			_loc2_ = _loc5_.defaultTextFormat;
			_loc2_.align = "center";
			_loc2_.size = 30;
			_loc5_.defaultTextFormat = _loc2_;
			_loc5_.text = Locale.getString("SETTINGS_ACTION_OPEN");
			_loc5_.setTextFormat(_loc2_);
			_loc5_.height = _loc5_.textHeight + 8;
			_loc5_.y = _loc11_ - _loc5_.height / 2;
		}
		mButtonClip.x = _loc8_.x + _loc8_.width / 2 - _loc13_;
		mButtonClip.y = _loc12_.y + _loc12_.height / 2 - _loc11_;
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
			mStateButton.selected = false;
			if (mStateButton.label != null) {
				mStateButton.label.text = Locale.getString("SETTINGS_ACTION_OPEN");
			}
		}
	}

	override function get_isActivatable():Bool {
		return true;
	}

	override function onRowActivated() {
		toggle();
	}

	override public function nudgeDown() {}

	override public function nudgeUp() {}

	override public function destroy() {
		if (mButtonClip != null) {
			mButtonClip.removeEventListener("click", swallowButtonClick);
			mButtonClip = null;
		}
		if (mStateButton != null) {
			mStateButton.destroy();
			mStateButton = null;
		}
		mSwfAsset = null;
		super.destroy();
	}

	function toggle() {
		if (mDefinition.action != null) {
			mDefinition.action();
		}
	}

	function stateWord():String {
		return Locale.getString("SETTINGS_ACTION_OPEN");
	}
}
