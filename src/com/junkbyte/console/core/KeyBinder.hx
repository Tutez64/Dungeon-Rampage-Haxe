package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.KeyBind;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;

class KeyBinder extends ConsoleCore {
	public var _warns:UInt = 0;

	public var _passInd:Int = 0;

	public var _binds:IMap<ASAny, ASAny>;

	public function new(console:Console = /*undefined*/ null) {
		super(console);
		console.get_cl().addCLCmd("keybinds", printBinds, "List all keybinds used");
		_binds = new StringMap<ASAny>();
	}

	public function tryRunKey(key:String) {
		var _loc4_:ASAny = null;
		var _loc2_ = cast(_binds, StringMap<Dynamic>);
		var _loc3_:Array<ASAny> = ASCompat.coerce(_loc2_.get(key), Array);
		if (config.keyBindsEnabled && _loc3_ != null) {
			if (canTrigger()) {
				_loc4_ = null;
				Reflect.callMethod(_loc4_, _loc3_[0], _loc3_[1]);
			} else if (_warns < 3) {
				++_warns;
				report("Key bind [" + key + "] did not trigger because you have focus on an input TextField.", 8);
			}
		}
	}

	public function printBinds(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc13_:ASAny = null;
		var _loc14_ = 0;
		var _loc15_ = false;
		var _loc16_:ASAny = ASCompat.asString(null);
		var _loc17_:ASAny = ASCompat.asString(null);
		report("Key binds:", -2);
		var _loc3_ = (0 : UInt);
		var _loc4_ = cast(_binds, StringMap<Dynamic>);
		var _loc5_:ASAny = ASCompat.haxeMapStorage(_loc4_);
		var _loc6_:ASAny = null;
		var _loc7_ = 0;
		var _loc8_ = false;
		var _loc9_:ASAny = _loc5_;
		var _loc10_ = _loc7_;
		var _loc11_ = (_loc10_ = ASCompat.nextIndex(_loc9_, _loc10_)) != 0;
		if (!_loc11_ && _loc6_ != null) {
			_loc9_ = _loc5_ = _loc6_;
			_loc10_ = _loc7_ = 0;
			_loc6_ = null;
			_loc8_ = true;
			_loc11_ = (_loc10_ = ASCompat.nextIndex(_loc9_, _loc10_)) != 0;
		}
		var _loc12_ = _loc10_;
		while (true) {
			_loc13_ = _loc5_;
			_loc14_ = _loc7_;
			_loc15_ = (_loc14_ = ASCompat.nextIndex(_loc13_, _loc14_)) != 0;
			if (!_loc15_ && _loc6_ != null) {
				_loc13_ = _loc5_ = _loc6_;
				_loc14_ = _loc7_ = 0;
				_loc6_ = null;
				_loc8_ = true;
				_loc15_ = (_loc14_ = ASCompat.nextIndex(_loc13_, _loc14_)) != 0;
			}
			_loc12_ = _loc14_;
			if (!_loc15_) {
				break;
			}
			_loc16_ = ASCompat.nextName(_loc5_, _loc12_);
			_loc7_ = _loc12_;
			if (_loc8_) {
				_loc16_ = Std.string(_loc16_).substr(1);
			}
			_loc17_ = _loc16_;
			_loc3_ += (1 : UInt);
			report(_loc17_, -2);
		}
		report("--- Found " + ("" + _loc3_), -2);
	}

	public function keyUpHandler(e:KeyboardEvent) {
		handleKeyEvent(e, true);
	}

	public function keyDownHandler(e:KeyboardEvent) {
		handleKeyEvent(e, false);
	}

	public function handleKeyEvent(e:KeyboardEvent, isKeyUp:Bool) {
		var _loc5_ = ASCompat.dynamicAs(null, KeyBind);
		var _loc3_:Int = e.charCode;
		var _loc4_:String = _loc3_ < 65536 ? (String : ASAny)["fromCharCode"](_loc3_) : ASCompat.fromCodePoint(_loc3_);
		if (isKeyUp
			&& config.keystrokePassword != null
			&& _loc4_ != null
			&& _loc4_ == config.keystrokePassword.substring(_passInd, _passInd + 1)) {
			++_passInd;
			if (_passInd >= config.keystrokePassword.length) {
				_passInd = 0;
				if (canTrigger()) {
					if (console.visible && !console.get_panels().get_mainPanel().visible) {
						console.get_panels().get_mainPanel().set_visible(true);
					} else {
						console.set_visible(!console.visible);
					}
					if (console.visible && console.get_panels().get_mainPanel().visible) {
						console.get_panels().get_mainPanel().set_visible(true);
						console.get_panels().get_mainPanel().moveBackSafePosition();
					}
				} else if (_warns < 3) {
					++_warns;
					report("Password did not trigger because you have focus on an input TextField.", 8);
				}
			}
		} else {
			if (isKeyUp) {
				_passInd = 0;
			}
			_loc5_ = new KeyBind(e.keyCode, e.shiftKey, e.ctrlKey, e.altKey, isKeyUp);
			tryRunKey(_loc5_.get_key());
			if (_loc4_ != null) {
				_loc5_ = new KeyBind(_loc4_, e.shiftKey, e.ctrlKey, e.altKey, isKeyUp);
				tryRunKey(_loc5_.get_key());
			}
		}
	}

	public function canTrigger():Bool {
		var _loc2_:ASAny = ASCompat.dynamicAs(null, TextField);
		var _loc3_ = ASCompat.dynamicAs(null, Error);
		try {
			if (console.stage != null && Std.isOfType(console.stage.focus, TextField)) {
				_loc2_ = console.stage.focus;
				if (_loc2_.type == TextFieldType.INPUT) {
					return false;
				}
			}
		} catch (_loc_e_:Dynamic) {
			_loc3_ = ASCompat.asError(_loc_e_);
		}
		return true;
	}

	public function bindKey(key:KeyBind, fun:ASAny, args:Array<ASAny> = /*undefined*/ null) {
		var _loc4_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc5_ = ASCompat.dynamicAs(null, IMap);
		var _loc6_ = ASCompat.asString(null);
		var _loc7_:ASAny = ASCompat.dynamicAs(null, StringMap);
		if (config.keystrokePassword != null && (!key.get_useKeyCode() && key.get_key().charAt(0) == config.keystrokePassword.charAt(0))) {
			report("Error: KeyBind [" + key.get_key() + "] is conflicting with Console password.", 9);
			return;
		}
		if (fun == null) {
			cast(_binds, StringMap<Dynamic>).remove(key.get_key());
		} else {
			_loc4_ = ([fun, args] : Array<ASAny>);
			_loc5_ = _binds;
			_loc6_ = key.get_key();
			_loc7_ = _loc5_;
			{
				_loc7_.set(_loc6_, _loc4_);
			}
		}
	}
}
