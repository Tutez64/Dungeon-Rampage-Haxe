package settings.view;

import brain.logger.Logger;
import brain.uI.UIRadioButton;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import settings.model.SettingCategory;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.text.TextField;

class SettingsCategoryTabs {
	static inline final RADIO_GROUP = "SETTINGS_CATEGORY_TABS";

	static inline final PANEL_LABEL_NAME = "panel_label_one";

	static final PANEL_NAME_PATTERN:compat.RegExp = new compat.RegExp("^panel_\\d+$");

	static final STATE_PROPERTY_NAMES:Vector<String> = Vector.ofArray(["up", "over", "selected"]);

	var mDBFacade:DBFacade;

	var mButtons:Vector<UIRadioButton>;

	var mCategories:Vector<String>;

	var mSelectedCategory:String;

	var mSelectionCallback:ASFunction;

	public function new(dbFacade:DBFacade, popupClip:MovieClip, selectionCallback:ASFunction) {
		mDBFacade = dbFacade;
		mSelectionCallback = selectionCallback;
		mButtons = new Vector<UIRadioButton>();
		mCategories = new Vector<String>();
		buildButtons(popupClip);
	}

	static function findPanels(popupClip:MovieClip):Vector<MovieClip> {
		var _loc3_ = 0;
		var _loc4_:MovieClip = null;
		var _loc2_ = new Vector<MovieClip>();
		_loc3_ = 0;
		while (_loc3_ < popupClip.numChildren) {
			_loc4_ = ASCompat.reinterpretAs(popupClip.getChildAt(_loc3_), MovieClip);
			if (_loc4_ != null && PANEL_NAME_PATTERN.test(_loc4_.name)) {
				_loc2_.push(_loc4_);
			}
			_loc3_++;
		}
		ASCompat.ASVector.sort(_loc2_, compareTopToBottom);
		return _loc2_;
	}

	static function compareTopToBottom(a:DisplayObject, b:DisplayObject):Float {
		return a.y - b.y;
	}

