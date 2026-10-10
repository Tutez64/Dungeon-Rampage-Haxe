package dr_floor;

import brain.gameObject.View;
import brain.logger.Logger;
import dungeon.NavCollider;
import facade.DBFacade;
import flash.display.DisplayObjectContainer;
import flash.geom.Vector3D;

class FloorView extends View {
	var mParentFloorObject:FloorObject;

	var mLayer:Int = 0;

	var mDBFacade:DBFacade;

	public function new(facade:DBFacade, floorObject:FloorObject) {
		mDBFacade = facade;
		super(facade);
		mParentFloorObject = floorObject;
	}

	public static function findNavCollisions(searchNode:DisplayObjectContainer):Array<ASAny> {
		return View.findChildrenOfClass(searchNode, ["NavCollisionCircle", "NavCollisionRectangle"]);
	}

	public static function findCombatCollisions(searchNode:DisplayObjectContainer):Array<ASAny> {
		return View.findChildrenOfClass(searchNode, ["CombatCollisionCircle", "CombatCollisionRectangle"]);
	}

	override public function set_position(pos:Vector3D):Vector3D {
		super.position = pos;
		var _loc2_:NavCollider;
		final __ax4_iter_210 = mParentFloorObject.navCollisions;
		if (checkNullIteratee(__ax4_iter_210))
			for (_tmp_ in __ax4_iter_210) {
				_loc2_ = _tmp_;
				_loc2_.position = pos;
			}
		return pos;
	}

	@:isVar public var worldCenter(get, never):Vector3D;

	public function get_worldCenter():Vector3D {
		return mParentFloorObject.worldCenter;
	}

	public function addToStage() {
		if (this.layer == 0) {
			Logger.error("Tried to addToStage with layer == 0");
		} else {
			mSceneGraphComponent.addChild(this.root, (this.layer : UInt));
			checkoutMovieClipRenderers();
		}
	}

	public function removeFromStage() {
		if (this.layer != 0 && mSceneGraphComponent.contains(this.root, (this.layer : UInt))) {
			mSceneGraphComponent.removeChild(this.root);
		}
		checkinMovieClipRenderers();
	}

	function checkoutMovieClipRenderers() {}

	function checkinMovieClipRenderers() {}

	@:isVar public var layer(get, set):Int;

	public function set_layer(value:Int):Int {
		return mLayer = value;
	}

	override public function destroy() {
		mParentFloorObject = null;
		mDBFacade = null;
		super.destroy();
	}

	function get_layer():Int {
		return mLayer;
	}
}
