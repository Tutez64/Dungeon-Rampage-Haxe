package brain.starling;

import flash.geom.Matrix;
import starling.display.MeshBatch;

/*internal*/
class StarlingBakedRun {
	public final batch:MeshBatch = new MeshBatch();

	public final members:Vector<StarlingScenerySprite> = new Vector((0 : UInt));

	public final leadInverse:Matrix = new Matrix();

	public var lead:StarlingScenerySprite;

	public var shownCount:Int = 0;

	public var left:Float = 0;

	public var top:Float = 0;

	public var right:Float = 0;

	public var bottom:Float = 0;

	public var first:Int = -1;

	public var last:Int = -1;

	public var seen:Int = 0;

	public var violated:Bool = false;

	public function new() {
		batch.touchable = false;
	}

	public function clear() {
		batch.clear();
		batch.texture = null;
		members.length = 0;
		lead = null;
		shownCount = 0;
		violated = false;
	}

	public function dispose() {
		batch.dispose();
		members.length = 0;
		lead = null;
	}
}
