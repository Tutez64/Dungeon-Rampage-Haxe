package gameMasterDictionary;

class GMChest {
	public var Id:UInt = 0;

	public var Name:String;

	public var Rarity:String;

	public var IconName:String;

	public var IconSwf:String;

	public var InventoryRevealName:String;

	public var InventoryRevealSwf:String;

	public var Description:String;

	public function new(jsonAsset:ASObject) {
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		Name = jsonAsset.Name;
		Rarity = jsonAsset.Rarity;
		IconName = jsonAsset.IconName;
		IconSwf = jsonAsset.IconSwf;
		InventoryRevealName = jsonAsset.InventoryRevealName;
		InventoryRevealSwf = jsonAsset.InventoryRevealSwf;
		Description = jsonAsset.Description;
	}
}
