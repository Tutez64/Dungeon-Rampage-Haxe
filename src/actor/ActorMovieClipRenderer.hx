package actor;

import brain.render.IRenderer;
import brain.render.MovieClipRenderController;
import facade.DBFacade;
import dr_floor.FloorView;
import flash.display.DisplayObject;
import flash.display.MovieClip;

class ActorMovieClipRenderer extends MovieClipRenderController implements IRenderer {
	public static var MOVIE_CLIP_RENDERER_TYPE:String = "MovieClipRenderer";

	var mDBFacade:DBFacade;

	var mHeading:Float = Math.NaN;

	public function new(dbFacade:DBFacade, movieClip:MovieClip) {
		super(dbFacade, movieClip);
		mDBFacade = dbFacade;
		var _loc3_:DisplayObject;
		final __ax4_iter_24 = FloorView.findNavCollisions(movieClip);
		if (checkNullIteratee(__ax4_iter_24))
			for (_tmp_ in __ax4_iter_24) {
				_loc3_ = ASCompat.dynamicAs(_tmp_, flash.display.DisplayObject);
				_loc3_.parent.removeChild(_loc3_);
			}
		var _loc4_:DisplayObject;
		final __ax4_iter_25 = FloorView.findCombatCollisions(movieClip);
		if (checkNullIteratee(__ax4_iter_25))
			for (_tmp_ in __ax4_iter_25) {
				_loc4_ = ASCompat.dynamicAs(_tmp_, flash.display.DisplayObject);
				_loc4_.parent.removeChild(_loc4_);
			}
	}

	@:isVar public var displayObject(get, never):DisplayObject;

	public function get_displayObject():DisplayObject {
		return mClip;
	}

	@:isVar public var rendererType(get, never):String;

	public function get_rendererType():String {
		return MOVIE_CLIP_RENDERER_TYPE;
	}

	@:isVar public var heading(never, set):Float;

	public function set_heading(value:Float):Float {
		return mHeading = value;
	}

	override public function destroy() {
		mDBFacade = null;
		super.destroy();
	}
}
