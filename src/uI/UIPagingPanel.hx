package uI;

import brain.uI.UIButton;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import flash.display.MovieClip;

class UIPagingPanel {
	static inline final PAGE_BUTTON_PAD = (8 : UInt);

	static inline final MAX_PAGE_BUTTONS = (8 : UInt);

	var mDBFacade:DBFacade;

	var mRoot:MovieClip;

	var mCallback:ASFunction;

	var mNumPages:UInt = 0;

	var mCurrentPage:UInt = 0;

	var mPageLeftButton:UIButton;

	var mPageRightButton:UIButton;

	var mPageButtonClass:Dynamic;

	var mPageButtons:Vector<UIButton>;

	var mVisiblePageButtonCount:UInt = 0;

	public function new(dbFacade:DBFacade, numPages:UInt, rootClip:MovieClip, pageButtonClass:Dynamic, callback:ASFunction) {
		mDBFacade = dbFacade;
		mNumPages = numPages;
		mRoot = rootClip;
		mPageButtonClass = pageButtonClass;
		mPageButtons = new Vector<UIButton>();
		mCurrentPage = (0 : UInt);
		mCallback = callback;
		this.setupUI(rootClip);
		updatePageArrows();
	}

	public function destroy() {
		mDBFacade = null;
		mCallback = null;
		var _loc1_:UIButton;
		final __ax4_iter_133 = mPageButtons;
		if (checkNullIteratee(__ax4_iter_133))
			for (_tmp_ in __ax4_iter_133) {
				_loc1_ = _tmp_;
				_loc1_.detach();
				_loc1_.destroy();
			}
		mPageButtons.length = 0;
		mPageLeftButton.destroy();
		mPageRightButton.destroy();
	}

	@:isVar public var root(get, never):MovieClip;

	public function get_root():MovieClip {
		return mRoot;
	}

	@:isVar public var visible(get, set):Bool;

	public function set_visible(value:Bool):Bool {
		return mRoot.visible = value;
	}

	function get_visible():Bool {
		return mRoot.visible;
	}

	@:isVar public var numPages(get, set):UInt;

	public function set_numPages(value:UInt):UInt {
		mNumPages = value;
		if (mNumPages == 0) {
			mCurrentPage = (0 : UInt);
		} else if (mCurrentPage >= mNumPages) {
			mCurrentPage = mNumPages - 1;
		}
		this.updatePageArrows();
		return value;
	}

	function get_numPages():UInt {
		return mNumPages;
	}

	@:isVar public var currentPage(get, set):UInt;

	public function set_currentPage(value:UInt):UInt {
		value = (ASCompat.floatToInt(mNumPages == 0 ? (0 : UInt) : (ASCompat.floatToInt(Math.min(value, (mNumPages : Float) - 1)) : UInt)) : UInt);
		if (value == mCurrentPage) {
			return value;
		}
		mCurrentPage = value;
		this.updatePageArrows();
		return value;
	}

	function get_currentPage():UInt {
		return mCurrentPage;
	}

	public function dontKillUI() {
		mPageLeftButton.dontKillMyChildren = true;
		mPageRightButton.dontKillMyChildren = true;
	}

