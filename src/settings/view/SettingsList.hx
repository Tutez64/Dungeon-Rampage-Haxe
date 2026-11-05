package settings.view;

import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.uI.UIScrollPane;
import brain.uI.UISlider;
import facade.DBFacade;
import settings.model.SettingDefinition;
import settings.model.SettingsModel;
import settings.view.rows.BooleanSettingRow;
import settings.view.rows.ChoiceSettingRow;
import settings.view.rows.KeyBindingSettingRow;
import settings.view.rows.SettingRow;
import settings.view.rows.SliderSettingRow;
import flash.display.MovieClip;
import flash.events.MouseEvent;

class SettingsList {
	static inline final SCROLL_STEP:Float = 50;

	static inline final ROW_PADDING:Float = 4;

	var mDBFacade:DBFacade;

	var mSwfAsset:SwfAsset;

	var mModel:SettingsModel;

	var mPopupClip:MovieClip;

	var mScrollPane:UIScrollPane;

	var mScrollSlider:UISlider;

	var mScrollUpButton:UIButton;

	var mScrollDownButton:UIButton;

	var mRows:Vector<SettingRow>;

	var mContentHeight:Float = 0;

	var mViewportHeight:Float = 0;

	var mScrollable:Bool = false;

	public function new(dbFacade:DBFacade, popupClip:MovieClip, swfAsset:SwfAsset, model:SettingsModel) {
		mDBFacade = dbFacade;
		mPopupClip = popupClip;
		mSwfAsset = swfAsset;
		mModel = model;
		mRows = new Vector<SettingRow>();
		buildScrollControls();
		mModel.addChangeListener(onSettingChanged);
	}

	@:isVar public var rows(get, never):Vector<SettingRow>;

	public function get_rows():Vector<SettingRow> {
		return mRows;
	}

	@:isVar public var firstRow(get, never):SettingRow;

	public function get_firstRow():SettingRow {
		return ASCompat.coerce(mRows.length > 0 ? mRows[0] : null, settings.view.rows.SettingRow);
	}

	@:isVar public var lastRow(get, never):SettingRow;

	public function get_lastRow():SettingRow {
		return ASCompat.coerce(mRows.length > 0 ? mRows[mRows.length - 1] : null, settings.view.rows.SettingRow);
	}

	public function showCategory(category:String) {
		var _loc2_ = 0;
		var _loc3_:SettingRow = null;
		destroyRows();
		if (mScrollPane == null) {
			return;
		}
		var _loc4_ = mModel.catalog.getDefinitionsForCategory(category);
		var _loc5_:Float = 0;
		_loc2_ = 0;
		while (_loc2_ < _loc4_.length) {
			_loc3_ = createRow(_loc4_[_loc2_], _loc2_);
			_loc3_.build();
			_loc3_.root.y = _loc5_;
			_loc3_.focusedCallback = scrollRowIntoView;
			mScrollPane.root.addChild(_loc3_.root);
			mRows.push(_loc3_);
			_loc5_ += _loc3_.height + 4;
			_loc2_++;
		}
		mContentHeight = _loc5_;
		linkRowNavigation();
		updateScrollRange();
	}

	public function scrollRowIntoView(row:SettingRow) {
		if (mScrollPane == null || row.root == null) {
			return;
		}
		var _loc2_ = mScrollPane.root.scrollRect.y;
		var _loc4_ = row.root.y;
		var _loc3_ = _loc4_ + row.height;
		var _loc5_ = _loc2_;
		if (_loc4_ < _loc2_) {
			_loc5_ = _loc4_;
		} else if (_loc3_ > _loc2_ + mViewportHeight) {
			_loc5_ = _loc3_ - mViewportHeight;
		}
		if (_loc5_ == _loc2_) {
			return;
		}
		if (mScrollable && mScrollSlider != null) {
			mScrollSlider.valueWithCallback = _loc5_;
		} else {
			mScrollPane.scrollToY(_loc5_);
		}
	}

	public function destroy() {
		mModel.removeChangeListener(onSettingChanged);
		destroyRows();
		if (mPopupClip != null) {
			mPopupClip.removeEventListener("mouseWheel", onMouseWheel);
		}
		if (mScrollUpButton != null) {
			mScrollUpButton.destroy();
			mScrollUpButton = null;
		}
		if (mScrollDownButton != null) {
			mScrollDownButton.destroy();
			mScrollDownButton = null;
		}
		if (mScrollSlider != null) {
			mScrollSlider.destroy();
			mScrollSlider = null;
		}
		if (mScrollPane != null) {
			mScrollPane.destroy();
			mScrollPane = null;
		}
		mRows = null;
		mModel = null;
		mSwfAsset = null;
		mPopupClip = null;
		mDBFacade = null;
	}

