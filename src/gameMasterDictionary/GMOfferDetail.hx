package gameMasterDictionary;

class GMOfferDetail {
	public var OfferId:UInt = 0;

	public var WeaponId:UInt = 0;

	public var WeaponPower:UInt = 0;

	public var Level:UInt = 0;

	public var Rarity:String;

	public var Modifier1:String;

	public var Modifier2:String;

	public var Modifier3:String;

	public var ChestId:UInt = 0;

	public var HeroId:UInt = 0;

	public var PetId:UInt = 0;

	public var SkinId:UInt = 0;

	public var StackableId:UInt = 0;

	public var StackableCount:UInt = 0;

	public var Coins:UInt = 0;

	public var BasicKeys:UInt = 0;

	public var UncommonKeys:UInt = 0;

	public var RareKeys:UInt = 0;

	public var LegendaryKeys:UInt = 0;

	public var WeaponSlots:UInt = 0;

	public var Gems:UInt = 0;

	public function new(jsonAsset:ASObject) {
		OfferId = (ASCompat.toInt(jsonAsset.OfferId) : UInt);
		WeaponId = (ASCompat.toInt(jsonAsset.WeaponId) : UInt);
		WeaponPower = (ASCompat.toInt(jsonAsset.WeaponPower) : UInt);
		Level = (ASCompat.toInt(jsonAsset.Level != null ? (ASCompat.toInt(jsonAsset.Level) : UInt) : (0 : UInt)) : UInt);
		Rarity = jsonAsset.Rarity;
		Modifier1 = jsonAsset.Modifier1;
		Modifier2 = jsonAsset.Modifier2;
		Modifier3 = jsonAsset.Modifier3;
		ChestId = (ASCompat.toInt(jsonAsset.ChestId) : UInt);
		HeroId = (ASCompat.toInt(jsonAsset.HeroId) : UInt);
		PetId = (ASCompat.toInt(jsonAsset.PetId) : UInt);
		SkinId = (ASCompat.toInt(jsonAsset.SkinId) : UInt);
		StackableId = (ASCompat.toInt(jsonAsset.StackableId) : UInt);
		StackableCount = (ASCompat.toInt(jsonAsset.StackableCount) : UInt);
		Coins = (ASCompat.toInt(jsonAsset.Coins) : UInt);
		BasicKeys = (ASCompat.toInt(jsonAsset.BasicKeys) : UInt);
		UncommonKeys = (ASCompat.toInt(jsonAsset.UncommonKeys) : UInt);
		RareKeys = (ASCompat.toInt(jsonAsset.RareKeys) : UInt);
		LegendaryKeys = (ASCompat.toInt(jsonAsset.LegendaryKeys) : UInt);
		WeaponSlots = (ASCompat.toInt(jsonAsset.WeaponSlots) : UInt);
		Gems = (ASCompat.toInt(jsonAsset.Gems) : UInt);
	}
}
