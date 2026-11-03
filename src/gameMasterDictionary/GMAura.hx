package gameMasterDictionary;

import flash.Boot;

class GMAura extends GMItem {
	public var HostileBuffGiven:String;

	public var FriendlyBuffGiven:String;

	public var Duration:Float = Math.NaN;

	public var DrainsMana:Float = Math.NaN;

	public var Description:String;

	public var AuraEffect:String;

	public var AreaRadius:Float = Math.NaN;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(jsonAsset);
			AuraEffect = jsonAsset.AuraEffect;
			Description = jsonAsset.Description;
		}
	}
}
