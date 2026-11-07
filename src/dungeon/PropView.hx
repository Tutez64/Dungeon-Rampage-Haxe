package dungeon;

import brain.render.MovieClipRenderController;
import facade.DBFacade;
import dr_floor.FloorView;
import starling.StarlingView;
import starling.SwfFallbackDebug;
import flash.display.DisplayObject;
import flash.display.MovieClip;

class PropView extends FloorView {
	var mBody:MovieClip;

	var mStarlingView:StarlingView;

	var mStarlingViewVisible:Bool = true;

	public function new(dbFacade:DBFacade, gameObject:Prop) {
		super(dbFacade, gameObject);
		mRoot.name = "PropView_" + gameObject.id;
		mRoot.mouseEnabled = false;
		mRoot.mouseChildren = false;
	}

	@:isVar public var starlingView(get, set):StarlingView;

	public function set_starlingView(value:StarlingView):StarlingView {
		mStarlingView = value;
		if (mStarlingView != null) {
			removeSwfFallbackOutline();
			if (mStarlingViewVisible) {
				mStarlingView.addToStage();
			} else {
				mStarlingView.removeFromStage();
			}
		} else {
			applySwfFallbackOutline();
		}
		return value;
	}

	function get_starlingView():StarlingView {
		return mStarlingView;
	}

	@:isVar public var body(never, set):MovieClip;

	public function set_body(clip:MovieClip):MovieClip {
		mBody = clip;
		mRoot.addChild(mBody);
		applySwfFallbackOutline();
		var _loc2_:DisplayObject;
		final __ax4_iter_448 = FloorView.findNavCollisions(mBody);
		if (checkNullIteratee(__ax4_iter_448))
			for (_tmp_ in __ax4_iter_448) {
				_loc2_ = ASCompat.coerce(_tmp_, flash.display.DisplayObject);
				_loc2_.parent.removeChild(_loc2_);
			}
		var _loc3_:DisplayObject;
		final __ax4_iter_449 = FloorView.findCombatCollisions(mBody);
		if (checkNullIteratee(__ax4_iter_449))
			for (_tmp_ in __ax4_iter_449) {
				_loc3_ = ASCompat.coerce(_tmp_, flash.display.DisplayObject);
				_loc3_.parent.removeChild(_loc3_);
			}
		mMovieClipRenderer = new MovieClipRenderController(mDBFacade, mBody);
		if (mBody.totalFrames == 1 && !mDBFacade.featureFlags.getFlagValue("want-zoom")) {
			mRoot.cacheAsBitmap = true;
			mMovieClipRenderer.play((0 : UInt), false);
		} else {
			mMovieClipRenderer.play((0 : UInt), true);
		}
		return clip;
	}

	override public function addToStage() {
		super.addToStage();
		mStarlingViewVisible = true;
		if (mStarlingView != null) {
			mStarlingView.addToStage();
		}
	}

	override public function removeFromStage() {
		super.removeFromStage();
		mStarlingViewVisible = false;
		if (mStarlingView != null) {
			mStarlingView.removeFromStage();
		}
	}

	function applySwfFallbackOutline() {
		if (mStarlingView == null) {
			SwfFallbackDebug.applyOutline(mDBFacade, mBody, "PROP");
		}
	}

	function removeSwfFallbackOutline() {
		SwfFallbackDebug.removeOutline(mBody);
	}

	override public function destroy() {
		mBody = null;
		if (mStarlingView != null) {
			mStarlingView.dispose();
			mStarlingView = null;
		}
		super.destroy();
	}
}
