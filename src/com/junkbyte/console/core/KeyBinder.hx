package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.KeyBind;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFieldType;

class KeyBinder extends ConsoleCore {
	var _passInd:Int = 0;

	var _binds:ASObject = {};

	var _warns:UInt = 0;

	public function new(console:Console) {
		super(console);
		console.cl.addCLCmd("keybinds", this.printBinds, "List all keybinds used");
	}

	public function bindKey(key:KeyBind, fun:ASFunction, args:Array<ASAny> = null) {
		if (ASCompat.stringAsBool(config.keystrokePassword)
			&& (!key.useKeyCode && key.key.charAt(0) == config.keystrokePassword.charAt(0))) {
			report("Error: KeyBind [" + key.key + "] is conflicting with Console password.", 9);
			return;
		}
		if (fun == null) {
			ASCompat.deleteProperty(this._binds, key.key);
		} else {
			this._binds[key.key] = ([fun, args] : Array<ASAny>);
		}
	}

	public function keyDownHandler(e:KeyboardEvent) {
		this.handleKeyEvent(e, false);
	}

	public function keyUpHandler(e:KeyboardEvent) {
		this.handleKeyEvent(e, true);
	}

	function handleKeyEvent(e:KeyboardEvent, isKeyUp:Bool) {
		var _loc4_:KeyBind = null;
		var _loc3_ = String.fromCharCode((e.charCode : Int));
		if (isKeyUp
			&& config.keystrokePassword != null
			&& ASCompat.stringAsBool(_loc3_)
			&& _loc3_ == config.keystrokePassword.substring(this._passInd, this._passInd + 1)) {
			++this._passInd;
			if (this._passInd >= config.keystrokePassword.length) {
				this._passInd = 0;
				if (this.canTrigger()) {
					if (console.visible && !console.panels.mainPanel.visible) {
						console.panels.mainPanel.visible = true;
					} else {
						console.visible = !console.visible;
					}
					if (console.visible && console.panels.mainPanel.visible) {
						console.panels.mainPanel.visible = true;
						console.panels.mainPanel.moveBackSafePosition();
					}
				} else if (this._warns < 3) {
					++this._warns;
					report("Password did not trigger because you have focus on an input TextField.", 8);
				}
			}
		} else {
			if (isKeyUp) {
				this._passInd = 0;
			}
			_loc4_ = new KeyBind(e.keyCode, e.shiftKey, e.ctrlKey, e.altKey, isKeyUp);
			this.tryRunKey(_loc4_.key);
			if (ASCompat.stringAsBool(_loc3_)) {
				_loc4_ = new KeyBind(_loc3_, e.shiftKey, e.ctrlKey, e.altKey, isKeyUp);
				this.tryRunKey(_loc4_.key);
			}
		}
	}

	function printBinds(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc3_:String = null;
		report("Key binds:", -2);
		var _loc2_ = (0 : UInt);
		final __ax4_iter_114:ASObject = this._binds;
		if (checkNullIteratee(__ax4_iter_114))
			for (_tmp_ in __ax4_iter_114.___keys()) {
				_loc3_ = _tmp_;
				_loc2_++;
				report(_loc3_, -2);
			}
		report("--- Found " + _loc2_, -2);
	}

	function tryRunKey(key:String) {
		var _loc2_:Array<ASAny> = ASCompat.dynamicAs(this._binds[key], Array);
		if (config.keyBindsEnabled && _loc2_ != null) {
			if (this.canTrigger()) {
				ASCompatMacro.applyClosure(ASCompat.asFunction(_loc2_[0]), _loc2_[1]);
			} else if (this._warns < 3) {
				++this._warns;
				report("Key bind [" + key + "] did not trigger because you have focus on an input TextField.", 8);
			}
		}
	}

	function canTrigger():Bool {
		var txt:TextField = null;
		try {
			if (console.stage != null && Std.isOfType(console.stage.focus, TextField)) {
				txt = ASCompat.reinterpretAs(console.stage.focus, TextField);
				if (txt.type == TextFieldType.INPUT) {
					return false;
				}
			}
		} catch (err:Dynamic) {}
		return true;
	}
}
