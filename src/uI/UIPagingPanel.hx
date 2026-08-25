package uI;

import brain.uI.UIButton;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import flash.display.MovieClip;

class UIPagingPanel {
	var mDBFacade:DBFacade;

	var mRoot:MovieClip;

	var mCallback:ASFunction;

	var mNumPages:UInt = 0;

	var mCurrentPage:UInt = 0;

	var mPageLeftButton:UIButton;

	var mPageRightButton:UIButton;

	var mPageButtonClass:Dynamic;

	var mPageButtons:Vector<UIButton>;

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
		this.updatePageArrows();
		return value;
	}

	function get_numPages():UInt {
		return mNumPages;
	}

	@:isVar public var currentPage(get, set):UInt;

	public function set_currentPage(value:UInt):UInt {
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
		mPageLeftButton = new UIButton(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).page_left, flash.display.MovieClip));
		mPageRightButton = new UIButton(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).page_right, flash.display.MovieClip));
		mPageLeftButton.releaseCallback = pageLeft;
		mPageRightButton.releaseCallback = pageRight;
		mPageLeftButton.enabled = false;
		mPageRightButton.enabled = false;
	}

	function pageLeft() {
		this.currentPage = (Std.int(Math.max(0, mCurrentPage - 1)) : UInt);
		if (mCallback != null) {
			mCallback(mCurrentPage);
		}
	}

	function pageRight() {
		this.currentPage = (Std.int(Math.min(mNumPages, mCurrentPage + 1)) : UInt);
		if (mCallback != null) {
			mCallback(mCurrentPage);
		}
	}

	function updatePageArrows() {
		var pageButton:UIButton;
		var pageButtonMC:MovieClip;
		var PAD:UInt;
		var MAX_BUTTONS:UInt;
		var startPage:UInt;
		var endPage:UInt;
		var numPagesShowing:UInt;
		var even:Bool;
		var i:UInt;
		var buttonWidth:Float;
		var leftEdge:Float;
		var offset:Float;
		mPageLeftButton.enabled = mCurrentPage != 0;
		mPageRightButton.enabled = mCurrentPage < mNumPages - 1;
		final __ax4_iter_134 = mPageButtons;
		if (checkNullIteratee(__ax4_iter_134))
			for (_tmp_ in __ax4_iter_134) {
				pageButton = _tmp_;
				pageButton.detach();
				pageButton.destroy();
			}
		mPageButtons.length = 0;
		PAD = (8 : UInt);
		MAX_BUTTONS = (9 : UInt);
		startPage = (Std.int(Math.max(0, Math.min(mNumPages - MAX_BUTTONS, mCurrentPage - MAX_BUTTONS / 2 + 1))) : UInt);
		endPage = (Std.int(Math.min(startPage + MAX_BUTTONS, mNumPages)) : UInt);
		numPagesShowing = endPage - startPage;
		even = numPagesShowing % 2 == 0;
		i = startPage;
		while (i < endPage) {
			pageButtonMC = ASCompat.dynamicAs(ASCompat.createInstance(mPageButtonClass, []), flash.display.MovieClip);
			mRoot.addChild(pageButtonMC);
			pageButton = new UIButton(mDBFacade, pageButtonMC);
			pageButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			pageButton.label.text = Std.string((i + 1));
			buttonWidth = pageButton.root.width + PAD;
			leftEdge = numPagesShowing * buttonWidth * -0.5;
			offset = even ? buttonWidth * 0.5 : 0;
			pageButton.root.x = leftEdge + offset + (i - startPage) * buttonWidth;
			ASCompat.setProperty(pageButton.root, "pageIndex", i);
			pageButton.releaseCallbackThis = function(param1:UIButton) {
				param1.bringToFront();
				currentPage = (ASCompat.toInt((param1.root : ASAny).pageIndex) : UInt);
				if (mCallback != null) {
					mCallback(mCurrentPage);
				}
			};
			mPageButtons.push(pageButton);
			if (i == mCurrentPage) {
				pageButton.enabled = false;
				pageButton.root.scaleX = pageButton.root.scaleY = 1.2;
				pageButton.root.filters = cast([DBGlobal.UI_SELECTED_FILTER]);
			} else {
				pageButton.enabled = true;
				pageButton.root.scaleX = pageButton.root.scaleY = 1;
				pageButton.root.filters = cast([]);
			}
			i = i + 1;
		}
		if ((mPageButtons.length : UInt) > mCurrentPage - startPage) {
			mPageButtons[(mCurrentPage - startPage : Int)].bringToFront();
		}
	}
}
