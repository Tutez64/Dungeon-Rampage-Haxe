package uI;

import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.starling.StarlingLayer;
import facade.DBFacade;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;

class UIHideToggle {
	public static inline final CHANGED_EVENT = "UI_HIDE_TOGGLE_CHANGED";

	public static inline final TOGGLE_KEY = 119;

	static inline final KEY_LISTENER_PRIORITY = 500;

	static final HIDDEN_LAYERS:Vector<Int> = Vector.ofArray([
		50, 51, 53, 52, 54, 55, 56, 57, 59, 58, 60, 63, 61, 62, 162, 163, 75, 104, 105, 106, 107, 200
	]);

	var mDBFacade:DBFacade;

	var mEventComponent:EventComponent;

	var mHidden:Bool = false;

	var mTogglePressHeld:Bool = false;

	var mHiddenLayers:Vector<DisplayObject> = new Vector();

	var mHiddenLayersWereVisible:Vector<Bool> = new Vector();

	var mHiddenStarlingLayers:Vector<StarlingLayer> = new Vector();

	var mHiddenStarlingLayersWereVisible:Vector<Bool> = new Vector();

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		mEventComponent = new EventComponent(mDBFacade);
		EventListeners.add(mDBFacade.stageRef, "keyDown", onKeyDown, false, 500);
		EventListeners.add(mDBFacade.stageRef, "keyUp", onKeyUp, true);
		EventListeners.add(mDBFacade.stageRef, "keyUp", onKeyUp);
		EventListeners.add(mDBFacade.stageRef, "deactivate", onDeactivate);
		EventListeners.add(mDBFacade.stageRef, "focusIn", onFocusIn, true);
	}

	public function destroy() {
		reveal();
		EventListeners.remove(mDBFacade.stageRef, "keyDown", onKeyDown);
		EventListeners.remove(mDBFacade.stageRef, "keyUp", onKeyUp, true);
		EventListeners.remove(mDBFacade.stageRef, "keyUp", onKeyUp);
		EventListeners.remove(mDBFacade.stageRef, "deactivate", onDeactivate);
		EventListeners.remove(mDBFacade.stageRef, "focusIn", onFocusIn, true);
		mEventComponent.destroy();
		mEventComponent = null;
		mDBFacade = null;
	}

	@:isVar public var hidden(get, never):Bool;

	public function get_hidden():Bool {
		return mHidden;
	}

	public function reveal() {
		setHidden(false);
	}

	function onKeyDown(event:KeyboardEvent) {
		if (event.keyCode != 119) {
			return;
		}
		if (!mTogglePressHeld) {
			if (!mHidden && !canHide()) {
				return;
			}
			mTogglePressHeld = true;
			setHidden(!mHidden);
		}
		event.stopImmediatePropagation();
	}

	function onKeyUp(event:KeyboardEvent) {
		if (event.keyCode == 119) {
			mTogglePressHeld = false;
		}
	}

	function onDeactivate(event:Event) {
		mTogglePressHeld = false;
	}

	function canHide():Bool {
		if (mDBFacade.mainStateMachine == null || mDBFacade.mainStateMachine.currentStateName != "RunState") {
			return false;
		}
		return !mDBFacade.sceneGraphManager.popupCurtainShown;
	}

	function onFocusIn(event:FocusEvent) {
		if (mHidden && mDBFacade.textInputHasFocus) {
			reveal();
		}
	}

	function setHidden(value:Bool) {
		if (mHidden == value) {
			return;
		}
		mHidden = value;
		if (mHidden) {
			hideLayers();
		} else {
			restoreLayers();
		}
		mDBFacade.sessionIdVisible = !mHidden;
		if (mDBFacade.fpsReadout != null) {
			mDBFacade.fpsReadout.suppressed = mHidden;
		}
		mEventComponent.dispatchEvent(new Event("UI_HIDE_TOGGLE_CHANGED"));
	}

	function hideLayers() {
		var _loc3_:DisplayObject = null;
		var _loc1_:Int;
		final __ax4_iter_131 = HIDDEN_LAYERS;
		if (checkNullIteratee(__ax4_iter_131))
			for (_tmp_ in __ax4_iter_131) {
				_loc1_ = _tmp_;
				_loc3_ = mDBFacade.sceneGraphManager.getLayer(_loc1_);
				if (_loc3_ != null) {
					mHiddenLayers.push(_loc3_);
					mHiddenLayersWereVisible.push(_loc3_.visible);
					_loc3_.visible = false;
				}
			}
		var _loc2_ = mDBFacade.starlingLayerManager;
		if (_loc2_ != null) {
			hideStarlingLayer(_loc2_.getLayer(50));
			hideStarlingLayer(_loc2_.getLayer(36));
		}
	}

	function hideStarlingLayer(layer:StarlingLayer) {
		if (layer == null) {
			return;
		}
		mHiddenStarlingLayers.push(layer);
		mHiddenStarlingLayersWereVisible.push(layer.visible);
		layer.visible = false;
	}

	function restoreLayers() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mHiddenLayers.length) {
			mHiddenLayers[_loc1_].visible = mHiddenLayersWereVisible[_loc1_];
			_loc1_++;
		}
		mHiddenLayers.length = 0;
		mHiddenLayersWereVisible.length = 0;
		_loc1_ = 0;
		while (_loc1_ < mHiddenStarlingLayers.length) {
			mHiddenStarlingLayers[_loc1_].visible = mHiddenStarlingLayersWereVisible[_loc1_];
			_loc1_++;
		}
		mHiddenStarlingLayers.length = 0;
		mHiddenStarlingLayersWereVisible.length = 0;
	}
}
