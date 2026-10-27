package gameMasterDictionary;

class GMStackable extends GMInventoryBase {
	public var StackLimit:UInt = 0;

	public var EquipLimit:UInt = 0;

	public var LevelReq:UInt = 0;

	public var ExpMult:Float = Math.NaN;

	public var GoldMult:Float = Math.NaN;

	public var AccountBooster:Bool = false;

	public var Buff:String;

	public var UsageAttack:String;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		StackLimit = (ASCompat.toInt(jsonAsset.StackLimit) : UInt);
		EquipLimit = (ASCompat.toInt(jsonAsset.EquipLimit) : UInt);
		LevelReq = (ASCompat.toInt(jsonAsset.LevelReq) : UInt);
		ExpMult = ASCompat.toNumberField(jsonAsset, "ExpMult");
		GoldMult = ASCompat.toNumberField(jsonAsset, "GoldMult");
		Buff = jsonAsset.BuffGiven;
		UsageAttack = jsonAsset.UsageAttack;
		AccountBooster = ASCompat.toBool(jsonAsset.AccountBooster);
	}
}
