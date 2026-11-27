package brain.uI;

import brain.event.EventListeners;
import brain.facade.Facade;
import brain.utils.TextUtil;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.text.TextField;

class UIInputText extends UIObject {
	var mTextField:TextField;

	var mDefaultText:String;

	var mDefaultTextColor:UInt = (8947848 : UInt);

	var mNormalTextColor:UInt = (0 : UInt);

	var mShowingDefaultText:Bool = false;

	var mChangeCallback:ASFunction;

	var mEnterCallback:ASFunction;

	var mCancelCallback:ASFunction;

	var mMenuNavigationKeysEnabled:Bool = false;

	var mRolloverFilter:GlowFilter;

	var mFiltersBeforeRollover:Array<ASAny>;

	var mFiltersCaptured:Bool = false;

	var mFocusInCallback:ASFunction;

	var mSelectedCallback:ASFunction;

	var mFocusOutCallback:ASFunction;

	public function new(facade:Facade, root:MovieClip) {
		mTextField = ASCompat.coerce((root : ASAny).textField, flash.text.TextField);
		super(facade, root);
		EventListeners.add(mTextField, "mouseDown", onPress);
		EventListeners.add(mTextField, "change", onChange);
		EventListeners.add(mTextField, "keyDown", onKeyDown);
		EventListeners.add(mTextField, "keyUp", onKeyUp);
		EventListeners.add(mTextField, "focusIn", onFocusIn);
		EventListeners.add(mTextField, "focusOut", onFocusOut);
	}

	function onPress(event:MouseEvent) {
		event.stopImmediatePropagation();
		EventListeners.add(mTextField, "mouseUp", onRelease);
	}

	function onRelease(event:MouseEvent) {
		event.stopImmediatePropagation();
		EventListeners.remove(mTextField, "mouseUp", onRelease);
	}

	override public function onSelected(fromController:Bool = false) {
		if (mFacade != null && mFacade.stageRef != null && mTextField != null) {
			mFacade.stageRef.focus = mTextField;
		}
		if (mSelectedCallback != null) {
			mSelectedCallback(fromController);
		}
	}

	public function releaseKeyboardFocus() {
		if (mFacade == null || mFacade.stageRef == null || mTextField == null) {
			return;
		}
		if (mFacade.stageRef.focus == mTextField) {
			mFacade.stageRef.focus = null;
		}
	}

	override function onRollOver(event:MouseEvent) {
		super.onRollOver(event);
		if (mRolloverFilter == null || mFiltersCaptured || mRoot == null) {
			return;
		}
		mFiltersBeforeRollover = mRoot.filters.slice(0);
		mFiltersCaptured = true;
		mRoot.filters = cast([mRolloverFilter]);
	}

	override function onRollOut(event:MouseEvent) {
		super.onRollOut(event);
		if (!mFiltersCaptured) {
			return;
		}
		if (mRoot != null) {
			mRoot.filters = cast(mFiltersBeforeRollover);
		}
		mFiltersBeforeRollover = null;
		mFiltersCaptured = false;
	}

	@:isVar public var menuNavigationKeysEnabled(get, set):Bool;

	public function set_menuNavigationKeysEnabled(value:Bool):Bool {
		return mMenuNavigationKeysEnabled = value;
	}

	function get_menuNavigationKeysEnabled():Bool {
		return mMenuNavigationKeysEnabled;
	}

	@:isVar public var rolloverFilter(get, set):GlowFilter;

	public function set_rolloverFilter(value:GlowFilter):GlowFilter {
		return mRolloverFilter = value;
	}

	function get_rolloverFilter():GlowFilter {
		return mRolloverFilter;
	}

	@:isVar public var defaultTextColor(get, set):UInt;

	public function set_defaultTextColor(value:UInt):UInt {
		mDefaultTextColor = value;
		if (mShowingDefaultText) {
			mTextField.textColor = mDefaultTextColor;
		}
		return value;
	}

	function get_defaultTextColor():UInt {
		return mDefaultTextColor;
	}

	@:isVar public var showingDefaultText(get, never):Bool;

	public function get_showingDefaultText():Bool {
		return mShowingDefaultText;
	}

	@:isVar public var normalTextColor(never, set):UInt;

	public function set_normalTextColor(value:UInt):UInt {
		mNormalTextColor = value;
		if (!mShowingDefaultText) {
			mTextField.textColor = mNormalTextColor;
		}
		return value;
	}

