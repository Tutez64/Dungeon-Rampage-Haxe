package gameMasterDictionary;

class GMWeaponMastertype {
	public var Id:UInt = 0;

	public var Constant:String;

	public var Name:String;

	public var Icon:String;

	public var UISwfFilepath:String;

	public var Description:String;

	public var DontShowInTavern:Bool = false;

	public function new(jsonAsset:ASObject) {
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		Constant = jsonAsset.Constant;
		Name = jsonAsset.Name;
		Icon = jsonAsset.Icon;
		UISwfFilepath = jsonAsset.UISwfFilepath;
		Description = jsonAsset.Description;
		DontShowInTavern = ASCompat.toBool(jsonAsset.DontShowInTavern != null ? ASCompat.toBool(jsonAsset.DontShowInTavern) : false);
	}
}