	function buildScrollControls() {
		if (!(mPopupClip : ASAny).hasOwnProperty("panel_two_scroll_panel")) {
			Logger.warn("Settings popup art has no scroll panel");
			return;
		}
		mScrollPane = new UIScrollPane(mDBFacade, ASCompat.coerce((mPopupClip : ASAny).panel_two_scroll_panel, flash.display.MovieClip));
		mViewportHeight = mScrollPane.root.scrollRect.height;
		if ((mPopupClip : ASAny).hasOwnProperty("slider")) {
			mScrollSlider = new UISlider(mDBFacade, ASCompat.coerce((mPopupClip : ASAny).slider, flash.display.MovieClip), (1 : UInt));
			mScrollSlider.updateCallback = mScrollPane.scrollToY;
		}
		mPopupClip.addEventListener("mouseWheel", onMouseWheel);
		if ((mPopupClip : ASAny).hasOwnProperty("uparrow")) {
			mScrollUpButton = new UIButton(mDBFacade, ASCompat.coerce((mPopupClip : ASAny).uparrow, flash.display.MovieClip));
			mScrollUpButton.releaseCallback = scrollUp;
		}
		if ((mPopupClip : ASAny).hasOwnProperty("downarrow")) {
			mScrollDownButton = new UIButton(mDBFacade, ASCompat.coerce((mPopupClip : ASAny).downarrow, flash.display.MovieClip));
			mScrollDownButton.releaseCallback = scrollDown;
		}
	}

	function onMouseWheel(event:MouseEvent) {
		if (!mScrollable || mScrollSlider == null) {
			return;
		}
		mScrollSlider.valueWithCallback = mScrollSlider.value - event.delta * 50;
	}

	function scrollUp() {
		if (mScrollable && mScrollSlider != null) {
			mScrollSlider.valueWithCallback = mScrollSlider.value - 50;
		}
	}

	function scrollDown() {
		if (mScrollable && mScrollSlider != null) {
			mScrollSlider.valueWithCallback = mScrollSlider.value + 50;
		}
	}

	function updateScrollRange() {
		if (mScrollPane == null) {
			return;
		}
		var _loc1_ = Math.max(0, mContentHeight - mViewportHeight);
		mScrollable = _loc1_ > 0;
		setScrollControlsVisible(mScrollable);
		mScrollPane.scrollToY(0);
		if (!mScrollable || mScrollSlider == null) {
			return;
		}
		mScrollSlider.minimum = _loc1_;
		mScrollSlider.maximum = 0;
		mScrollSlider.value = 0;
	}

	function setScrollControlsVisible(visible:Bool) {
		if (mScrollSlider != null) {
			mScrollSlider.visible = visible;
		}
		if (mScrollUpButton != null) {
			mScrollUpButton.visible = visible;
		}
		if (mScrollDownButton != null) {
			mScrollDownButton.visible = visible;
		}
	}

	function linkRowNavigation() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mRows.length - 1) {
			mRows[_loc1_].isAbove(mRows[_loc1_ + 1]);
			_loc1_++;
		}
		var _loc2_:SettingRow;
		final __ax4_iter_411 = mRows;
		if (checkNullIteratee(__ax4_iter_411))
			for (_tmp_ in __ax4_iter_411) {
				_loc2_ = _tmp_;
				_loc2_.leftNavigationAdditionalInteraction = _loc2_.nudgeDown;
				_loc2_.rightNavigationAdditionalInteraction = _loc2_.nudgeUp;
			}
	}

	function createRow(definition:SettingDefinition, index:Int):SettingRow {
		if (definition.isKeyBinding) {
			return new KeyBindingSettingRow(mDBFacade, mSwfAsset, definition, mModel, index);
		}
		if (definition.isChoice) {
			return new ChoiceSettingRow(mDBFacade, mSwfAsset, definition, mModel, index);
		}
		if (definition.isSlider) {
			return new SliderSettingRow(mDBFacade, mSwfAsset, definition, mModel, index);
		}
		return new BooleanSettingRow(mDBFacade, mSwfAsset, definition, mModel, index);
	}

	function destroyRows() {
		var _loc1_:SettingRow;
		final __ax4_iter_412 = mRows;
		if (checkNullIteratee(__ax4_iter_412))
			for (_tmp_ in __ax4_iter_412) {
				_loc1_ = _tmp_;
				if (_loc1_.root != null && _loc1_.root.parent != null) {
					_loc1_.root.parent.removeChild(_loc1_.root);
				}
				_loc1_.destroy();
			}
		mRows.length = 0;
		mContentHeight = 0;
	}

	function onSettingChanged(id:String) {
		var _loc2_:SettingRow;
		final __ax4_iter_413 = mRows;
		if (checkNullIteratee(__ax4_iter_413))
			for (_tmp_ in __ax4_iter_413) {
				_loc2_ = _tmp_;
				_loc2_.refreshFromModel();
			}
	}
}