	function setupUI(rootClip:MovieClip) {
		mRoot = rootClip;
		mPageLeftButton = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).page_left, flash.display.MovieClip));
		mPageRightButton = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).page_right, flash.display.MovieClip));
		mPageLeftButton.releaseCallback = pageLeft;
		mPageRightButton.releaseCallback = pageRight;
		mPageLeftButton.enabled = false;
		mPageRightButton.enabled = false;
	}

	function pageLeft() {
		this.currentPage = (ASCompat.floatToInt(Math.max(0, (mCurrentPage : Float) - 1)) : UInt);
		if (mCallback != null) {
			mCallback(mCurrentPage);
		}
	}

	function pageRight() {
		this.currentPage = (ASCompat.floatToInt(mNumPages == 0 ? (0 : UInt) : (ASCompat.floatToInt(Math.min((mNumPages : Float) - 1,
			mCurrentPage + 1)) : UInt)) : UInt);
		if (mCallback != null) {
			mCallback(mCurrentPage);
		}
	}

	function updatePageArrows() {
		var pageButton:UIButton;
		var pageButtonMC:MovieClip;
		var maxStartPage:Int;
		var centeredStartPage:Int;
		var startPage:UInt;
		var endPage:UInt;
		var numPagesShowing:UInt;
		var even:Bool;
		var buttonIndex:UInt;
		var pageIndex:UInt;
		var buttonWidth:Float;
		var leftEdge:Float;
		var offset:Float;
		mPageLeftButton.enabled = mCurrentPage != 0;
		mPageRightButton.enabled = mNumPages > 0 && mCurrentPage < (mNumPages:Float) - 1;
		maxStartPage = ASCompat.floatToInt(Math.max(0, mNumPages - 8));
		centeredStartPage = mCurrentPage - 4 + 1;
		startPage = (ASCompat.floatToInt(Math.max(0, Math.min(maxStartPage, centeredStartPage))) : UInt);
		endPage = (ASCompat.floatToInt(Math.min(startPage + 8, mNumPages)) : UInt);
		numPagesShowing = endPage - startPage;
		mVisiblePageButtonCount = numPagesShowing;
		even = numPagesShowing % 2 == 0;
		while ((mPageButtons.length : UInt) < numPagesShowing) {
			pageButtonMC = ASCompat.coerce(ASCompat.createInstance(mPageButtonClass, []), flash.display.MovieClip);
			mRoot.addChild(pageButtonMC);
			pageButton = new UIButton(mDBFacade, pageButtonMC);
			pageButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			pageButton.releaseCallbackThis = function(param1:UIButton) {
				param1.bringToFront();
				currentPage = (ASCompat.toInt((param1.root : ASAny).pageIndex) : UInt);
				if (mCallback != null) {
					mCallback(mCurrentPage);
				}
			};
			mPageButtons.push(pageButton);
		}
		buttonIndex = (0 : UInt);
		while (buttonIndex < (mPageButtons.length:UInt)) {
			pageButton = mPageButtons[(buttonIndex : Int)];
			pageButton.clearNavigationAndInteractions();
			pageButton.visible = buttonIndex < numPagesShowing;
			if (pageButton.visible) {
				pageIndex = startPage + buttonIndex;
				pageButton.root.scaleX = pageButton.root.scaleY = 1;
				TextUtil.setText(pageButton.label, Std.string((pageIndex + 1)));
				buttonWidth = pageButton.root.width + 8;
				leftEdge = numPagesShowing * buttonWidth * -0.5;
				offset = even ? buttonWidth * 0.5 : 0;
				pageButton.root.x = leftEdge + offset + buttonIndex * buttonWidth;
				ASCompat.setProperty(pageButton.root, "pageIndex", pageIndex);
				if (pageIndex == mCurrentPage) {
					pageButton.enabled = false;
					pageButton.root.scaleX = pageButton.root.scaleY = 1.2;
					pageButton.root.filters = cast([DBGlobal.UI_SELECTED_FILTER]);
				} else {
					pageButton.enabled = true;
					pageButton.root.scaleX = pageButton.root.scaleY = 1;
					pageButton.root.filters = cast([]);
				}
			}
			buttonIndex = buttonIndex + 1;
		}
		if (mVisiblePageButtonCount > (mCurrentPage : Float) - (startPage : Float)) {
			mPageButtons[(mCurrentPage - startPage : Int)].bringToFront();
		}
	}

	@:isVar public var getPageLeftButton(get, never):UIButton;

	public function get_getPageLeftButton():UIButton {
		return mPageLeftButton;
	}

	@:isVar public var getPageRightButton(get, never):UIButton;

	public function get_getPageRightButton():UIButton {
		return mPageRightButton;
	}

	public function getPageButton(buttonIndex:Int):UIButton {
		if (mPageButtons[buttonIndex] == null) {
			return null;
		}
		return mPageButtons[buttonIndex];
	}

	@:isVar public var numPageButtons(get, never):UInt;

	public function get_numPageButtons():UInt {
		return mVisiblePageButtonCount;
	}

	public function getNextPageButton():UIButton {
		var _loc1_ = (0 : UInt);
		if (mVisiblePageButtonCount < 2) {
			return null;
		}
		_loc1_ = (0 : UInt);
		while (_loc1_ < mVisiblePageButtonCount) {
			if (ASCompat.toNumberField((mPageButtons[(_loc1_ : Int)].root : ASAny), "pageIndex") == mCurrentPage) {
				return _loc1_ + 1 < mVisiblePageButtonCount ? mPageButtons[(_loc1_ + 1 : Int)] : mPageButtons[0];
			}
			_loc1_++;
		}
		return mPageButtons[0];
	}
}
