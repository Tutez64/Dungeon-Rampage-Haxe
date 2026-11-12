package steamInput;

import brain.assetRepository.AssetLoader;
import brain.event.EventComponent;
import brain.logger.Logger;
import facade.DBFacade;
import com.amanitadesign.steam.FRESteamWorks;
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.geom.Vector3D;

class SteamInputManager {
	static inline final GAMEPAD_DEADZONE_TOLERANCE:Float = 0.05;

	var mDBFacade:DBFacade;

	var mSteamworks:FRESteamWorks;

	var mEventComponent:EventComponent;

	var mKeyboardEventSpoofer:KeyboardEventSpoofer;

	var mControllerRumble:ControllerRumble;

	var mLocalGlyphs:LocalSteamInputGlyphs = new LocalSteamInputGlyphs();

	var mLoggedGlyphOrigins:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mGlyphFilePathsByOrigin:Map<String, String> = new Map();

	var mIsInitialized:Bool = false;

	var mIsSteamInputManagerEnabled:Bool = false;

	var mControllerWasConnectedLastUpdate:Bool = false;

	var mHandlesToSteamControllers:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mConnectedSteamControllers:Vector<SteamController> = new Vector();

	var mLastActiveSteamController:SteamController;

	var mIsRunningOnSteamDeck:Bool = false;

	var mInGameControlsActionSet:SteamInputActionSet;

	var mMenuControlsActionSet:SteamInputActionSet;

	var mUseMenuControlsInsteadOfInGameControls:Bool = true;

	var mHasLoggedActionSetLoadFailure:Bool = false;

	var mActionManifestSetupHasRun:Bool = false;

	var mInputActionNameToControllerGlyphFilePath:ASDictionary<ASAny, ASAny> = new ASDictionary();

	final ZERO_VECTOR:Vector3D = new Vector3D(0, 0, 0);

	var mIsInActionSetWarningState:Bool = false;

	public function new(inDBFacade:DBFacade, inSteamworks:FRESteamWorks, stageRef:Stage, isSteamInputManagerEnabled:Bool = true) {
		mDBFacade = inDBFacade;
		mSteamworks = inSteamworks;
		mIsSteamInputManagerEnabled = isSteamInputManagerEnabled;
		mEventComponent = new EventComponent(inDBFacade);
		mControllerRumble = new ControllerRumble(inDBFacade, inSteamworks);
		mKeyboardEventSpoofer = new KeyboardEventSpoofer(stageRef, inDBFacade.keyBindings);
	}