	static function exposeStates(panel:MovieClip):Bool {
		var _loc3_ = 0;
		var _loc7_:DisplayObject = null;
		var _loc4_:MovieClip = null;
		var _loc6_ = new Vector<MovieClip>();
		var _loc5_ = new Vector<DisplayObject>();
		_loc3_ = 0;
		while (_loc3_ < panel.numChildren) {
			_loc7_ = panel.getChildAt(_loc3_);
			_loc4_ = ASCompat.reinterpretAs(_loc7_, MovieClip);
			if (_loc4_ != null && _loc4_.getChildByName("panel_label_one") != null) {
				_loc6_.push(_loc4_);
			} else {
				_loc5_.push(_loc7_);
			}
			_loc3_++;
		}
		if (_loc6_.length != STATE_PROPERTY_NAMES.length) {
			return false;
		}
		_loc3_ = 0;
		while (_loc3_ < _loc6_.length) {
			(panel : ASAny)[STATE_PROPERTY_NAMES[_loc3_]] = _loc6_[_loc3_];
			_loc3_++;
		}
		var _loc2_:DisplayObject;
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_) {
				_loc2_ = _tmp_;
				_loc2_.visible = false;
			}
		return true;
	}

	static function labelPanel(panel:MovieClip, text:String) {
		var _loc3_ = 0;
		var _loc4_:DisplayObjectContainer = null;
		var _loc5_ = setLabel(panel, text);
		_loc3_ = 0;
		while (_loc3_ < panel.numChildren) {
			_loc4_ = ASCompat.reinterpretAs(panel.getChildAt(_loc3_), DisplayObjectContainer);
			if (_loc4_ != null && setLabel(_loc4_, text)) {
				_loc5_ = true;
			}
			_loc3_++;
		}
		if (!_loc5_) {
			Logger.warn("Settings category panel has no label: " + panel.name);
		}
	}

	static function setLabel(container:DisplayObjectContainer, text:String):Bool {
		var _loc3_ = ASCompat.reinterpretAs(container.getChildByName("panel_label_one"), TextField);
		if (_loc3_ == null) {
			return false;
		}
		_loc3_.mouseEnabled = false;
		_loc3_.text = text;
		return true;
	}

	@:isVar public var selectedCategory(get, never):String;

	public function get_selectedCategory():String {
		return mSelectedCategory;
	}

	@:isVar public var buttons(get, never):Vector<UIRadioButton>;

	public function get_buttons():Vector<UIRadioButton> {
		return mButtons;
	}

	@:isVar public var selectedButton(get, never):UIRadioButton;

	public function get_selectedButton():UIRadioButton {
		var _loc1_ = mCategories.indexOf(mSelectedCategory);
		return _loc1_ != -1 ? mButtons[_loc1_] : (mButtons.length > 0 ? mButtons[0] : null);
	}

	public function select(category:String) {
		var _loc2_ = mCategories.indexOf(category);
		if (_loc2_ == -1) {
			return;
		}
		mSelectedCategory = category;
		mButtons[_loc2_].selected = true;
		if (mSelectionCallback != null) {
			mSelectionCallback(category);
		}
	}

	public function selectFirst() {
		if (mCategories.length > 0) {
			select(mCategories[0]);
		}
	}

	public function selectNext() {
		selectByOffset(1);
	}

	public function selectPrevious() {
		selectByOffset(-1);
	}

	function selectByOffset(offset:Int) {
		var _loc3_ = mCategories.length;
		if (_loc3_ == 0) {
			return;
		}
		var _loc4_ = mCategories.indexOf(mSelectedCategory);
		if (_loc4_ == -1) {
			select(mCategories[0]);
			return;
		}
		var _loc2_ = (_loc4_ + offset) % _loc3_;
		if (_loc2_ < 0) {
			_loc2_ += _loc3_;
		}
		select(mCategories[_loc2_]);
	}

	public function destroy() {
		var _loc1_:UIRadioButton;
		final __ax4_iter_414 = mButtons;
		if (checkNullIteratee(__ax4_iter_414))
			for (_tmp_ in __ax4_iter_414) {
				_loc1_ = _tmp_;
				_loc1_.destroy();
			}
		mButtons = null;
		mCategories = null;
		mSelectionCallback = null;
		mDBFacade = null;
	}

	function buildButtons(popupClip:MovieClip) {
		var _loc4_ = 0;
		var _loc5_:MovieClip = null;
		var _loc6_:String = null;
		var _loc2_:UIRadioButton = null;
		var _loc3_ = findPanels(popupClip);
		if (_loc3_.length < SettingCategory.ORDERED.length) {
			Logger.warn("Settings popup art has " + _loc3_.length + " category panels for " + SettingCategory.ORDERED.length + " categories");
		}
		_loc4_ = 0;
		while (_loc4_ < _loc3_.length) {
			_loc5_ = _loc3_[_loc4_];
			if (_loc4_ >= SettingCategory.ORDERED.length) {
				_loc5_.visible = false;
			} else {
				if (!exposeStates(_loc5_)) {
					Logger.warn("Settings category panel has no up/hover/selected states: " + _loc5_.name);
				}
				_loc6_ = SettingCategory.ORDERED[_loc4_];
				_loc2_ = new UIRadioButton(mDBFacade, _loc5_, "SETTINGS_CATEGORY_TABS");
				_loc2_.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
				_loc2_.releaseCallback = makeSelectionHandler(_loc6_);
				labelPanel(_loc5_, Locale.getString(SettingCategory.getLabelKey(_loc6_)));
				mButtons.push(_loc2_);
				mCategories.push(_loc6_);
			}
			_loc4_++;
		}
	}

	function makeSelectionHandler(category:String):ASFunction {
		return function() {
			select(category);
		};
	}
}
