package com.junkbyte.console.view;

import com.junkbyte.console.Console;
import com.junkbyte.console.KeyBind;
import com.junkbyte.console.core.LogReferences;
import flash.Boot;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.TextEvent;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import haxe.IMap;
import haxe.ds.ObjectMap;

class RollerPanel extends ConsolePanel {
	public static var customContentProvider:ASAny;

	public static var NAME:String = "rollerPanel";

	public var _settingKey:Bool = false;

	public function new(m:Console = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(m);
			name = "rollerPanel";
			init(60, 100, false);
			txtField = makeTF("rollerPrints");
			txtField.multiline = true;
			txtField.autoSize = TextFieldAutoSize.LEFT;
			registerTFRoller(txtField, onMenuRollOver, linkHandler);
			registerDragger(txtField);
			addChild(txtField);
			addEventListener(Event.ENTER_FRAME, _onFrame);
			addEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
		}
	}

	public function removeListeners(e:Event = /*undefined*/ null) {
		removeEventListener(Event.ENTER_FRAME, _onFrame);
		removeEventListener(Event.REMOVED_FROM_STAGE, removeListeners);
		if (stage != null) {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
	}

	public function onMenuRollOver(e:TextEvent) {
		var _loc3_ = ASCompat.dynamicAs(null, KeyBind);
		var _loc2_ = e.text != null ? StringTools.replace(e.text, "event:", "") : "";
		if (_loc2_ == "close") {
			_loc2_ = "Close";
		} else if (_loc2_ == "capture") {
			_loc3_ = console.get_rollerCaptureKey();
			if (_loc3_ != null) {
				_loc2_ = "Unassign key ::" + Std.string(_loc3_.get_key());
			} else {
				_loc2_ = "Assign key";
			}
		} else if (_loc2_ == "cancel") {
			_loc2_ = "Cancel assign key";
		} else {
			_loc2_ = null;
		}
		console.get_panels().tooltip(_loc2_, this);
	}

	public function linkHandler(e:TextEvent) {
		cast(e.currentTarget, TextField).setSelection(0, 0);
		if (e.text == "close") {
			close();
		} else if (e.text == "capture") {
			if (console.get_rollerCaptureKey() != null) {
				console.setRollerCaptureKey(null);
			} else {
				_settingKey = true;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false, 0, true);
			}
			console.get_panels().tooltip(null);
		} else if (e.text == "cancel") {
			cancelCaptureKeySet();
			console.get_panels().tooltip(null);
		}
		e.stopPropagation();
	}

	public function keyDownHandler(e:KeyboardEvent) {
		if (e.charCode == 0) {
			return;
		}
		var _loc2_:Int = e.charCode;
		var _loc3_:String = _loc2_ < 65536 ? (String : ASAny)["fromCharCode"](_loc2_) : Boot.fromCodePoint(_loc2_);
		cancelCaptureKeySet();
		console.setRollerCaptureKey(_loc3_, e.shiftKey, e.ctrlKey, e.altKey);
		console.get_panels().tooltip(null);
	}

	public function getMapString(dolink:Bool):String {
		var _loc4_:ASAny = ASCompat.asString(null);
		var _loc9_:ASAny = ASCompat.dynamicAs(null, DisplayObject);
		var _loc10_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc11_:ASAny = ASCompat.dynamicAs(null, DisplayObject);
		var _loc12_ = 0;
		var _loc13_ = 0;
		var _loc14_ = 0;
		var _loc15_ = 0;
		var _loc16_:ASAny = null;
		var _loc17_ = 0;
		var _loc18_ = (0 : UInt);
		var _loc2_ = console.stage;
		var _loc3_ = "";
		if (!dolink) {
			_loc4_ = console.get_rollerCaptureKey() != null ? console.get_rollerCaptureKey().get_key() : "unassigned";
			_loc3_ = "<menu> <a href=\"event:close\"><b>X</b></a></menu> Capture key: <menu><a href=\"event:capture\">"
				+ Std.string(_loc4_)
				+ "</a></menu><br/>";
		}
		var _loc5_ = new Point(_loc2_.mouseX, _loc2_.mouseY);
		if (_loc2_.areInaccessibleObjectsUnderPoint(_loc5_)) {
			_loc3_ += "<p9>Inaccessible objects detected</p9><br/>";
		}
		var _loc6_ = _loc2_.getObjectsUnderPoint(_loc5_);
		var _loc7_:IMap = new ObjectMap();
		if (_loc6_.length == 0) {
			_loc6_.push(_loc2_);
		}
		var _loc8_ = 0;
		while (_loc8_ < _loc6_.length) {
			_loc9_ = _loc6_[_loc8_];
			_loc8_++;
			_loc10_ = [_loc9_];
			_loc11_ = _loc9_.parent;
			while (_loc11_ != null) {
				_loc10_.unshift(_loc11_);
				_loc11_ = _loc11_.parent;
			}
			_loc12_ = ASCompat.toInt(_loc10_.length);
			_loc13_ = 0;
			_loc14_ = _loc12_;
			while (_loc13_ < _loc14_) {
				_loc15_ = _loc13_++;
				_loc16_ = _loc10_[_loc15_];
				if ((_loc7_ : ASAny)[_loc16_] == null) {
					(_loc7_ : ASAny)[_loc16_] = _loc15_;
					_loc17_ = _loc15_;
					while (_loc17_ > 0) {
						_loc3_ += _loc17_ == 1 ? " ∟" : " -";
						_loc17_--;
					}
					if (Std.isOfType(_loc16_, DisplayObject)) {
						_loc4_ = _loc16_.name;
					} else if (Reflect.hasField(_loc16_, "name")) {
						_loc4_ = _loc16_.name;
					} else {
						_loc4_ = "instance";
					}
					if (dolink && console.get_config().useObjectLinking) {
						_loc18_ = console.get_refs().setLogRef(_loc16_);
						_loc4_ = "<a href=\'event:cl_" + ("" + _loc18_) + "\'>" + Std.string(_loc4_) + "</a> " + console.get_refs().makeRefTyped(_loc16_);
					} else {
						_loc4_ = Std.string(_loc4_) + " (" + LogReferences.ShortClassName(_loc16_) + ")";
					}
					if (_loc16_ == _loc2_) {
						_loc18_ = console.get_refs().setLogRef(_loc2_);
						if (_loc18_ != 0) {
							_loc3_ += "<p3><a href=\'event:cl_" + ("" + _loc18_) + "\'><i>Stage</i></a> ";
						} else {
							_loc3_ += "<p3><i>Stage</i> ";
						}
						_loc3_ += "["
							+ Std.string(ASCompat.floatToInt(Math.fround(_loc2_.mouseX * 10000000)) / 10000000)
							+ ","
							+ Std.string(ASCompat.floatToInt(Math.fround(_loc2_.mouseY * 10000000)) / 10000000)
							+ "]</p3><br/>";
					} else if (_loc15_ == _loc12_ - 1) {
						_loc3_ += "<p5>" + Std.string(_loc4_) + "</p5><br/>";
					} else {
						_loc3_ += "<p2><i>" + Std.string(_loc4_) + "</i></p2><br/>";
					}
				}
			}
		}
		if (RollerPanel.customContentProvider != null) {
			_loc4_ = RollerPanel.customContentProvider(_loc2_.mouseX, _loc2_.mouseY, dolink);
			if (_loc4_ != null && _loc4_ != "") {
				_loc3_ += _loc4_;
			}
		}
		return _loc3_;
	}

	override public function close() {
		cancelCaptureKeySet();
		removeListeners();
		super.close();
		console.get_panels().updateMenu();
	}

	public function cancelCaptureKeySet() {
		_settingKey = false;
		if (stage != null) {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		}
	}

	public function _onFrame(e:Event) {
		if (console.stage == null) {
			close();
			return;
		}
		if (_settingKey) {
			txtField.htmlText = "<high><menu>Press a key to set [ <a href=\"event:cancel\"><b>cancel</b></a> ]</menu></high>";
		} else {
			txtField.htmlText = "<low>" + getMapString(false) + "</low>";
			txtField.autoSize = TextFieldAutoSize.LEFT;
			txtField.setSelection(0, 0);
		}
		set_width(txtField.width + 4);
		set_height(txtField.height);
	}
}
