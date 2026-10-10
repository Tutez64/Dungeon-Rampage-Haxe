package gameMasterDictionary;

class GMAura extends GMItem {
	public var Duration:Float = Math.NaN;

	public var DrainsMana:Float = Math.NaN;

	public var AreaRadius:Float = Math.NaN;

	public var FriendlyBuffGiven:String;

	public var HostileBuffGiven:String;

	public var AuraEffect:String;

	public var Description:String;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		AuraEffect = jsonAsset.AuraEffect;
		Description = jsonAsset.Description;
	}
}
