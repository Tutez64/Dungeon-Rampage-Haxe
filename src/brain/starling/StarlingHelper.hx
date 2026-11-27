package brain.starling;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

class StarlingHelper {
	public function new() {}

	public static function findNavCollisions(inSearchNode:DisplayObjectContainer):Array<ASAny> {
		return findChildrenOfClass(inSearchNode, ["NavCollisionCircle", "NavCollisionRectangle"]);
	}

	public static function findCombatCollisions(searchNode:DisplayObjectContainer):Array<ASAny> {
		return findChildrenOfClass(searchNode, ["CombatCollisionCircle", "CombatCollisionRectangle"]);
	}

	public static function findChildrenOfClass(inSearchNode:DisplayObjectContainer, classNames:Array<ASAny>):Array<ASAny> {
		var _loc3_:Array<ASAny> = [];
		recursiveFindChildrenOfClass(_loc3_, inSearchNode, classNames);
		return _loc3_;
	}

	static function recursiveFindChildrenOfClass(foundArray:Array<ASAny>, node:DisplayObject, classNames:Array<ASAny>) {
		var _loc5_ = 0;
		var _loc6_ = ASCompat.getQualifiedClassName(node);
		if (classNames.indexOf(_loc6_) != -1) {
			foundArray.push(node);
		}
		var _loc4_ = ASCompat.reinterpretAs(node, DisplayObjectContainer);
		if (_loc4_ != null) {
			_loc5_ = 0;
			while (_loc5_ < _loc4_.numChildren) {
				recursiveFindChildrenOfClass(foundArray, _loc4_.getChildAt(_loc5_), classNames);
				_loc5_++;
			}
		}
	}
}
