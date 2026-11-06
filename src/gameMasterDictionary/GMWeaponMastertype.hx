package gameMasterDictionary;

class GMWeaponMastertype {
	public var UISwfFilepath:String;

	public var Name:String;

	public var Id:UInt = 0;

	public var Icon:String;

	public var DontShowInTavern:Bool = false;

	public var Description:String;

	public var Constant:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		Constant = jsonAsset.Constant;
		Name = jsonAsset.Name;
		Icon = jsonAsset.Icon;
		UISwfFilepath = jsonAsset.UISwfFilepath;
		Description = jsonAsset.Description;
		DontShowInTavern = jsonAsset.DontShowInTavern != null && ASCompat.toBool(jsonAsset.DontShowInTavern);
	}
}
