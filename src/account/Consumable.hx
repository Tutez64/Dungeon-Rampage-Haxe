package account;

class Consumable {
	public var stackId:UInt = 0;

	public var stackCount:UInt = 0;

	public var stackSlot:UInt = 0;

	public function new(slot:UInt, id:UInt, count:UInt) {
		stackId = id;
		stackCount = count;
		stackSlot = slot;
	}
}
