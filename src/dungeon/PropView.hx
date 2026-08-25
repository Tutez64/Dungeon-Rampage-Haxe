package dungeon;

import brain.render.MovieClipRenderController;
import facade.DBFacade;
import dr_floor.FloorView;
import flash.display.DisplayObject;
import flash.display.MovieClip;

class PropView extends FloorView {
	var mBody:MovieClip;

	public function new(dbFacade:DBFacade, gameObject:Prop) {
		super(dbFacade, gameObject);
		mRoot.name = "PropView_" + gameObject.id;
		mRoot.mouseEnabled = false;
		mRoot.mouseChildren = false;
	}

	@:isVar public var body(never, set):MovieClip;

	public function set_body(clip:MovieClip):MovieClip {
		mBody = clip;
		mRoot.addChild(mBody);
		var _loc2_:DisplayObject;
		final __ax4_iter_140 = FloorView.findNavCollisions(mBody);
		if (checkNullIteratee(__ax4_iter_140))
			for (_tmp_ in __ax4_iter_140) {
				_loc2_ = ASCompat.dynamicAs(_tmp_, flash.display.DisplayObject);
				_loc2_.parent.removeChild(_loc2_);
			}
		var _loc3_:DisplayObject;
		final __ax4_iter_141 = FloorView.findCombatCollisions(mBody);
		if (checkNullIteratee(__ax4_iter_141))
			for (_tmp_ in __ax4_iter_141) {
				_loc3_ = ASCompat.dynamicAs(_tmp_, flash.display.DisplayObject);
				_loc3_.parent.removeChild(_loc3_);
			}
		mMovieClipRenderer = new MovieClipRenderController(mFacade, mBody);
		if (mBody.totalFrames == 1 && !mDBFacade.featureFlags.getFlagValue("want-zoom")) {
			mRoot.cacheAsBitmap = true;
			mMovieClipRenderer.play((0 : UInt), false);
		} else {
			mMovieClipRenderer.play((0 : UInt), true);
		}
		return clip;
	}

	override public function destroy() {
		mBody = null;
		super.destroy();
	}
}
