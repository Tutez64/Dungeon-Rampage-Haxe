package box2D.collision;

import flash.Boot;

class B2DynamicTreeNode {
	public static var currentID:Int = 0;

	public var userData:ASAny;

	public var parent:B2DynamicTreeNode;

	public var id:Int = 0;

	public var child2:B2DynamicTreeNode;

	public var child1:B2DynamicTreeNode;

	public var aabb:B2AABB;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		aabb = new B2AABB();
		var _temp_1 = B2DynamicTreeNode;
		var _loc1_:Int;
		ASCompat.setProperty(_temp_1, "currentID", (_loc1_ = ASCompat.toInt(_temp_1.currentID)) + 1);
		id = _loc1_;
	}

	public function isLeaf():Bool {
		return IsLeaf();
	}

	public function IsLeaf():Bool {
		return child1 == null;
	}
}
