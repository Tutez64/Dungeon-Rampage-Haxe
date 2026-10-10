package gameMasterDictionary;

class GMCashDeal {
	public var Id:UInt = 0;

	public var Name:String;

	public var Currency:String;

	public var Partner:String;

	var mPrice:Float = Math.NaN;

	public var Value:UInt = 0;

	public var Bonus:UInt = 0;

	public var Default:UInt = 0;

	public var ImageURL:String;

	public var ProductURL:String;

	public var SplitTest:String;

	public var Description:String;

	public var DragonKnightBonus:Bool = false;

	public function new(jsonAsset:ASObject, SplitTests:ASObject) {
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		Name = jsonAsset.Name;
		mPrice = ASCompat.toNumberField(jsonAsset, "Price");
		Value = (ASCompat.toInt(jsonAsset.Value) : UInt);
		Bonus = (ASCompat.toInt(jsonAsset.Bonus) : UInt);
		ImageURL = jsonAsset.ImageURL;
		ProductURL = jsonAsset.ProductURL;
		Description = jsonAsset.Description;
		Currency = jsonAsset.Currency;
		Partner = jsonAsset.Partner;
		Default = (ASCompat.toInt(jsonAsset.Default) : UInt);
		SplitTest = jsonAsset.SplitTest;
		DragonKnightBonus = ASCompat.asBool(jsonAsset.DragonKnightBonus);
	}

	@:isVar public var Price(get, never):Float;

	public function get_Price():Float {
		return mPrice;
	}
}
