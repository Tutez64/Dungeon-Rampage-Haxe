package input;

import brain.event.EventComponent;
import brain.input.*;
import brain.logger.Logger;
import brain.uI.UIObject;
import facade.DBFacade;
import steamInput.OnSteamInputButtonPressedEvent;
import steamInput.OnSteamInputButtonReleasedEvent;
import steamInput.RumbleEffect;
import steamInput.SteamInputManager;

class MenuNavigationController {
	static inline final MAX_NAVIGATION_ITERATIONS = (150 : UInt);

	static var RETURN_LAYERS:Array<ASAny>;

	var mTopLayer:UInt = (0 : UInt);

	var mUILayerConstants:Array<ASAny> = [];

	var mSelectedUIObjs:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mDefaultUIObjs:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mLayerExitCallbacks:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mLayerPreviousCategoryCallbacks:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mLayerNextCategoryCallbacks:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mSteamInputActionsToKeyCodes:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mDBFacade:DBFacade;

	var mSteamInputManager:SteamInputManager;

	var mEventComponent:EventComponent;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		mDBFacade.inputManager.registerMenuNavigationCallback(onKeyPressed);
		mSteamInputManager = mDBFacade.steamInputManager;
		mEventComponent = new EventComponent(mDBFacade);
		mEventComponent.addListener("OnSteamInputButtonPressedEvent", onSteamInputButtonPressed);
		mEventComponent.addListener("OnSteamInputButtonReleasedEvent", onSteamInputButtonReleased);
		UIObject.mouseFocusRequestHandler = onMouseRequestedFocus;
		mSteamInputActionsToKeyCodes["menu_left"] = 37;
		mSteamInputActionsToKeyCodes["menu_right"] = 39;
		mSteamInputActionsToKeyCodes["menu_up"] = 38;
		mSteamInputActionsToKeyCodes["menu_down"] = 40;
		mSteamInputActionsToKeyCodes["menu_select"] = 13;
		mSteamInputActionsToKeyCodes["menu_cancel"] = 27;
		mSteamInputActionsToKeyCodes["menu_previous_category"] = 81;
		mSteamInputActionsToKeyCodes["menu_next_category"] = 69;
		syncSteamInputActionSet();
	}

	public function getTopUILayer():String {
		return mUILayerConstants[(mTopLayer : Int)];
	}

	public function setLayerCategoryCallbacks(previousCategoryCallback:ASFunction, nextCategoryCallback:ASFunction, ownerLayer:String = null) {
		if (mTopLayer == 0 && ownerLayer == null) {
			return;
		}
		var _loc4_:String = ownerLayer ?? mUILayerConstants[(mTopLayer : Int)];
		if (mUILayerConstants.indexOf(_loc4_) == -1) {
			return;
		}
		mLayerPreviousCategoryCallbacks[_loc4_] = previousCategoryCallback;
		mLayerNextCategoryCallbacks[_loc4_] = nextCategoryCallback;
	}

	public function pushNewLayer(layerConstant:String, layerExitCallback:ASFunction, defaultObject:UIObject, focusedObject:UIObject = null,
			previousCategoryCallback:ASFunction = null, nextCategoryCallback:ASFunction = null) {
		if (ASCompat.toBool(ASDictionary.getString(mDefaultUIObjs, layerConstant))
			|| ASCompat.toBool(ASDictionary.getString(mSelectedUIObjs, layerConstant))
			|| mUILayerConstants.indexOf(layerConstant) != -1) {
			Logger.debugch("UI", "Layer constant " + layerConstant + " already exists in the UI Manager");
			return;
		}
		Logger.debugch("UI", "Pushing layer: " + layerConstant + " (Current Layers: " + getAllCurrentLayers() + ")");
		if (mFocusedUiObject != null) {
			mFocusedUiObject.setFocused(false);
		}
		mTopLayer = mTopLayer + 1;
		mUILayerConstants[(mTopLayer : Int)] = layerConstant;
		mLayerExitCallbacks[layerConstant] = layerExitCallback;
		mLayerPreviousCategoryCallbacks[layerConstant] = previousCategoryCallback;
		mLayerNextCategoryCallbacks[layerConstant] = nextCategoryCallback;
		mDefaultUIObjs[layerConstant] = defaultObject;
		if (focusedObject != null && focusedObject.canBeFocused()) {
			setFocusedUiObject(focusedObject);
		} else {
			setFocusedUiObject(defaultObject);
		}
		syncSteamInputActionSet();
	}

	public function popLayer(layerConstant:String) {
		if (layerConstant == null) {
			layerConstant = mUILayerConstants[(mTopLayer : Int)];
		}
		if (mTopLayer == 0) {
			Logger.debugch("UI", "No layers to pop");
			return;
		}
		if (mUILayerConstants[(mTopLayer : Int)] != layerConstant) {
			Logger.debugch("UI",
				"You tried to pop a layer that wasn\'t currently the top one. Layer attempted to be popped (Layerconstant): "
				+ layerConstant
				+ " Actual Current Top Layer: "
				+ Std.string(mUILayerConstants[(mTopLayer : Int)]));
			return;
		}
		removeLayer(layerConstant);
	}

	public function removeLayer(layerConstant:String) {
		var _loc4_ = mUILayerConstants.indexOf(layerConstant);
		if (_loc4_ < 1) {
			return;
		}
		var _loc3_ = (_loc4_ : UInt) == mTopLayer;
		Logger.debugch("UI", (_loc3_ ? "Popping layer: " : "Removing layer: ")
			+ layerConstant
			+ " (Current Layers: "
			+ getAllCurrentLayers()
			+ ")");
		var _loc2_ = ASCompat.coerce(ASDictionary.getString(mSelectedUIObjs, layerConstant), brain.uI.UIObject);
		if (_loc2_ != null) {
			_loc2_.setFocused(false);
		}
		mDefaultUIObjs.remove(layerConstant);
		mSelectedUIObjs.remove(layerConstant);
		mLayerExitCallbacks.remove(layerConstant);
		mLayerPreviousCategoryCallbacks.remove(layerConstant);
		mLayerNextCategoryCallbacks.remove(layerConstant);
		mUILayerConstants.splice(_loc4_, (1 : UInt));
		mTopLayer = mTopLayer - 1;
		if (!_loc3_) {
			return;
		}
		syncSteamInputActionSet();
		if (mTopLayer == 0) {
			mFocusedUiObject = null;
			return;
		}
		if (ASCompat.dictionaryLookupNeNull(mSelectedUIObjs, mUILayerConstants[(mTopLayer : Int)])) {
			setFocusedUiObject(ASCompat.coerce(mSelectedUIObjs[mUILayerConstants[(mTopLayer : Int)]], brain.uI.UIObject));
		} else {
			setFocusedUiObject(ASCompat.coerce(mDefaultUIObjs[mUILayerConstants[(mTopLayer : Int)]], brain.uI.UIObject));
		}
	}

	function syncSteamInputActionSet() {
		if (mTopLayer > 0) {
			mSteamInputManager.activateMenuControlsActionLayer();
		} else {
			mSteamInputManager.activateInGameActionLayer();
		}
	}

	public function getAllCurrentLayers():String {
		var _loc2_ = 0;
		var _loc1_ = "";
		_loc2_ = 1;
		while (_loc2_ < mUILayerConstants.length) {
			_loc1_ += Std.string(mUILayerConstants[_loc2_]) + ", ";
			_loc2_++;
		}
		return _loc1_;
	}

	@:isVar public var layerDepth(get, never):UInt;

	public function get_layerDepth():UInt {
		return mTopLayer;
	}

	@:isVar public var focusedUiObject(get, never):UIObject;

	public function get_focusedUiObject():UIObject {
		return mTopLayer == 0 ? null : mFocusedUiObject;
	}

	public function setFocusedUiObject(uiObject:UIObject, fromControllerNavigation:Bool = false) {
		if (mTopLayer == 0) {
			Logger.debugch("UI", "There\'s no UI Layer for you to set a Focused UIObject on because top layer is 0!");
			return;
		}
		if (uiObject == null) {
			Logger.debugch("UI", "Cannot focus on a null UIObject");
			return;
		}
		if (mFocusedUiObject != uiObject) {
			if (mFocusedUiObject != null) {
				if (mFocusedUiObject.navigationSetToUnselectedInteraction != null) {
					mFocusedUiObject.navigationSetToUnselectedInteraction();
				}
				mFocusedUiObject.setFocused(false);
			}
			uiObject.setFocused(true);
			mFocusedUiObject = uiObject;
			if (fromControllerNavigation) {
				mSteamInputManager.playRumble(RumbleEffect.MENU_SELECTION);
			}
		} else if (!mFocusedUiObject.isFocused()) {
			mFocusedUiObject.setFocused(true);
		}
	}

	function onMouseRequestedFocus(uiObject:UIObject) {
		if (mTopLayer == 0 || uiObject == null || !uiObject.canBeFocused()) {
			return;
		}
		if (!isInCurrentNavigationLayer(uiObject)) {
			return;
		}
		mSteamInputManager.playRumble(RumbleEffect.MENU_SELECTION);
		if (mFocusedUiObject == uiObject) {
			return;
		}
		setFocusedUiObject(uiObject);
	}

	public function isInCurrentNavigationLayer(target:UIObject):Bool {
		return collectCurrentLayerObjects().indexOf(target) != -1;
	}

	public function collectCurrentLayerObjects():Array<ASAny> {
		var _loc1_:UIObject;
		var _loc7_:UIObject = null;
		var _loc4_:UIObject = null;
		var _loc8_:Array<ASAny> = null;
		var _loc10_:Array<ASAny> = [];
		if (mTopLayer == 0) {
			return _loc10_;
		}
		var _loc2_:String = mUILayerConstants[(mTopLayer : Int)];
		var _loc5_:Array<ASAny> = [
			ASDictionary.getString(mSelectedUIObjs, _loc2_),
			ASDictionary.getString(mDefaultUIObjs, _loc2_)
		];
		var _loc6_ = new ASDictionary<ASAny, ASAny>(true);
		var _loc3_:Array<ASAny> = [];
		if (checkNullIteratee(_loc5_))
			for (_tmp_ in _loc5_) {
				_loc7_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
				if (_loc7_ != null && !ASCompat.toBool(_loc6_[_loc7_])) {
					_loc6_[_loc7_] = true;
					_loc3_.push(_loc7_);
				}
			}
		var _loc9_ = (0 : UInt);
		while (_loc3_.length > 0) {
			if (++_loc9_ >= 150) {
				Logger.debugch("UI",
					"Menu navigation graph too large while walking layer: "
					+ getTopUILayer()
					+ " (Current Layers: "
					+ getAllCurrentLayers()
					+ ")");
				break;
			}
			_loc4_ = ASCompat.dynamicAs(_loc3_.shift(), UIObject);
			_loc10_.push(_loc4_);
			_loc8_ = [
				_loc4_.leftNavigation,
				_loc4_.rightNavigation,
				_loc4_.upNavigation,
				_loc4_.downNavigation
			];
			if (checkNullIteratee(_loc8_))
				for (_tmp_ in _loc8_) {
					_loc1_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
					if (_loc1_ != null && !ASCompat.toBool(_loc6_[_loc1_])) {
						_loc6_[_loc1_] = true;
						_loc3_.push(_loc1_);
					}
				}
		}
		return _loc10_;
	}

	public function replaceLayerUIObjects(param1:String, param2:UIObject, param3:UIObject = null) {
		var layerConstant = param1;
		var defaultUiObject = param2;
		var selectedUiObject = param3;
		if (layerConstant == null || mUILayerConstants.indexOf(layerConstant) == -1) {
			Logger.warn("Cannot replace UI objects for a layer that does not exist: " + Std.string(layerConstant));
			return;
		}
		mDefaultUIObjs[layerConstant] = defaultUiObject;
		mSelectedUIObjs[layerConstant] = selectedUiObject != null ? selectedUiObject : defaultUiObject;
	}

	@:isVar var mFocusedUiObject(get, set):UIObject;

	function get_mFocusedUiObject():UIObject {
		return ASCompat.coerce(mSelectedUIObjs[mUILayerConstants[(mTopLayer : Int)]], brain.uI.UIObject);
	}

	function set_mFocusedUiObject(uiObject:UIObject):UIObject {
		mSelectedUIObjs[mUILayerConstants[(mTopLayer : Int)]] = uiObject;
		return uiObject;
	}

	public function getNextAvailableNavLeftObject():UIObject {
		var _loc1_ = mFocusedUiObject.leftNavigation;
		var _loc2_ = (0 : UInt);
		while (_loc1_ != null && !_loc1_.canBeFocused()) {
			if (++_loc2_ >= 150) {
				Logger.debugch("UI",
					"Menu navigation infinite loop detected traversing LEFT from layer: "
					+ getTopUILayer()
					+ " (Current Layers: "
					+ getAllCurrentLayers()
					+ ")");
				return mFocusedUiObject;
			}
			_loc1_ = _loc1_.leftNavigation;
		}
		if (_loc1_ != null) {
			return _loc1_;
		}
		return mFocusedUiObject;
	}

	public function getNextAvailableNavRightObject():UIObject {
		var _loc1_ = mFocusedUiObject.rightNavigation;
		var _loc2_ = (0 : UInt);
		while (_loc1_ != null && !_loc1_.canBeFocused()) {
			if (++_loc2_ >= 150) {
				Logger.debugch("UI",
					"Menu navigation infinite loop detected traversing RIGHT from layer: "
					+ getTopUILayer()
					+ " (Current Layers: "
					+ getAllCurrentLayers()
					+ ")");
				return mFocusedUiObject;
			}
			_loc1_ = _loc1_.rightNavigation;
		}
		if (_loc1_ != null) {
			return _loc1_;
		}
		return mFocusedUiObject;
	}

	public function getNextAvailableNavUpObject():UIObject {
		var _loc1_ = mFocusedUiObject.upNavigation;
		var _loc2_ = (0 : UInt);
		while (_loc1_ != null && !_loc1_.canBeFocused()) {
			if (++_loc2_ >= 150) {
				Logger.debugch("UI",
					"Menu navigation infinite loop detected traversing UP from layer: "
					+ getTopUILayer()
					+ " (Current Layers: "
					+ getAllCurrentLayers()
					+ ")");
				return mFocusedUiObject;
			}
			_loc1_ = _loc1_.upNavigation;
		}
		if (_loc1_ != null) {
			return _loc1_;
		}
		return mFocusedUiObject;
	}

	public function getNextAvailableNavDownObject():UIObject {
		var _loc1_ = mFocusedUiObject.downNavigation;
		var _loc2_ = (0 : UInt);
		while (_loc1_ != null && !_loc1_.canBeFocused()) {
			if (++_loc2_ >= 150) {
				Logger.debugch("UI",
					"Menu navigation infinite loop detected traversing DOWN from layer: "
					+ getTopUILayer()
					+ " (Current Layers: "
					+ getAllCurrentLayers()
					+ ")");
				return mFocusedUiObject;
			}
			_loc1_ = _loc1_.downNavigation;
		}
		if (_loc1_ != null) {
			return _loc1_;
		}
		return mFocusedUiObject;
	}

	function onSteamInputButtonPressed(eventData:OnSteamInputButtonPressedEvent) {
		var _loc2_:String;
		final __ax4_iter_447 = mSteamInputActionsToKeyCodes;
		if (checkNullIteratee(__ax4_iter_447))
			for (_tmp_ in __ax4_iter_447.keys()) {
				_loc2_ = _tmp_;
				if (mSteamInputManager.pressedAction(_loc2_)) {
					onKeyPressed(ASCompat.toInt(ASDictionary.getString(mSteamInputActionsToKeyCodes, _loc2_)), true);
				}
			}
	}

	function onSteamInputButtonReleased(eventData:OnSteamInputButtonReleasedEvent) {
		if (eventData.actionName != "menu_return") {
			return;
		}
		var _loc2_:String = mUILayerConstants[(mTopLayer : Int)];
		if (RETURN_LAYERS.indexOf(_loc2_) != -1 && ASCompat.toBool(ASDictionary.getString(mLayerExitCallbacks, _loc2_))) {
			ASDictionary.getString(mLayerExitCallbacks, _loc2_)();
		}
	}

	public function onKeyPressed(inputCode:Int, fromController:Bool = false) {
		var _loc5_:UIObject = null;
		var _loc4_:UIObject = null;
		var _loc3_:String = mUILayerConstants[(mTopLayer : Int)];
		if (mFocusedUiObject != null && mFocusedUiObject.root == null && inputCode != 27 && inputCode != 81 && inputCode != 69) {
			_loc5_ = ASCompat.coerce(ASDictionary.getString(mDefaultUIObjs, _loc3_), brain.uI.UIObject);
			if (_loc5_ != null && _loc5_.root != null) {
				setFocusedUiObject(_loc5_);
			}
			return;
		}
		if (inputCode == 81) {
			if (ASCompat.dictionaryLookupNeNull(mLayerPreviousCategoryCallbacks, _loc3_)) {
				ASDictionary.getString(mLayerPreviousCategoryCallbacks, _loc3_)();
			}
			return;
		}
		if (inputCode == 69) {
			if (ASCompat.dictionaryLookupNeNull(mLayerNextCategoryCallbacks, _loc3_)) {
				ASDictionary.getString(mLayerNextCategoryCallbacks, _loc3_)();
			}
			return;
		}
		if (mFocusedUiObject != null) {
			_loc4_ = null;
			if (inputCode == 37) {
				_loc4_ = getNextAvailableNavLeftObject();
				if (_loc4_ != null) {
					if (mFocusedUiObject.leftNavigationAdditionalInteraction != null) {
						mFocusedUiObject.leftNavigationAdditionalInteraction();
					}
					setFocusedUiObject(_loc4_, fromController);
					if (mFocusedUiObject.navigationSelectedInteraction != null) {
						mFocusedUiObject.navigationSelectedInteraction();
					}
				}
			} else if (inputCode == 39) {
				_loc4_ = getNextAvailableNavRightObject();
				if (_loc4_ != null) {
					if (mFocusedUiObject.rightNavigationAdditionalInteraction != null) {
						mFocusedUiObject.rightNavigationAdditionalInteraction();
					}
					setFocusedUiObject(_loc4_, fromController);
					if (mFocusedUiObject.navigationSelectedInteraction != null) {
						mFocusedUiObject.navigationSelectedInteraction();
					}
				}
			} else if (inputCode == 38) {
				_loc4_ = getNextAvailableNavUpObject();
				if (_loc4_ != null) {
					if (mFocusedUiObject.upNavigationAdditionalInteraction != null) {
						mFocusedUiObject.upNavigationAdditionalInteraction();
					}
					setFocusedUiObject(_loc4_, fromController);
					if (mFocusedUiObject.navigationSelectedInteraction != null) {
						mFocusedUiObject.navigationSelectedInteraction();
					}
				}
			} else if (inputCode == 40) {
				_loc4_ = getNextAvailableNavDownObject();
				if (_loc4_ != null) {
					if (mFocusedUiObject.downNavigationAdditionalInteraction != null) {
						mFocusedUiObject.downNavigationAdditionalInteraction();
					}
					setFocusedUiObject(_loc4_, fromController);
					if (mFocusedUiObject.navigationSelectedInteraction != null) {
						mFocusedUiObject.navigationSelectedInteraction();
					}
				}
			} else if (inputCode == 13) {
				if (mFocusedUiObject.enabled && mFocusedUiObject.visible) {
					mFocusedUiObject.onSelected(fromController);
				} else {
					Logger.debugch("UI",
						"Attempted to press UIObject when it was not enabled or visible (Enabled: "
						+ Std.string(mFocusedUiObject.enabled)
						+ " Visible: "
						+ Std.string(mFocusedUiObject.visible)
						+ ")");
				}
			} else if (inputCode == 27) {
				if (fromController && _loc3_ == "REVIVE_MENU") {
					return;
				}
				if (ASCompat.toBool(mLayerExitCallbacks[mUILayerConstants[(mTopLayer : Int)]])) {
					mLayerExitCallbacks[mUILayerConstants[(mTopLayer : Int)]]();
				}
			}
		}
	}

	static function __init__() {
		RETURN_LAYERS = [
			"EXIT_DUNGEON",
			"EXIT_INFINITE_DUNGEON",
			"TOWN_MENU",
			"EXIT_POPUP",
			"REVIVE_MENU"
		];
	}
}
