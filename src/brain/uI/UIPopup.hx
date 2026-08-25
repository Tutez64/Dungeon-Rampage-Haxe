package brain.uI;

import brain.facade.Facade;
import brain.utils.MemoryTracker;
import flash.display.MovieClip;
import flash.text.TextField;

class UIPopup extends UIObject {
	public static inline final YES = (1 : UInt);

	public static inline final NO = (2 : UInt);

	public static inline final OK = (4 : UInt);

	public static inline final CANCEL = (8 : UInt);

	var mButtonFlags:UInt = (4 : UInt);

	var mModal:Bool = true;

	var mCurtainActive:Bool = false;

	var mCloseCallback:ASFunction;

	var mText:String = "";

	var mTextField:TextField;

	var mYesButton:UIButton;

	var mNoButton:UIButton;

	var mOkButton:UIButton;

	var mCancelButton:UIButton;

	public function new(facade:Facade) {
		var _loc2_ = new MovieClip();
		MemoryTracker.track(_loc2_, "MovieClip - popup root created in UIPopup()", "brain");
		super(facade, _loc2_);
		if (mModal) {
			makeCurtain();
		}
		mFacade.sceneGraphManager.addChild(mRoot, 105);
	}

	public static function show(facade:Facade, text:String = "", flags:UInt = (4 : UInt), modal:Bool = true, callback:ASFunction = null):UIPopup {
		var _loc6_ = new UIPopup(facade);
		_loc6_.mText = text;
		_loc6_.mButtonFlags = flags;
		_loc6_.mModal = modal;
		_loc6_.mCloseCallback = callback;
		return _loc6_;
	}

	override public function destroy() {
		removeCurtain();
	}

	@:isVar public var callback(never, set):ASFunction;

	public function set_callback(closeCallback:ASFunction):ASFunction {
		return mCloseCallback = closeCallback;
	}

	function makeCurtain() {
		if (!mCurtainActive) {
			mFacade.sceneGraphManager.showPopupCurtain();
			mCurtainActive = true;
		}
	}

	function removeCurtain() {
		if (mCurtainActive) {
			mFacade.sceneGraphManager.removePopupCurtain();
			mCurtainActive = false;
		}
	}

	function setupUI(popupClass:Dynamic) {
		var popup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
		MemoryTracker.track(popup, "MovieClip - popup content created in UIPopup.setupUI()", "brain");
		mRoot.addChild(popup);
		mTextField = cast((popup : ASAny).popupText, TextField);
		mTextField.text = mText;
		mYesButton = new UIButton(mFacade, ASCompat.dynamicAs((popup : ASAny).yesButton, flash.display.MovieClip));
		MemoryTracker.track(mYesButton, "UIButton - yes button created in UIPopup.setupUI()", "brain");
		mNoButton = new UIButton(mFacade, ASCompat.dynamicAs((popup : ASAny).noButton, flash.display.MovieClip));
		MemoryTracker.track(mNoButton, "UIButton - no button created in UIPopup.setupUI()", "brain");
		mOkButton = new UIButton(mFacade, ASCompat.dynamicAs((popup : ASAny).okButton, flash.display.MovieClip));
		MemoryTracker.track(mOkButton, "UIButton - ok button created in UIPopup.setupUI()", "brain");
		mCancelButton = new UIButton(mFacade, ASCompat.dynamicAs((popup : ASAny).cancelButton, flash.display.MovieClip));
		MemoryTracker.track(mCancelButton, "UIButton - cancel button created in UIPopup.setupUI()", "brain");
		mYesButton.label.text = "Yes";
		mNoButton.label.text = "No";
		mOkButton.label.text = "OK";
		mCancelButton.label.text = "Cancel";
		mYesButton.releaseCallback = function() {
			onClose((1 : UInt));
		};
		mNoButton.releaseCallback = function() {
			onClose((2 : UInt));
		};
		mOkButton.releaseCallback = function() {
			onClose((4 : UInt));
		};
		mCancelButton.releaseCallback = function() {
			onClose((8 : UInt));
		};
		mYesButton.root.visible = ((mButtonFlags : Int) & 1) != 0;
		mNoButton.root.visible = ((mButtonFlags : Int) & 2) != 0;
		mOkButton.root.visible = ((mButtonFlags : Int) & 4) != 0;
		mCancelButton.root.visible = ((mButtonFlags : Int) & 8) != 0;
	}

	function onClose(buttonFlag:UInt) {
		if (mCloseCallback != null) {
			mCloseCallback(buttonFlag);
		}
		this.destroy();
	}
}
