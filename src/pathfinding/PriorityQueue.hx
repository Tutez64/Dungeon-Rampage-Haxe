package pathfinding;

/*dynamic*/
class PriorityQueue extends ASArrayBase {
	public function new() {
		super();
	}

	override public function push(..._rest:ASAny):UInt {
		var rest = ASCompat.restToArray(_rest);
		var _loc2_ = super.push(rest[0]);
		this.sort(compare);
		return _loc2_;
	}

	public function front():AstarGridNode {
		return ASCompat.dynamicAs((this : ASAny)[0], pathfinding.AstarGridNode);
	}

	override public function pop():ASAny {
		return splice(0, 1);
	}

	public function contains(node:AstarGridNode):Bool {
		var _loc2_ = 0;
		_loc2_ = 0;
		while (_loc2_ != length) {
			if ((this : ASAny)[_loc2_] == node) {
				return true;
			}
			_loc2_++;
		}
		return false;
	}

	function compare(nodeA:AstarGridNode, nodeB:AstarGridNode):Int {
		if (nodeA.f < nodeB.f) {
			return -1;
		}
		if (nodeA.f > nodeB.f) {
			return 1;
		}
		return 0;
	}
}
