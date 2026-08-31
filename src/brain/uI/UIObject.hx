package brain.uI;

import brain.clock.GameClock;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.workLoop.DoLater;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;

class UIObject {
	static inline final DEFAULT_TOOLTIP_DELAY:Float = 0;

	static inline final DEFAULT_TOOLTIP_LAYER = 107;

	static inline final NAVIGATION_UP = "UP";

	static inline final NAVIGATION_DOWN = "DOWN";

	static inline final NAVIGATION_LEFT = "LEFT";

	static inline final NAVIGATION_RIGHT = "RIGHT";

	static inline final NAVIGATION_SELECTED = "SELECTED";

	static inline final NAVIGATION_SET_TO_UNSELECTED = "SET_TO_UNSELECTED";

	var mEnabled:Bool = true;

	var mFacade:Facade;

	var mRoot:MovieClip;

	var mTooltip:MovieClip;

	var mTooltipLabel:TextField;

	var mTooltipPos:Point = new Point();

	var mTooltipDelay:Float = 0;

	var mTooltipTask:DoLater;

	var mTooltipLayer:Float = 107;

	var mDontKillMyChildren:Bool = false;

	var mIsParentedToStage:Bool = false;

	var mNavigationDictionary:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mNavigationAdditionalInteraction:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mIsFocused:Bool = false;

	public function new(facade:Facade, root:MovieClip, tooltipDrawLayer:Int = 0, dontKillChildren:Bool = false) {
		mFacade = facade;
		mRoot = root;
		if ((mRoot : ASAny).hasOwnProperty("tooltip")) {
			if (tooltipDrawLayer != 0) {
				mTooltipLayer = tooltipDrawLayer;
			}
			this.tooltip = ASCompat.dynamicAs((mRoot : ASAny).tooltip, flash.display.MovieClip);
		}
		try {
			ASCompat.setProperty(mRoot, "UIObject", this);
		} catch (errObject:Dynamic) {}
		this.enabled = true;
		mDontKillMyChildren = dontKillChildren;
		mIsParentedToStage = false;
	}

	public static function scaleToFit(icon:DisplayObject, pixelSize:Float) {
		icon.scaleX = icon.scaleY = 1;
		var _loc4_ = icon.height > icon.width ? icon.height : icon.width;
		var _loc5_ = pixelSize / _loc4_;
		icon.scaleX = icon.scaleY = _loc5_;
		var _loc3_ = icon.getBounds(icon);
		icon.x = -(_loc3_.left + _loc3_.width * 0.5);
		icon.y = -(_loc3_.top + _loc3_.height * 0.5);
	}

	public function handleDrop(dropObject:UIObject):Bool {
		return false;
	}

	@:isVar public var visible(get, set):Bool;

	public function set_visible(value:Bool):Bool {
		return mRoot.visible = value;
	}

	function get_visible():Bool {
		return mRoot.visible;
	}

	@:isVar public var enabled(get, set):Bool;

	public function get_enabled():Bool {
		return mEnabled;
	}

	function set_enabled(value:Bool):Bool {
		mEnabled = value;
		hideTooltip();
		removeListeners();
		if (mEnabled) {
			addListeners();
		}
		return value;
	}

	function addListeners() {
		mRoot.addEventListener("rollOver", onRollOver);
		mRoot.addEventListener("rollOut", onRollOut);
	}

	public function setFocused(focused:Bool) {
		if (mIsFocused != focused) {
			mIsFocused = focused;
			if (mIsFocused) {
				onFocused();
			} else {
				onUnfocused();
			}
		}
	}

	function onFocused() {
		onRollOver(null);
	}

	function onUnfocused() {
		onRollOut(null);
	}

	public function onSelected() {}

	function removeListeners() {
		mRoot.removeEventListener("rollOver", onRollOver);
		mRoot.removeEventListener("rollOut", onRollOut);
	}

	function onRollOver(event:MouseEvent) {
		hideTooltip();
		if (mTooltip != null) {
			if (mTooltipDelay == 0) {
				showTooltip();
			} else {
				mTooltipTask = mFacade.preRenderWorkManager.doLater(mTooltipDelay, showTooltip, false, "UIObject.tooltip");
			}
		}
	}

	function onRollOut(event:MouseEvent) {
		hideTooltip();
	}

	public function bringToFront() {
		mRoot.parent.setChildIndex(mRoot, mRoot.parent.numChildren - 1);
	}

	public function sendToBack() {
		mRoot.parent.setChildIndex(mRoot, 0);
	}

