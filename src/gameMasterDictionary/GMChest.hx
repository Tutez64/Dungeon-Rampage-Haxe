package gameMasterDictionary;

import flash.Boot;

class GMChest {
	public var Rarity:String;

	public var Name:String;

	public var InventoryRevealSwf:String;

	public var InventoryRevealName:String;

	public var Id:UInt = 0;

	public var IconSwf:String;

	public var IconName:String;

	public var Description:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
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
