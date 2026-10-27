package gameMasterDictionary;

class GMAttack_StateVectorOffsets {
	public var speed:Float = Math.NaN;

	public var offence:Float = Math.NaN;

	public var defence:Float = Math.NaN;

	public var type:Float = Math.NaN;

	public function new(sp:Float, off:Float, def:Float, tp:Float) {
		speed = sp;
		offence = off;
		defence = def;
		type = tp;
	}
}
