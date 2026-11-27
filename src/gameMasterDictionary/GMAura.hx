package gameMasterDictionary;

class GMAura extends GMItem {
	public var HostileBuffGiven:String;

	public var FriendlyBuffGiven:String;

	public var Duration:Float = Math.NaN;

	public var DrainsMana:Float = Math.NaN;

	public var Description:String;

	public var AuraEffect:String;

	public var AreaRadius:Float = Math.NaN;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		super(jsonAsset);
		AuraEffect = jsonAsset.AuraEffect;
		Description = jsonAsset.Description;
	}
}
