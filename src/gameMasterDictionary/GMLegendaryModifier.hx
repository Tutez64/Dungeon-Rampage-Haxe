package gameMasterDictionary;

class GMLegendaryModifier extends GMItem {
	public var IconName:String;

	public var Description:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		super(jsonAsset);
		IconName = jsonAsset.IconName;
		Description = jsonAsset.Description;
	}
}