	public function detach() {
		if (mRoot.parent != null) {
			mRoot.parent.removeChild(mRoot);
		}
	}

	@:isVar public var root(get, never):MovieClip;

	public function get_root():MovieClip {
		return mRoot;
	}

	@:isVar public var tooltipPos(never, set):Point;

	public function set_tooltipPos(value:Point):Point {
		return mTooltipPos = value;
	}

	public function setTooltipToBeParentedToStage() {
		mIsParentedToStage = true;
	}

	@:isVar public var tooltip(get, set):MovieClip;

	public function get_tooltip():MovieClip {
		return mTooltip;
	}

	@:isVar public var tooltipLabel(get, never):TextField;

	public function get_tooltipLabel():TextField {
		return mTooltipLabel;
	}

	function set_tooltip(value:MovieClip):MovieClip {
		setTooltip(value);
		return value;
	}

	public function setTooltip(value:ASAny) {
		hideTooltip();
		if (Std.isOfType(value, MovieClip)) {
			mTooltip = ASCompat.dynamicAs(value, MovieClip);
			mTooltipLabel = null;
		} else if (Std.isOfType(value, TextField)) {
			mTooltip = new MovieClip();
			mTooltipLabel = ASCompat.dynamicAs(value, TextField);
			mTooltip.addChild(mTooltipLabel);
		} else if (Std.isOfType(value, String)) {
			mTooltip = new MovieClip();
			mTooltipLabel = new TextField();
			mTooltipLabel.text = ASCompat.asString(value);
			mTooltipLabel.autoSize = "center";
			mTooltipLabel.background = true;
			mTooltipLabel.backgroundColor = (0 : UInt);
			mTooltipLabel.textColor = (16777215 : UInt);
			mTooltip.addChild(mTooltipLabel);
		} else if (value == null) {
			if (mTooltip != null && mTooltip.parent != null) {
				mTooltip.parent.removeChild(mTooltip);
			}
			if (mTooltipLabel != null && mTooltipLabel.parent != null) {
				mTooltipLabel.parent.removeChild(mTooltipLabel);
			}
			mTooltipLabel = null;
			mTooltip = null;
		} else {
			Logger.error("invalid tooltip type: " + Std.string(value));
		}
		if (mTooltip != null) {
			mTooltip.mouseChildren = false;
			mTooltip.mouseEnabled = false;
			this.tooltipPos = new Point(mTooltip.x, mTooltip.y);
			if (mTooltip.parent != null) {
				mTooltip.parent.removeChild(mTooltip);
			}
		}
	}

	@:isVar public var tooltipDelay(never, set):Float;

	public function set_tooltipDelay(value:Float):Float {
		return mTooltipDelay = value;
	}

	function hideTooltip() {
		if (mTooltipTask != null) {
			mTooltipTask.destroy();
		}
		if (mTooltip != null && mTooltip.parent != null) {
			mTooltip.parent.removeChild(mTooltip);
		}
	}

	function showTooltip(gameClock:GameClock = null) {
		var _loc2_:Point = null;
		if (mTooltip != null) {
			if (!mIsParentedToStage) {
				_loc2_ = root.localToGlobal(mTooltipPos);
				mTooltip.x = _loc2_.x;
				mTooltip.y = _loc2_.y;
			} else {
				mTooltip.x = mTooltipPos.x;
				mTooltip.y = mTooltipPos.y;
			}
			mFacade.sceneGraphManager.addChild(mTooltip, Std.int(mTooltipLayer));
		}
	}

	@:isVar public var dontKillMyChildren(never, set):Bool;

	public function set_dontKillMyChildren(haveMercy:Bool):Bool {
		return mDontKillMyChildren = haveMercy;
	}

	public function destroy() {
		if (mRoot != null) {
			if ((mRoot : ASAny).hasOwnProperty("UIObject")) {
				ASCompat.setProperty(mRoot, "UIObject", null);
			}
			hideTooltip();
			removeListeners();
			if (!mDontKillMyChildren) {
				while (mRoot.numChildren > 0) {
					mRoot.removeChildAt(0);
				}
			}
			mNavigationDictionary = null;
			mRoot = null;
			mFacade = null;
		}
	}

	public function canBeFocused():Bool {
		return enabled && visible;
	}

	public function isFocused():Bool {
		return mIsFocused;
	}

	public function setRootMovieClipAsBitMap() {
		mRoot.cacheAsBitmap = true;
	}

	public function isToTheLeftOf(rightUiObject:UIObject) {
		this.rightNavigation = rightUiObject;
		rightUiObject.leftNavigation = this;
	}

