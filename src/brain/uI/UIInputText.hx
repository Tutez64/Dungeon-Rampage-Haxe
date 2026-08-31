package brain.uI;

import brain.facade.Facade;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
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

	public function new(facade:Facade, root:MovieClip) {
		mTextField = ASCompat.dynamicAs((root : ASAny).textField, flash.text.TextField);
		super(facade, root);
		mTextField.addEventListener("mouseDown", onPress);
		mTextField.addEventListener("change", onChange);
		mTextField.addEventListener("keyDown", onKeyDown);
		mTextField.addEventListener("keyUp", onKeyUp);
		mTextField.addEventListener("focusIn", onFocusIn);
		mTextField.addEventListener("focusOut", onFocusOut);
	}

	function onPress(event:MouseEvent) {
		event.stopImmediatePropagation();
		mTextField.addEventListener("mouseUp", onRelease);
	}

	function onRelease(event:MouseEvent) {
		event.stopImmediatePropagation();
		mTextField.removeEventListener("mouseUp", onRelease);
	}

	@:isVar public var defaultTextColor(never, set):UInt;

	public function set_defaultTextColor(value:UInt):UInt {
		mDefaultTextColor = value;
		if (mShowingDefaultText) {
			mTextField.textColor = mDefaultTextColor;
		}
		return value;
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
	}

	function onFocusOut(event:FocusEvent) {}

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
		} else if (!(event.ctrlKey && (event.keyCode == 86 || event.keyCode == 67 || event.keyCode == 88))) {
			event.stopPropagation();
		}
	}

	function onKeyUp(event:KeyboardEvent) {
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

	override public function set_enabled(value:Bool):Bool {
		super.enabled = value;
		return mTextField.tabEnabled = value;
	}

	override public function destroy() {
		super.destroy();
		mTextField.removeEventListener("mouseDown", onPress);
		mTextField.removeEventListener("mouseUp", onRelease);
		mTextField.removeEventListener("change", onChange);
		mTextField.removeEventListener("keyDown", onKeyDown);
		mTextField.removeEventListener("keyUp", onKeyUp);
		mTextField.removeEventListener("focusIn", onFocusIn);
		mTextField.removeEventListener("focusOut", onFocusOut);
		mTextField = null;
		mChangeCallback = null;
		mEnterCallback = null;
		mCancelCallback = null;
	}
}
