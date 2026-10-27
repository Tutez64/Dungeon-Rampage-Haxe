package gameMasterDictionary;

class GMProp extends GMItem {
	public var PropType:String;

	public var AssetClassName:String;

	public var SwfFilepath:String;

	public var DefaultLayer:String;

	public var ArchwayAlpha:Bool = false;

	public var TileTheme:String;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		PropType = jsonAsset.PropType;
		AssetClassName = jsonAsset.AssetClassName;
		SwfFilepath = jsonAsset.SwfFilepath;
		DefaultLayer = jsonAsset.DefaultLayer;
		ArchwayAlpha = jsonAsset.ArchwayAlpha == true;
		TileTheme = jsonAsset.TileTheme;
	}
}
