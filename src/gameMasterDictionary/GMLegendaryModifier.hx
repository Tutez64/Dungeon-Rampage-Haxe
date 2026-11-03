package gameMasterDictionary;

import flash.Boot;

class GMLegendaryModifier extends GMItem {
	public var IconName:String;

	public var Description:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(jsonAsset);
			IconName = jsonAsset.IconName;
			Description = jsonAsset.Description;
		}
	}
}
