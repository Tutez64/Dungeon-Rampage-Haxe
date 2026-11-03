package uI.training;

import brain.facade.Facade;
import brain.uI.UIButton;
import dBGlobals.DBGlobal;
import flash.display.MovieClip;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

class UIStatUpgradeButton extends UIButton {
	var mUpgradeEnabled:Bool = true;

	public function new(facade:Facade, root:MovieClip) {
		super(facade, root);
	}

	@:isVar public var upgradeEnabled(get, set):Bool;

	public function get_upgradeEnabled():Bool {
		return mUpgradeEnabled;
	}

	override public function canBeFocused():Bool {
		return visible;
	}

	function set_upgradeEnabled(value:Bool):Bool {
		mUpgradeEnabled = value;
		mRoot.buttonMode = value;
		refreshVisualState();
		if (value && (mIsHovered || mIsFocused)) {
			DBGlobal.highlightButton(this);
		} else if (!value) {
			DBGlobal.unHighlightButton(this);
		}
		return value;
	}

	override function refreshVisualState() {
		if (mRoot == null) {
			return;
		}
		if (!mUpgradeEnabled) {
			showState((3 : UInt));
			return;
		}
		super.refreshVisualState();
	}

	override function onPress(event:MouseEvent) {
		if (!mUpgradeEnabled) {
			event.stopImmediatePropagation();
			return;
		}
		super.onPress(event);
	}

	override function onRollOver(event:MouseEvent) {
		super.onRollOver(event);
		if (mUpgradeEnabled) {
			DBGlobal.highlightButton(this);
		}
	}

	override function onRollOut(event:MouseEvent) {
		super.onRollOut(event);
		DBGlobal.unHighlightButton(this);
	}

	override function onKey(event:KeyboardEvent) {
		if (!mUpgradeEnabled) {
			event.stopImmediatePropagation();
			return;
		}
		super.onKey(event);
	}

	override public function click() {
		if (mUpgradeEnabled) {
			super.click();
		}
	}

	override public function onSelected(fromController:Bool = false) {
		if (mUpgradeEnabled) {
			super.onSelected(fromController);
		}
	}
}
