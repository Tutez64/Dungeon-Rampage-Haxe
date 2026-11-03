package gameMasterDictionary;

import flash.Boot;

class GMProp extends GMItem {
	public var TileTheme:String;

	public var SwfFilepath:String;

	public var PropType:String;

	public var DefaultLayer:String;

	public var AssetClassName:String;

	public var ArchwayAlpha:Bool = false;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(jsonAsset);
			PropType = jsonAsset.PropType;
			AssetClassName = jsonAsset.AssetClassName;
			SwfFilepath = jsonAsset.SwfFilepath;
			DefaultLayer = jsonAsset.DefaultLayer;
			ArchwayAlpha = ASCompat.toBool(jsonAsset.ArchwayAlpha) == true;
			TileTheme = jsonAsset.TileTheme;
		}
	}
}