	public function isAbove(bottomUiObject:UIObject) {
		this.downNavigation = bottomUiObject;
		bottomUiObject.upNavigation = this;
	}

	@:isVar public var leftNavigation(get, set):UIObject;

	public function get_leftNavigation():UIObject {
		return ASCompat.dynamicAs(mNavigationDictionary["LEFT"], UIObject);
	}

	@:isVar public var rightNavigation(get, set):UIObject;

	public function get_rightNavigation():UIObject {
		return ASCompat.dynamicAs(mNavigationDictionary["RIGHT"], UIObject);
	}

	@:isVar public var upNavigation(get, set):UIObject;

	public function get_upNavigation():UIObject {
		return ASCompat.dynamicAs(mNavigationDictionary["UP"], UIObject);
	}

	@:isVar public var downNavigation(get, set):UIObject;

	public function get_downNavigation():UIObject {
		return ASCompat.dynamicAs(mNavigationDictionary["DOWN"], UIObject);
	}

	function set_leftNavigation(leftUiObject:UIObject):UIObject {
		if (mNavigationDictionary["LEFT"] == leftUiObject) {
			Logger.warnch("UI", "Navigation left already set to same target on: " + this.mRoot.name);
			return leftUiObject;
		}
		if (ASCompat.dictionaryLookupNeNull(mNavigationDictionary, "LEFT")) {
			throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate left towards: "
				+ Std.string(mNavigationDictionary["LEFT"].mRoot.name));
		}
		mNavigationDictionary["LEFT"] = leftUiObject;
		return leftUiObject;
	}

	function set_rightNavigation(rightUiObject:UIObject):UIObject {
		if (mNavigationDictionary["RIGHT"] == rightUiObject) {
			Logger.warnch("UI", "Navigation right already set to same target on: " + this.mRoot.name);
			return rightUiObject;
		}
		if (ASCompat.dictionaryLookupNeNull(mNavigationDictionary, "RIGHT")) {
			throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate right towards: "
				+ Std.string(mNavigationDictionary["RIGHT"].mRoot.name));
		}
		mNavigationDictionary["RIGHT"] = rightUiObject;
		return rightUiObject;
	}

	function set_upNavigation(upUiObject:UIObject):UIObject {
		if (mNavigationDictionary["UP"] == upUiObject) {
			Logger.warnch("UI", "Navigation up already set to same target on: " + this.mRoot.name);
			return upUiObject;
		}
		if (ASCompat.dictionaryLookupNeNull(mNavigationDictionary, "UP")) {
			throw new Error("This UIObject ("
				+ this.mRoot.name
				+ ") can already navigate up towards: "
				+ Std.string(mNavigationDictionary["UP"].mRoot.name));
		}
		mNavigationDictionary["UP"] = upUiObject;
		return upUiObject;
	}

	function set_downNavigation(downUiObject:UIObject):UIObject {
		if (mNavigationDictionary["DOWN"] == downUiObject) {
			Logger.warnch("UI", "Navigation down already set to same target on: " + this.mRoot.name);
			return downUiObject;
		}
		if (ASCompat.dictionaryLookupNeNull(mNavigationDictionary, "DOWN")) {
			throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate down towards: "
				+ Std.string(mNavigationDictionary["DOWN"].mRoot.name));
		}
		mNavigationDictionary["DOWN"] = downUiObject;
		return downUiObject;
	}

	public function clearLeftNavigation() {
		mNavigationDictionary["LEFT"] = null;
	}

	public function clearRightNavigation() {
		mNavigationDictionary["RIGHT"] = null;
	}

	public function clearUpNavigation() {
		mNavigationDictionary["UP"] = null;
	}

	public function clearDownNavigation() {
		mNavigationDictionary["DOWN"] = null;
	}

	public function clearNavigationAndInteractions() {
		mNavigationDictionary["LEFT"] = null;
		mNavigationDictionary["RIGHT"] = null;
		mNavigationDictionary["UP"] = null;
		mNavigationDictionary["DOWN"] = null;
		mNavigationAdditionalInteraction["LEFT"] = null;
		mNavigationAdditionalInteraction["RIGHT"] = null;
		mNavigationAdditionalInteraction["UP"] = null;
		mNavigationAdditionalInteraction["DOWN"] = null;
		mNavigationAdditionalInteraction["SELECTED"] = null;
		mNavigationAdditionalInteraction["SET_TO_UNSELECTED"] = null;
	}

	@:isVar public var leftNavigationAdditionalInteraction(get, set):ASFunction;

	public function get_leftNavigationAdditionalInteraction():ASFunction {
		return ASCompat.asFunction(mNavigationAdditionalInteraction["LEFT"]);
	}

	@:isVar public var rightNavigationAdditionalInteraction(get, set):ASFunction;

	public function get_rightNavigationAdditionalInteraction():ASFunction {
		return ASCompat.asFunction(mNavigationAdditionalInteraction["RIGHT"]);
	}

	@:isVar public var upNavigationAdditionalInteraction(get, set):ASFunction;

	public function get_upNavigationAdditionalInteraction():ASFunction {
		return ASCompat.asFunction(mNavigationAdditionalInteraction["UP"]);
	}

	@:isVar public var downNavigationAdditionalInteraction(get, set):ASFunction;

	public function get_downNavigationAdditionalInteraction():ASFunction {
		return ASCompat.asFunction(mNavigationAdditionalInteraction["DOWN"]);
	}

	@:isVar public var navigationSelectedInteraction(get, set):ASFunction;

	public function get_navigationSelectedInteraction():ASFunction {
		return ASCompat.asFunction(mNavigationAdditionalInteraction["SELECTED"]);
	}

	@:isVar public var navigationSetToUnselectedInteraction(get, set):ASFunction;

	public function get_navigationSetToUnselectedInteraction():ASFunction {
		return ASCompat.asFunction(mNavigationAdditionalInteraction["SET_TO_UNSELECTED"]);
	}

	function set_leftNavigationAdditionalInteraction(leftUiObjectInteraction:ASFunction):ASFunction {
		if (ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "LEFT")) {
			throw new Error("This UIObject ("
				+ this.mRoot.name
				+ ") already has an additional interaction:  "
				+ Std.string(mNavigationAdditionalInteraction["LEFT"].mRoot.name));
		}
		mNavigationAdditionalInteraction["LEFT"] = leftUiObjectInteraction;
		return leftUiObjectInteraction;
	}

	function set_rightNavigationAdditionalInteraction(rightUiObjectInteraction:ASFunction):ASFunction {
		if (ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "RIGHT")) {
			throw new Error("This UIObject ("
				+ this.mRoot.name
				+ ") already has an additional interaction:  "
				+ Std.string(mNavigationAdditionalInteraction["RIGHT"].mRoot.name));
		}
		mNavigationAdditionalInteraction["RIGHT"] = rightUiObjectInteraction;
		return rightUiObjectInteraction;
	}

	function set_upNavigationAdditionalInteraction(upUiObjectInteraction:ASFunction):ASFunction {
		if (ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "UP")) {
			throw new Error("This UIObject ("
				+ this.mRoot.name
				+ ") already has an additional interaction:  "
				+ Std.string(mNavigationAdditionalInteraction["UP"].mRoot.name));
		}
		mNavigationAdditionalInteraction["UP"] = upUiObjectInteraction;
		return upUiObjectInteraction;
	}

	function set_downNavigationAdditionalInteraction(downUiObjectInteraction:ASFunction):ASFunction {
		if (ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "DOWN")) {
			throw new Error("This UIObject ("
				+ this.mRoot.name
				+ ") already has an additional interaction: "
				+ Std.string(mNavigationAdditionalInteraction["DOWN"].mRoot.name));
		}
		mNavigationAdditionalInteraction["DOWN"] = downUiObjectInteraction;
		return downUiObjectInteraction;
	}

	function set_navigationSelectedInteraction(selectedUiObjectInteraction:ASFunction):ASFunction {
		if (ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "SELECTED")) {
			throw new Error("This UIObject ("
				+ this.mRoot.name
				+ ") already has a selected interaction: "
				+ Std.string(mNavigationAdditionalInteraction["SELECTED"].mRoot.name));
		}
		mNavigationAdditionalInteraction["SELECTED"] = selectedUiObjectInteraction;
		return selectedUiObjectInteraction;
	}

	function set_navigationSetToUnselectedInteraction(selectedUiObjectInteraction:ASFunction):ASFunction {
		if (ASCompat.dictionaryLookupNeNull(mNavigationAdditionalInteraction, "SET_TO_UNSELECTED")) {
			throw new Error("This UIObject ("
				+ this.mRoot.name
				+ ") already has an unselected interaction: "
				+ Std.string(mNavigationAdditionalInteraction["SET_TO_UNSELECTED"].mRoot.name));
		}
		mNavigationAdditionalInteraction["SET_TO_UNSELECTED"] = selectedUiObjectInteraction;
		return selectedUiObjectInteraction;
	}
}
