package gameMasterDictionary;

class GMAttack_StateVectorOffsets {
	public var type:Float = Math.NaN;

	public var speed:Float = Math.NaN;

	public var offence:Float = Math.NaN;

	public var defence:Float = Math.NaN;

	public function new(sp:Float = 0, off:Float = 0, def:Float = 0, tp:Float = 0) {
		speed = sp;
		offence = off;
		defence = def;
		type = tp;
	}
}
