package gameMasterDictionary;

class GMInventoryBase extends GMItem {
	public static inline final WEAPON_CATEGORY = "WEAPON";

	public static inline final POWERUP_CATEGORY = "POWERUP";

	public static inline final PET_CATEGORY = "PET";

	public static inline final STUFF_CATEGORY = "STUFF";

	public var Coins:Int = 0;

	public var Cash:Int = 0;

	public var CashB:Int = 0;

	public var CashC:Int = 0;

	public var CashD:Int = 0;

	public var CashE:Int = 0;

	public var CashF:Int = 0;

	public var CashG:Int = 0;

	public var CashH:Int = 0;

	public var CashI:Int = 0;

	public var SellCoins:Int = 0;

	public var IconName:String;

	public var UISwfFilepath:String;

	public var Description:String;

	public var ItemCategory:String;

	public var ItemSubclass:String;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		Coins = ASCompat.toInt(jsonAsset.Coins);
		Cash = ASCompat.toInt(jsonAsset.Cash);
		CashB = ASCompat.toInt(jsonAsset.CashB);
		CashC = ASCompat.toInt(jsonAsset.CashC);
		CashD = ASCompat.toInt(jsonAsset.CashD);
		CashE = ASCompat.toInt(jsonAsset.CashE);
		CashF = ASCompat.toInt(jsonAsset.CashF);
		CashG = ASCompat.toInt(jsonAsset.CashG);
		CashH = ASCompat.toInt(jsonAsset.CashH);
		CashI = ASCompat.toInt(jsonAsset.CashI);
		SellCoins = ASCompat.toInt(jsonAsset.SellCoins);
		ItemCategory = jsonAsset.ItemCategory;
		ItemSubclass = jsonAsset.ItemSubclass;
		IconName = jsonAsset.IconName;
		UISwfFilepath = jsonAsset.UISwfFilepath;
		Description = jsonAsset.Description;
	}
}
