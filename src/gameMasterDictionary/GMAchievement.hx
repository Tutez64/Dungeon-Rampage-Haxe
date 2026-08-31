package gameMasterDictionary;

class GMAchievement {
	public var Id:String;

	public var Name:String;

	public var Descriptions:String;

	public var ImageLink:String;

	public var Points:UInt = 0;

	public function new(jsonAsset:ASObject) {
		Id = jsonAsset.Id;
		Name = jsonAsset.Name;
		Descriptions = jsonAsset.Descriptions;
		ImageLink = jsonAsset.ImageLink;
		Points = (ASCompat.toInt(jsonAsset.Points) : UInt);
	}
}
