package input;

import brain.event.EventComponent;
import brain.input.*;
import brain.logger.Logger;
import brain.uI.UIObject;
import facade.DBFacade;
import steamInput.OnSteamInputButtonPressedEvent;
import steamInput.SteamInputManager;

class MenuNavigationController {
	static inline final MAX_NAVIGATION_ITERATIONS = (100 : UInt);

	var mTopLayer:UInt = (0 : UInt);

	var mUILayerConstants:Array<ASAny> = [];

	var mSelectedUIObjs:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mDefaultUIObjs:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mLayerExitCallbacks:ASDictionary<ASAny, ASAny> = new ASDictionary();

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
		mSteamInputActionsToKeyCodes["menu_left"] = 37;
		mSteamInputActionsToKeyCodes["menu_right"] = 39;
		mSteamInputActionsToKeyCodes["menu_up"] = 38;
		mSteamInputActionsToKeyCodes["menu_down"] = 40;
		mSteamInputActionsToKeyCodes["menu_select"] = 13;
		mSteamInputActionsToKeyCodes["menu_cancel"] = 27;
	}

	public function getTopUILayer():String {
		return mUILayerConstants[(mTopLayer : Int)];
	}

	public function pushNewLayer(layerConstant:String, layerExitCallback:ASFunction, defaultObject:UIObject, focusedObject:UIObject = null) {
		if (ASCompat.toBool(mDefaultUIObjs[layerConstant])
			|| ASCompat.toBool(mSelectedUIObjs[layerConstant])
			|| mUILayerConstants.indexOf(layerConstant) != -1) {
			Logger.warn("Layer constant " + layerConstant + " already exists in the UI Manager");
			return;
		}
		Logger.debugch("UI", "Pushing layer: " + layerConstant + " (Current Layers: " + getAllCurrentLayers() + ")");
		if (mFocusedUiObject != null) {
			mFocusedUiObject.setFocused(false);
		}
		mTopLayer = mTopLayer + 1;
		mUILayerConstants[(mTopLayer : Int)] = layerConstant;
		mLayerExitCallbacks[layerConstant] = layerExitCallback;
		mDefaultUIObjs[layerConstant] = defaultObject;
		if (focusedObject != null) {
			setFocusedUiObject(focusedObject);
		} else {
			setFocusedUiObject(defaultObject);
		}
		mDBFacade.steamInputManager.activateMenuControlsActionLayer();
	}

	public function popLayer(layerConstant:String) {
		if (layerConstant == null) {
			layerConstant = mUILayerConstants[(mTopLayer : Int)];
		}
		Logger.debugch("UI", "Popping layer: " + layerConstant + "(Current Layers: " + getAllCurrentLayers() + ")");
		if (mTopLayer == 0) {
			Logger.warn("No layers to pop");
			return;
		}
		if (mUILayerConstants[(mTopLayer : Int)] != layerConstant) {
			Logger.warn("You tried to pop a layer that wasn\'t currently the top one. Layer attempted to be popped (Layerconstant): "
				+ layerConstant
				+ " Actual Current Top Layer: "
				+ Std.string(mUILayerConstants[(mTopLayer : Int)]));
			return;
		}
		mDefaultUIObjs.remove(layerConstant);
		mSelectedUIObjs.remove(layerConstant);
		mLayerExitCallbacks.remove(layerConstant);
		mUILayerConstants.pop();
		mTopLayer = mTopLayer - 1;
		if (mTopLayer == 0) {
			mFocusedUiObject = null;
			mDBFacade.steamInputManager.activateInGameActionLayer();
			return;
		}
		if (ASCompat.dictionaryLookupNeNull(mSelectedUIObjs, mUILayerConstants[(mTopLayer : Int)])) {
			setFocusedUiObject(ASCompat.dynamicAs(mSelectedUIObjs[mUILayerConstants[(mTopLayer : Int)]], brain.uI.UIObject));
		} else {
			setFocusedUiObject(ASCompat.dynamicAs(mDefaultUIObjs[mUILayerConstants[(mTopLayer : Int)]], brain.uI.UIObject));
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

	public function setFocusedUiObject(uiObject:UIObject) {
		if (mTopLayer == 0) {
			Logger.warn("There\'s no UI Layer for you to set a Focused UIObject on because top layer is 0!");
			return;
		}
		if (uiObject == null) {
			Logger.warn("Cannot focus on a null UIObject");
			return;
		}
		if (mFocusedUiObject != uiObject) {
			if (mFocusedUiObject != null) {
				mFocusedUiObject.setFocused(false);
			}
			uiObject.setFocused(true);
			mFocusedUiObject = uiObject;
		} else if (!mFocusedUiObject.isFocused()) {
			mFocusedUiObject.setFocused(true);
		}
	}

	@:isVar var mFocusedUiObject(get, set):UIObject;

	function get_mFocusedUiObject():UIObject {
		return ASCompat.dynamicAs(mSelectedUIObjs[mUILayerConstants[(mTopLayer : Int)]], brain.uI.UIObject);
	}

	function set_mFocusedUiObject(uiObject:UIObject):UIObject {
		mSelectedUIObjs[mUILayerConstants[(mTopLayer : Int)]] = uiObject;
		return uiObject;
	}

	public function getNextAvailableNavLeftObject():UIObject {
		var _loc1_ = mFocusedUiObject.leftNavigation;
		var _loc2_ = (0 : UInt);
		while (_loc1_ != null && !_loc1_.canBeFocused()) {
			if (++_loc2_ >= 100) {
				Logger.warn("Menu navigation infinite loop detected traversing LEFT from layer: "
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
			if (++_loc2_ >= 100) {
				Logger.warn("Menu navigation infinite loop detected traversing RIGHT from layer: "
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
			if (++_loc2_ >= 100) {
				Logger.warn("Menu navigation infinite loop detected traversing UP from layer: "
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
			if (++_loc2_ >= 100) {
				Logger.warn("Menu navigation infinite loop detected traversing DOWN from layer: "
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
		final __ax4_iter_132 = mSteamInputActionsToKeyCodes;
		if (checkNullIteratee(__ax4_iter_132))
			for (_tmp_ in __ax4_iter_132.keys()) {
				_loc2_ = _tmp_;
				if (mSteamInputManager.pressedAction(_loc2_)) {
					onKeyPressed(ASCompat.toInt(mSteamInputActionsToKeyCodes[_loc2_]));
				}
			}
	}

	public function onKeyPressed(inputCode:Int) {
		var _loc2_:UIObject = null;
		if (mFocusedUiObject != null) {
			_loc2_ = null;
			if (inputCode == 37) {
				_loc2_ = getNextAvailableNavLeftObject();
				if (_loc2_ != null) {
					if (mFocusedUiObject.leftNavigationAdditionalInteraction != null) {
						mFocusedUiObject.leftNavigationAdditionalInteraction();
					}
					if (mFocusedUiObject.navigationSetToUnselectedInteraction != null) {
						mFocusedUiObject.navigationSetToUnselectedInteraction();
					}
					setFocusedUiObject(_loc2_);
					if (mFocusedUiObject.navigationSelectedInteraction != null) {
						mFocusedUiObject.navigationSelectedInteraction();
					}
				}
			} else if (inputCode == 39) {
				_loc2_ = getNextAvailableNavRightObject();
				if (_loc2_ != null) {
					if (mFocusedUiObject.rightNavigationAdditionalInteraction != null) {
						mFocusedUiObject.rightNavigationAdditionalInteraction();
					}
					if (mFocusedUiObject.navigationSetToUnselectedInteraction != null) {
						mFocusedUiObject.navigationSetToUnselectedInteraction();
					}
					setFocusedUiObject(_loc2_);
					if (mFocusedUiObject.navigationSelectedInteraction != null) {
						mFocusedUiObject.navigationSelectedInteraction();
					}
				}
			} else if (inputCode == 38) {
				_loc2_ = getNextAvailableNavUpObject();
				if (_loc2_ != null) {
					if (mFocusedUiObject.upNavigationAdditionalInteraction != null) {
						mFocusedUiObject.upNavigationAdditionalInteraction();
					}
					if (mFocusedUiObject.navigationSetToUnselectedInteraction != null) {
						mFocusedUiObject.navigationSetToUnselectedInteraction();
					}
					setFocusedUiObject(_loc2_);
					if (mFocusedUiObject.navigationSelectedInteraction != null) {
						mFocusedUiObject.navigationSelectedInteraction();
					}
				}
			} else if (inputCode == 40) {
				_loc2_ = getNextAvailableNavDownObject();
				if (_loc2_ != null) {
					if (mFocusedUiObject.downNavigationAdditionalInteraction != null) {
						mFocusedUiObject.downNavigationAdditionalInteraction();
					}
					if (mFocusedUiObject.navigationSetToUnselectedInteraction != null) {
						mFocusedUiObject.navigationSetToUnselectedInteraction();
					}
					setFocusedUiObject(_loc2_);
					if (mFocusedUiObject.navigationSelectedInteraction != null) {
						mFocusedUiObject.navigationSelectedInteraction();
					}
				}
			} else if (inputCode == 13) {
				if (mFocusedUiObject.enabled && mFocusedUiObject.visible) {
					mFocusedUiObject.onSelected();
				} else {
					Logger.debugch("UI",
						"Attempted to press UIObject when it was not enabled or visible (Enabled: "
						+ Std.string(mFocusedUiObject.enabled)
						+ " Visible: "
						+ Std.string(mFocusedUiObject.visible)
						+ ")");
				}
			} else if (inputCode == 27) {
				if (ASCompat.toBool(mLayerExitCallbacks[mUILayerConstants[(mTopLayer : Int)]])) {
					mLayerExitCallbacks[mUILayerConstants[(mTopLayer : Int)]]();
				}
			}
		}
	}
}
