package gameMasterDictionary;

class GMStackable extends GMInventoryBase {
	public var UsageAttack:String;

	public var StackLimit:UInt = 0;

	public var LevelReq:UInt = 0;

	public var GoldMult:Float = Math.NaN;

	public var ExpMult:Float = Math.NaN;

	public var EquipLimit:UInt = 0;

	public var Buff:String;

	public var AccountBooster:Bool = false;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		super(jsonAsset);
		StackLimit = (ASCompat.toInt(jsonAsset.StackLimit) : UInt);
		EquipLimit = (ASCompat.toInt(jsonAsset.EquipLimit) : UInt);
		LevelReq = (ASCompat.toInt(jsonAsset.LevelReq) : UInt);
		ExpMult = ASCompat.toNumber(jsonAsset.ExpMult);
		GoldMult = ASCompat.toNumber(jsonAsset.GoldMult);
		Buff = jsonAsset.BuffGiven;
		UsageAttack = jsonAsset.UsageAttack;
		AccountBooster = ASCompat.toBool(jsonAsset.AccountBooster);
	}
}