	static function controllerHasActiveInput(steamController:SteamController):Bool {
		var _loc5_ = 0;
		var _loc4_ = steamController.heldDigitalButtons;
		var _loc2_:ASObject;
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_.keys()) {
				_loc2_ = _tmp_;
				return true;
			}
		var _loc3_:Vector3D;
		final __ax4_iter_105 = steamController.analogInputs;
		if (checkNullIteratee(__ax4_iter_105))
			for (_tmp_ in __ax4_iter_105) {
				_loc3_ = ASCompat.coerce(_tmp_, flash.geom.Vector3D);
				if (_loc3_ != null && _loc3_.lengthSquared > 0.05) {
					return true;
				}
			}
		return false;
	}

	static function pushActionOrigins(digitalActionOrigins:Vector<String>, origins:Array<ASAny>) {
		var _loc3_:ASObject;
		if (checkNullIteratee(origins))
			for (_tmp_ in origins) {
				_loc3_ = _tmp_;
				digitalActionOrigins.push(ASCompat.toString(_loc3_));
			}
	}

	public function destroy() {
		mControllerRumble.stopAll();
		mControllerRumble.update(mConnectedSteamControllers);
		mControllerRumble = null;
		mConnectedSteamControllers.length = 0;
		var _loc1_:ASObject;
		final __ax4_iter_106 = mHandlesToSteamControllers;
		if (checkNullIteratee(__ax4_iter_106))
			for (_tmp_ in __ax4_iter_106.keys()) {
				_loc1_ = _tmp_;
				mHandlesToSteamControllers.remove(_loc1_);
			}
		mHandlesToSteamControllers = null;
		if (mEventComponent != null) {
			mEventComponent.destroy();
			mEventComponent = null;
		}
		mSteamworks.steamInputShutdown();
	}

	public function runFrame() {
		if (!mIsSteamInputManagerEnabled) {
			return;
		}
		if (!mIsInitialized) {
			initSteamInput();
			return;
		}
		mSteamworks.runFrame();
		reconcileControllerStateAndNotify();
		updateControllers();
		var _loc1_ = updateLastActiveController();
		updateActionOrigins();
		mControllerRumble.update(mConnectedSteamControllers);
		mKeyboardEventSpoofer.update(this);
		if (_loc1_) {
			mDBFacade.mouseCursorManager.hideMouseCursor();
		}
		fireButtonEvents();
	}

	function updateLastActiveController():Bool {
		var _loc1_:SteamController;
		final __ax4_iter_107 = mConnectedSteamControllers;
		if (checkNullIteratee(__ax4_iter_107))
			for (_tmp_ in __ax4_iter_107) {
				_loc1_ = _tmp_;
				if (controllerHasActiveInput(_loc1_)) {
					mLastActiveSteamController = _loc1_;
					return true;
				}
			}
		return false;
	}

	@:isVar var glyphController(get, never):SteamController;

	function get_glyphController():SteamController {
		var _loc1_:SteamController;
		var __ax4_iter_108:Vector<SteamController>;
		if (mLastActiveSteamController != null && mConnectedSteamControllers.indexOf(mLastActiveSteamController) != -1) {
			return mLastActiveSteamController;
		}
		if (mConnectedSteamControllers.length == 0) {
			return null;
		}
		if (mIsRunningOnSteamDeck) {
			__ax4_iter_108 = mConnectedSteamControllers;
			if (checkNullIteratee(__ax4_iter_108))
				for (_tmp_ in __ax4_iter_108) {
					_loc1_ = _tmp_;
					if (mSteamworks.getInputTypeForHandle(_loc1_.controllerHandle) == 14) {
						return _loc1_;
					}
				}
		}
		return mConnectedSteamControllers[0];
	}

	function updateActionOrigins() {
		var _loc3_:String = null;
		var _loc6_:String = null;
		if (!isSteamInputReady) {
			return;
		}
		var _loc2_ = new ASDictionary<ASAny, ASAny>();
		var _loc5_ = false;
		var _loc1_:SteamInputAction;
		final __ax4_iter_109 = mMenuControlsActionSet.digitalActionHandles;
		if (checkNullIteratee(__ax4_iter_109))
			for (_tmp_ in __ax4_iter_109) {
				_loc1_ = _tmp_;
				_loc3_ = getFirstGlyphFilePathForDigitalAction(_loc1_.actionName);
				if (!mIsInActionSetWarningState) {
					if (_loc3_ == "error1") {
						_loc5_ = true;
						Logger.warnch("Input", "SteamInputManager: Couldn\'t load Menu actionSet \'" + _loc1_.actionName + "\'");
					}
				}
				_loc2_[_loc1_.actionName] = _loc3_;
			}
		var _loc4_:SteamInputAction;
		final __ax4_iter_110 = mInGameControlsActionSet.digitalActionHandles;
		if (checkNullIteratee(__ax4_iter_110))
			for (_tmp_ in __ax4_iter_110) {
				_loc4_ = _tmp_;
				_loc6_ = getFirstGlyphFilePathForDigitalAction(_loc4_.actionName);
				if (!mIsInActionSetWarningState) {
					if (_loc6_ == "error1") {
						_loc5_ = true;
						Logger.warnch("Input", "SteamInputManager: Couldn\'t load In-Game actionSet \'" + _loc4_.actionName + "\'");
					}
				}
				_loc2_[_loc4_.actionName] = _loc6_;
			}
		if (_loc5_) {
			mIsInActionSetWarningState = true;
		}
		if (!dictionariesHaveSameContents(mInputActionNameToControllerGlyphFilePath, _loc2_)) {
			mInputActionNameToControllerGlyphFilePath = _loc2_;
			mEventComponent.dispatchEvent(new SteamInputGlyphsChangedEvent());
		}
	}

	function getFirstGlyphFilePathForDigitalAction(inActionName:String):String {
		var _loc2_ = getFilePathsOfGlyphsAssignedToDigitalAction(inActionName);
		return _loc2_.length > 0 ? _loc2_[0] : null;
	}

	public function getFilePathsOfGlyphsAssignedToDigitalAction(inActionName:String, inGlyphSize:UInt = (1 : UInt),
			inGlyphFlag:UInt = (2 : UInt)):Vector<String> {
		var _loc4_ = getDigitalActionOriginsAssignedToControlsAction(inActionName);
		var _loc6_ = new Vector<String>();
		if (_loc4_ == null) {
			Logger.warnch("Input", "actionOrigins is null please ensure it\'s loaded properly.");
			return _loc6_;
		}
		var _loc5_:String;
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_) {
				_loc5_ = _tmp_;
				if (_loc5_ == null) {
					Logger.warnch("Input", "origin is null please ensure actionOrigins is loaded properly.");
					return _loc6_;
				}
				_loc6_.push(getGlyphFilePathForOrigin(_loc5_, inGlyphSize, inGlyphFlag));
			}
		return _loc6_;
	}

	public function getGlyphFilePathForOrigin(origin:String, glyphSize:UInt = (1 : UInt), glyphFlag:UInt = (2 : UInt)):String {
		// Asked for every action on every frame. Finding the file asks Steam and compiles regular
		// expressions, 2 ms a frame, and their memory brought a full collection every other second.
		var _loc7_ = origin + "|" + glyphSize + "|" + glyphFlag + "|" + getControllerGlyphPreference();
		var _loc8_ = mGlyphFilePathsByOrigin.get(_loc7_);
		if (_loc8_ == null) {
			_loc8_ = findGlyphFilePathForOrigin(origin, glyphSize, glyphFlag);
			mGlyphFilePathsByOrigin.set(_loc7_, _loc8_);
		}
		return _loc8_;
	}

	function findGlyphFilePathForOrigin(origin:String, glyphSize:UInt, glyphFlag:UInt):String {
		var _loc6_ = mSteamworks.getGlyphPNGForActionOrigin(origin, (glyphSize : Int), (glyphFlag : Int));
		var _loc4_ = getControllerGlyphPreference();
		var _loc5_ = mLocalGlyphs.getGlyphPath(_loc6_, _loc4_);
		if (_loc5_ != null) {
			logGlyphResolutionOnce(origin, "preferred \'" + _loc4_ + "\' glyph \'" + _loc5_ + "\'");
			return _loc5_;
		}
		logGlyphResolutionOnce(origin, "Steam fallback \'" + _loc6_ + "\' (preferred family: \'" + _loc4_ + "\')");
		return _loc6_;
	}

	function getControllerGlyphPreference():String {
		var _loc1_ = mDBFacade.dbConfigManager.getConfigString("ControllerGlyphPreference", "");
		if (_loc1_ != "") {
			return _loc1_;
		}
		var _loc2_ = glyphController;
		if (_loc2_ == null) {
			return "";
		}
		switch (mSteamworks.getInputTypeForHandle(_loc2_.controllerHandle) - 1) {
			case 0:
				return "Steam";
			case 1:
				return "Xbox 360";
			case 2:
				return "Xbox One";
			case 4:
				return "PS4";
			case 7 | 8 | 9:
				return "Switch";
			case 11:
				return "PS3";
			case 12:
				return "PS5";
			case 13:
				return "Steam Deck";
			default:
				return "";
		}
		return null;
	}

	function logGlyphResolutionOnce(origin:String, resolution:String) {
		if (ASCompat.toBool(ASDictionary.getString(mLoggedGlyphOrigins, origin))) {
			return;
		}
		mLoggedGlyphOrigins[origin] = true;
		Logger.infoch("Input", "SteamInputManager: Glyph origin \'" + origin + "\' resolved to " + resolution + ".");
	}

	public function getGlyphFilePathForAction(inActionName:String):String {
		if (ASCompat.dictionaryLookupEqNull(mInputActionNameToControllerGlyphFilePath, inActionName)
			|| ASDictionary.getString(mInputActionNameToControllerGlyphFilePath, inActionName) == "error1") {
			updateActionOrigins();
		}
		return ASDictionary.getString(mInputActionNameToControllerGlyphFilePath, inActionName);
	}

	public function getGlyphFilePathForAnalogAction(inActionName:String):String {
		var _loc2_:SteamInputAction;
		var __ax4_iter_112:Vector<SteamInputAction>;
		var _loc3_:Array<ASAny> = null;
		var _loc4_ = glyphController;
		if (!isSteamInputReady || _loc4_ == null) {
			return null;
		}
		var _loc5_:SteamInputActionSet;
		final __ax4_iter_111:Array<ASAny> = [mInGameControlsActionSet, mMenuControlsActionSet];
		if (checkNullIteratee(__ax4_iter_111))
			for (_tmp_ in __ax4_iter_111) {
				_loc5_ = ASCompat.coerce(_tmp_, steamInput.SteamInputActionSet);
				__ax4_iter_112 = _loc5_.analogActionHandles;
				if (checkNullIteratee(__ax4_iter_112))
					for (_tmp_ in __ax4_iter_112) {
						_loc2_ = _tmp_;
						if (_loc2_.actionName == inActionName) {
							_loc3_ = mSteamworks.getAnalogActionOrigins(_loc4_.controllerHandle, _loc5_.actionSetHandle, _loc2_.actionHandle);
							if (_loc3_ == null || _loc3_.length == 0) {
								return null;
							}
							return getGlyphFilePathForOrigin(ASCompat.toString(_loc3_[0]));
						}
					}
			}
		return null;
	}

	public function flushInputs() {
		var _loc1_:SteamController;
		final __ax4_iter_113 = mConnectedSteamControllers;
		if (checkNullIteratee(__ax4_iter_113))
			for (_tmp_ in __ax4_iter_113) {
				_loc1_ = _tmp_;
				_loc1_.flushInput();
			}
	}

	public function getAnalogAction(movementActionName:String):Vector3D {
		var _loc2_:Vector3D = null;
		var _loc3_:SteamController;
		final __ax4_iter_114 = mConnectedSteamControllers;
		if (checkNullIteratee(__ax4_iter_114))
			for (_tmp_ in __ax4_iter_114) {
				_loc3_ = _tmp_;
				_loc2_ = ASCompat.coerce(ASDictionary.getString(_loc3_.analogInputs, movementActionName), flash.geom.Vector3D);
				if (_loc2_ != null) {
					if (_loc2_.lengthSquared > 0) {
						return _loc2_;
					}
				}
			}
		ZERO_VECTOR.setTo(0, 0, 0);
		return ZERO_VECTOR;
	}

	public function fireButtonEvents() {
		var _loc1_:ASObject;
		var __ax4_iter_116:ASDictionary<ASAny, ASAny>;
		var _loc2_:ASObject;
		var __ax4_iter_117:ASDictionary<ASAny, ASAny>;
		var _loc3_:SteamController;
		final __ax4_iter_115 = mConnectedSteamControllers;
		if (checkNullIteratee(__ax4_iter_115))
			for (_tmp_ in __ax4_iter_115) {
				_loc3_ = _tmp_;
				__ax4_iter_116 = _loc3_.pressedDigitalButtons;
				if (checkNullIteratee(__ax4_iter_116))
					for (_tmp_ in __ax4_iter_116.keys()) {
						_loc1_ = _tmp_;
						mEventComponent.dispatchEvent(new OnSteamInputButtonPressedEvent(ASCompat.toString(_loc1_)));
					}
				__ax4_iter_117 = _loc3_.releasedDigitalButtons;
				if (checkNullIteratee(__ax4_iter_117))
					for (_tmp_ in __ax4_iter_117.keys()) {
						_loc2_ = _tmp_;
						mEventComponent.dispatchEvent(new OnSteamInputButtonReleasedEvent(ASCompat.toString(_loc2_)));
					}
			}
		if (mUseMenuControlsInsteadOfInGameControls) {
			flushInputs();
		}
	}

	public function pressedAction(actionName:String):Bool {
		var _loc2_:SteamController;
		final __ax4_iter_118 = mConnectedSteamControllers;
		if (checkNullIteratee(__ax4_iter_118))
			for (_tmp_ in __ax4_iter_118) {
				_loc2_ = _tmp_;
				if (_loc2_.pressedDigitalButtons.exists(actionName)) {
					return true;
				}
			}
		return false;
	}

	public function releasedAction(actionName:String):Bool {
		var _loc2_:SteamController;
		final __ax4_iter_119 = mConnectedSteamControllers;
		if (checkNullIteratee(__ax4_iter_119))
			for (_tmp_ in __ax4_iter_119) {
				_loc2_ = _tmp_;
				if (_loc2_.releasedDigitalButtons.exists(actionName)) {
					return true;
				}
			}
		return false;
	}

	public function heldAction(actionName:String):Bool {
		var _loc2_:SteamController;
		final __ax4_iter_120 = mConnectedSteamControllers;
		if (checkNullIteratee(__ax4_iter_120))
			for (_tmp_ in __ax4_iter_120) {
				_loc2_ = _tmp_;
				if (_loc2_.heldDigitalButtons.exists(actionName)) {
					return true;
				}
			}
		return false;
	}

	public function activateInGameActionLayer() {
		mUseMenuControlsInsteadOfInGameControls = false;
	}

	public function activateMenuControlsActionLayer() {
		mUseMenuControlsInsteadOfInGameControls = true;
	}

	public function getDigitalActionOriginsAssignedToControlsAction(inActionName:String):Vector<String> {
		var _loc4_ = new Vector<String>();
		var _loc5_ = glyphController;
		if (mMenuControlsActionSet == null
			|| mInGameControlsActionSet == null
			|| _loc5_ == null
			|| mMenuControlsActionSet.digitalActionHandles == null
			|| mInGameControlsActionSet.digitalActionHandles == null) {
			Logger.warnch("Input",
				"SteamInputManager: digitalActionHandles or connectedSteamControllers is null. Unable to getDigitalActionOriginsAssignedToMenuControlsAction.");
			return _loc4_;
		}
		var _loc2_:SteamInputAction;
		final __ax4_iter_121 = mMenuControlsActionSet.digitalActionHandles;
		if (checkNullIteratee(__ax4_iter_121))
			for (_tmp_ in __ax4_iter_121) {
				_loc2_ = _tmp_;
				if (_loc2_.actionName == inActionName) {
					pushActionOrigins(_loc4_,
						mSteamworks.getDigitalActionOrigins(_loc5_.controllerHandle, mMenuControlsActionSet.actionSetHandle, _loc2_.actionHandle));
				}
			}
		var _loc3_:SteamInputAction;
		final __ax4_iter_122 = mInGameControlsActionSet.digitalActionHandles;
		if (checkNullIteratee(__ax4_iter_122))
			for (_tmp_ in __ax4_iter_122) {
				_loc3_ = _tmp_;
				if (_loc3_.actionName == inActionName) {
					pushActionOrigins(_loc4_,
						mSteamworks.getDigitalActionOrigins(_loc5_.controllerHandle, mInGameControlsActionSet.actionSetHandle, _loc3_.actionHandle));
				}
			}
		return _loc4_;
	}

	@:isVar public var isUsingMenuControlsInsteadOfInGameControls(get, never):Bool;

	public function get_isUsingMenuControlsInsteadOfInGameControls():Bool {
		return mUseMenuControlsInsteadOfInGameControls;
	}

	@:isVar public var isSteamInputReady(get, never):Bool;

	public function get_isSteamInputReady():Bool {
		return mConnectedSteamControllers != null && mConnectedSteamControllers.length > 0;
	}

	@:isVar public var wantsControllerPrompts(get, never):Bool;

	public function get_wantsControllerPrompts():Bool {
		return isSteamInputReady;
	}

	public function hasGlyphForAction(inActionName:String):Bool {
		if (!isSteamInputReady) {
			return false;
		}
		var _loc2_ = getGlyphFilePathForAction(inActionName);
		return _loc2_ != null && _loc2_ != "" && _loc2_ != "error1";
	}

	@:isVar public var isRunningOnSteamDeck(get, never):Bool;

	public function get_isRunningOnSteamDeck():Bool {
		return mIsRunningOnSteamDeck;
	}

	@:isVar public var usesSteamOnScreenKeyboard(get, never):Bool;

	public function get_usesSteamOnScreenKeyboard():Bool {
		return isBigPictureMode() || mIsRunningOnSteamDeck;
	}

	function initSteamInput() {
		if (!mSteamworks.isReady) {
			return;
		}
		if (mDBFacade.dbConfigManager == null) {
			return;
		}
		if (!mActionManifestSetupHasRun) {
			mActionManifestSetupHasRun = true;
			setActionManifestFilePathFromConfig();
			mIsRunningOnSteamDeck = mSteamworks.isSteamRunningOnSteamDeck();
			if (mIsRunningOnSteamDeck && mDBFacade.mouseCursorManager != null) {
				mDBFacade.mouseCursorManager.hideMouseCursor();
			}
			return;
		}
		var _loc1_ = mSteamworks.inputInit();
		if (!_loc1_) {
			Logger.infoch("Input", "SteamInputManager: Steamworks inputInit failed");
			return;
		}
		mControllerRumble.isEnabled = mDBFacade.dbConfigManager.getConfigBoolean("ControllerVibrationEnabled", true);
		mIsInitialized = true;
		Logger.infoch("Input", "SteamInputManager: Steam Input initialized." + (mIsRunningOnSteamDeck ? " Running on a Steam Deck." : ""));
	}

	function setActionManifestFilePathFromConfig() {
		var _loc2_ = mDBFacade.dbConfigManager.getConfigString("ActionManifestRelativePath", "");
		if (_loc2_ == "") {
			return;
		}
		var _loc1_ = AssetLoader.resolveFile(_loc2_);
		if (!_loc1_.exists) {
			Logger.warnch("Input", "SteamInputManager: Action manifest file not found at \'" + _loc1_.nativePath + "\'");
			return;
		}
		if (!mSteamworks.setInputActionManifestFilePath(_loc1_.nativePath)) {
			Logger.warnch("Input", "SteamInputManager: setInputActionManifestFilePath failed for \'" + _loc1_.nativePath + "\'");
		}
	}

	function reconcileControllerStateAndNotify() {
		resetControllerConnectedStates();
		updateOrCreateConnectedControllers();
		removeDisconnectedControllers();
		if (mControllerWasConnectedLastUpdate != isSteamInputReady) {
			mControllerRumble.forgetHardwareState();
			mEventComponent.dispatchEvent(new ControllerConnectionChangedEvent(isSteamInputReady));
			mControllerWasConnectedLastUpdate = isSteamInputReady;
		}
	}

	function dictionariesHaveSameContents(inDictOne:ASDictionary<ASAny, ASAny>, inDictTwo:ASDictionary<ASAny, ASAny>):Bool {
		var _loc4_:ASObject;
		if (checkNullIteratee(inDictOne))
			for (_tmp_ in inDictOne.keys()) {
				_loc4_ = _tmp_;
				if (inDictOne[_loc4_] != inDictTwo[_loc4_]) {
					return false;
				}
			}
		var _loc3_:ASObject;
		if (checkNullIteratee(inDictTwo))
			for (_tmp_ in inDictTwo.keys()) {
				_loc3_ = _tmp_;
				if (inDictTwo[_loc3_] != inDictOne[_loc3_]) {
					return false;
				}
			}
		return true;
	}

	function resetControllerConnectedStates() {
		var _loc1_:SteamController;
		final __ax4_iter_123 = mConnectedSteamControllers;
		if (checkNullIteratee(__ax4_iter_123))
			for (_tmp_ in __ax4_iter_123) {
				_loc1_ = _tmp_;
				_loc1_.isConnected = false;
			}
	}

	function updateOrCreateConnectedControllers() {
		var _loc2_:SteamController = null;
		var _loc1_ = mSteamworks.getConnectedControllers();
		if (!tryLazyLoadInGameActionSet(_loc1_)) {
			return;
		}
		if (!tryLazyLoadMenuControlsActionSet(_loc1_)) {
			return;
		}
		var _loc3_:String;
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc3_ = _tmp_;
				_loc2_ = ASCompat.coerce(ASDictionary.getString(mHandlesToSteamControllers, _loc3_), steamInput.SteamController);
				if (_loc2_ == null) {
					_loc2_ = new SteamController(_loc3_, mInGameControlsActionSet, mMenuControlsActionSet);
					mHandlesToSteamControllers[_loc3_] = _loc2_;
				}
				if (mConnectedSteamControllers.indexOf(_loc2_) == -1) {
					mConnectedSteamControllers.push(_loc2_);
				}
				_loc2_.isConnected = true;
				if (mUseMenuControlsInsteadOfInGameControls) {
					mSteamworks.activateActionSet(_loc2_.controllerHandle, mMenuControlsActionSet.actionSetHandle);
				} else {
					mSteamworks.activateActionSet(_loc2_.controllerHandle, mInGameControlsActionSet.actionSetHandle);
				}
			}
	}

	function tryLazyLoadMenuControlsActionSet(connectedControllerHandles:Array<ASAny>):Bool {
		if (mMenuControlsActionSet != null) {
			return true;
		}
		var _loc2_ = tryLoadActionSet("MenuControls", connectedControllerHandles);
		if (_loc2_ == null) {
			return false;
		}
		mMenuControlsActionSet = _loc2_;
		return true;
	}

	function tryLazyLoadInGameActionSet(connectedControllerHandles:Array<ASAny>):Bool {
		if (mInGameControlsActionSet != null) {
			return true;
		}
		var _loc2_ = tryLoadActionSet("InGameControls", connectedControllerHandles);
		if (_loc2_ == null) {
			return false;
		}
		mInGameControlsActionSet = _loc2_;
		return true;
	}

	function tryLoadActionSet(actionSetName:String, connectedControllerHandles:Array<ASAny>):SteamInputActionSet {
		if (connectedControllerHandles.length == 0) {
			return null;
		}
		var _loc4_ = mSteamworks.getActionSetHandle(actionSetName);
		if (_loc4_ == "0") {
			if (!mHasLoggedActionSetLoadFailure) {
				Logger.warnch("Input", "SteamInputManager: Couldn\'t load actionSet \'" + actionSetName + "\'");
				mHasLoggedActionSetLoadFailure = true;
			}
			return null;
		}
		var _loc6_ = new SteamInputActionSet(actionSetName, _loc4_);
		var _loc3_ = false;
		var _loc5_ = false;
		if (actionSetName == "InGameControls") {
			_loc3_ = _loc6_.tryLoadAnalogActions(InGameControlsActionSetData.gatherAnalogActionNames(), mSteamworks);
			_loc5_ = _loc6_.tryLoadDigitalActions(InGameControlsActionSetData.gatherDigitalActionNames(), mSteamworks);
		}
		if (actionSetName == "MenuControls") {
			_loc3_ = _loc6_.tryLoadAnalogActions(MenuControlsActionSetData.gatherAnalogActionNames(), mSteamworks);
			_loc5_ = _loc6_.tryLoadDigitalActions(MenuControlsActionSetData.gatherDigitalActionNames(), mSteamworks);
		}
		if (!_loc3_ || !_loc5_) {
			if (!mHasLoggedActionSetLoadFailure) {
				Logger.warnch("Input", "SteamInputManager: Couldn\'t load actionSet actions for \'" + actionSetName + "\'");
				mHasLoggedActionSetLoadFailure = true;
			}
			return null;
		}
		return _loc6_;
	}

	function removeDisconnectedControllers() {
		var _loc1_ = 0;
		var _loc2_:SteamController = null;
		_loc1_ = mConnectedSteamControllers.length - 1;
		while (_loc1_ >= 0) {
			_loc2_ = mConnectedSteamControllers[_loc1_];
			if (!_loc2_.isConnected) {
				_loc2_.handleDisconnect();
				mConnectedSteamControllers.removeAt(_loc1_);
			}
			_loc1_--;
		}
	}

	function updateControllers() {
		var _loc1_:SteamController;
		final __ax4_iter_124 = mConnectedSteamControllers;
		if (checkNullIteratee(__ax4_iter_124))
			for (_tmp_ in __ax4_iter_124) {
				_loc1_ = _tmp_;
				_loc1_.readInput(mSteamworks);
			}
	}

	public function isBigPictureMode():Bool {
		return mSteamworks.isSteamInBigPictureMode();
	}

	public function showFloatingGamepadTextInputForField(field:DisplayObject) {
		var _loc2_:Stage = null;
		if (field == null || field.stage == null) {
			Logger.warnch("Input", "Steam floating keyboard requested for a text field that is not on stage");
			_loc2_ = mDBFacade.stageRef;
			showFloatingGamepadTextInput(0, ASCompat.floatToInt(_loc2_.stageHeight / 2), _loc2_.stageWidth, ASCompat.floatToInt(_loc2_.stageHeight / 2));
			return;
		}
		var _loc5_ = field.getBounds(field.stage);
		var _loc4_ = Math.floor(_loc5_.left);
		var _loc3_ = Math.floor(_loc5_.top);
		showFloatingGamepadTextInput(_loc4_, _loc3_, ASCompat.floatToInt(Math.fceil(_loc5_.right) - _loc4_),
			ASCompat.floatToInt(Math.fceil(_loc5_.bottom) - _loc3_));
	}

	function showFloatingGamepadTextInput(textFieldXPosition:Int, textFieldYPosition:Int, textFieldWidth:Int, textFieldHeight:Int) {
		var _loc5_ = 0;
		if (!mSteamworks.showFloatingGamepadTextInput(_loc5_, textFieldXPosition, textFieldYPosition, textFieldWidth, textFieldHeight)) {
			Logger.warnch("Input", "Steam Input Manager couldn\'t open the virtual keyboard");
		}
	}

	public function playRumble(effect:RumbleEffect) {
		mControllerRumble.play(effect);
	}

	public function stopRumble() {
		mControllerRumble.stopAll();
	}

	@:isVar public var isRumbleEnabled(get, set):Bool;

	public function get_isRumbleEnabled():Bool {
		return mControllerRumble.isEnabled;
	}

	function set_isRumbleEnabled(value:Bool):Bool {
		return mControllerRumble.isEnabled = value;
	}
}
