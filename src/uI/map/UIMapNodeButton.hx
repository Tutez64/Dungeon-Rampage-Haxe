package uI.map;

import brain.clock.GameClock;
import brain.facade.Facade;
import brain.uI.UIButton;
import brain.workLoop.Task;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Rectangle;

class UIMapNodeButton extends UIButton {
	static inline final TOOLTIP_EDGE_MARGIN:Float = 8;

	static inline final POINTER_CORNER_ROOM:Float = 16;

	var mNavigable:Bool = false;

	var mTooltipBaseX:Float = 0;

	var mTooltipBaseY:Float = 0;

	var mTooltipClampTask:Task;

	public function new(facade:Facade, root:MovieClip, navigable:Bool) {
		super(facade, root);
		mNavigable = navigable;
	}

	static function isEffectivelyVisible(displayObject:DisplayObject):Bool {
		var _loc2_:DisplayObject = null;
		_loc2_ = displayObject;
		while (_loc2_ != null) {
			if (!_loc2_.visible) {
				return false;
			}
			_loc2_ = _loc2_.parent;
		}
		return true;
	}

	override public function canBeFocused():Bool {
		return mNavigable && super.canBeFocused() && isEffectivelyVisible(mRoot);
	}

	override function showTooltip(gameClock:GameClock = null) {
		super.showTooltip(gameClock);
		if (mTooltip == null || mTooltip.parent == null) {
			return;
		}
		mTooltipBaseX = mTooltip.x;
		mTooltipBaseY = mTooltip.y;
		keepTooltipInView();
		if (mTooltipClampTask == null) {
			mTooltipClampTask = mFacade.preRenderWorkManager.doEveryFrame(keepTooltipInView, "UIMapNodeButton tooltip clamp");
		}
	}

	override function hideTooltip() {
		stopTooltipClamp();
		super.hideTooltip();
	}

	function stopTooltipClamp() {
		if (mTooltipClampTask != null) {
			mTooltipClampTask.destroy();
			mTooltipClampTask = null;
		}
	}

	function keepTooltipInView(gameClock:GameClock = null) {
		var _loc6_:Rectangle = null;
		var _loc10_ = Math.NaN;
		if (mTooltip == null || mTooltip.parent == null) {
			stopTooltipClamp();
			return;
		}
		mTooltip.x = mTooltipBaseX;
		mTooltip.y = mTooltipBaseY;
		var _loc3_ = mTooltip.getChildByName("pointer");
		if (_loc3_ != null) {
			_loc3_.x = 0;
		}
		var _loc7_ = mTooltip.getBounds(mFacade.scalingRoot);
		var _loc4_:Float = 0;
		if (_loc7_.left < 8) {
			_loc4_ = Math.min(8 - _loc7_.left, _loc7_.width / 2);
		} else if (_loc7_.right > mFacade.viewWidth - 8) {
			_loc4_ = -Math.min(_loc7_.right - (mFacade.viewWidth - 8), _loc7_.width / 2);
		}
		var _loc5_ = Math.min(Math.max(0, 8 - _loc7_.top), _loc7_.height / 2);
		if (_loc4_ == 0 && _loc5_ == 0) {
			return;
		}
		var _loc2_ = mTooltip.parent;
		var _loc8_ = _loc2_.globalToLocal(mFacade.scalingRoot.localToGlobal(_loc7_.topLeft));
		var _loc9_ = _loc2_.globalToLocal(mFacade.scalingRoot.localToGlobal(new Point(_loc7_.left + _loc4_, _loc7_.top + _loc5_)));
		mTooltip.x += _loc9_.x - _loc8_.x;
		mTooltip.y += _loc9_.y - _loc8_.y;
		if (_loc3_ != null && mTooltip.scaleX != 0) {
			_loc6_ = mTooltip.getBounds(mTooltip);
			_loc10_ = Math.max(0, (_loc6_.width - _loc3_.width) / 2 - 16);
			_loc3_.x = Math.max(-_loc10_, Math.min(_loc10_, -(_loc9_.x - _loc8_.x) / mTooltip.scaleX));
		}
	}
}