	@:isVar public var defaultText(never, set):String;

	public function set_defaultText(value:String):String {
		mDefaultText = value;
		mTextField.text = mDefaultText;
		TextUtil.addOverhangSlack(mTextField);
		mTextField.textColor = mDefaultTextColor;
		mShowingDefaultText = true;
		return value;
	}

	@:isVar public var text(get, set):String;

	public function get_text():String {
		if (mShowingDefaultText) {
			return "";
		}
		return mTextField.text;
	}

	function set_text(value:String):String {
		return mTextField.text = value;
	}

	function onFocusIn(event:FocusEvent) {
		if (mShowingDefaultText) {
			this.clear();
			mShowingDefaultText = false;
			mTextField.textColor = mNormalTextColor;
		}
		if (mFocusInCallback != null) {
			mFocusInCallback();
		}
	}

	function onFocusOut(event:FocusEvent) {
		if (mFocusOutCallback != null) {
			mFocusOutCallback();
		}
	}

	@:isVar public var textField(get, never):TextField;

	public function get_textField():TextField {
		return mTextField;
	}

	function onKeyDown(event:KeyboardEvent) {
		if (event.keyCode == 13 && mEnterCallback != null && !mShowingDefaultText) {
			if (mTextField != null) {
				mEnterCallback(mTextField.text);
			}
			event.stopPropagation();
		} else if (event.keyCode == 27 && mCancelCallback != null) {
			mCancelCallback();
			event.stopPropagation();
		} else if (!(mMenuNavigationKeysEnabled && (event.keyCode == 38 || event.keyCode == 40))) {
			if (!(event.ctrlKey && (event.keyCode == 86 || event.keyCode == 67 || event.keyCode == 88))) {
				event.stopPropagation();
			}
		}
	}

	function onKeyUp(event:KeyboardEvent) {
		if (mFacade != null && mFacade.inputManager != null) {
			mFacade.inputManager.releaseKey((event.keyCode : Int));
		}
		if (!(event.ctrlKey && (event.keyCode == 86 || event.keyCode == 67 || event.keyCode == 88))) {
			event.stopPropagation();
		}
	}

	function onChange(event:Event) {
		if (mChangeCallback != null) {
			mChangeCallback(mTextField.text);
		}
	}

	public function clear() {
		mTextField.text = "";
		if (mChangeCallback != null) {
			mChangeCallback("");
		}
	}

	@:isVar public var changeCallback(never, set):ASFunction;

	public function set_changeCallback(value:ASFunction):ASFunction {
		return mChangeCallback = value;
	}

	@:isVar public var enterCallback(never, set):ASFunction;

	public function set_enterCallback(value:ASFunction):ASFunction {
		return mEnterCallback = value;
	}

	@:isVar public var cancelCallback(never, set):ASFunction;

	public function set_cancelCallback(value:ASFunction):ASFunction {
		return mCancelCallback = value;
	}

	@:isVar public var focusInCallback(never, set):ASFunction;

	public function set_focusInCallback(value:ASFunction):ASFunction {
		return mFocusInCallback = value;
	}

	@:isVar public var selectedCallback(never, set):ASFunction;

	public function set_selectedCallback(value:ASFunction):ASFunction {
		return mSelectedCallback = value;
	}

	@:isVar public var focusOutCallback(never, set):ASFunction;

	public function set_focusOutCallback(value:ASFunction):ASFunction {
		return mFocusOutCallback = value;
	}

	override public function set_enabled(value:Bool):Bool {
		super.enabled = value;
		return mTextField.tabEnabled = value;
	}

	override public function destroy() {
		releaseKeyboardFocus();
		super.destroy();
		EventListeners.remove(mTextField, "mouseDown", onPress);
		EventListeners.remove(mTextField, "mouseUp", onRelease);
		EventListeners.remove(mTextField, "change", onChange);
		EventListeners.remove(mTextField, "keyDown", onKeyDown);
		EventListeners.remove(mTextField, "keyUp", onKeyUp);
		EventListeners.remove(mTextField, "focusIn", onFocusIn);
		EventListeners.remove(mTextField, "focusOut", onFocusOut);
		mTextField = null;
		mRolloverFilter = null;
		mFiltersBeforeRollover = null;
		mChangeCallback = null;
		mEnterCallback = null;
		mCancelCallback = null;
		mFocusInCallback = null;
		mFocusOutCallback = null;
		mSelectedCallback = null;
	}
}
