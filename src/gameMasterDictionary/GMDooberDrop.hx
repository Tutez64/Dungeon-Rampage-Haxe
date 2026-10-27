package gameMasterDictionary;

class GMDooberDrop extends GMItem {
	public var BRUTE:Bool = false;

	public var SKELETON_WARRIOR:Bool = false;

	public var SKELETON_ARCHER:Bool = false;

	public var KNIGHT:Bool = false;

	public var CASTLE_BARREL:Bool = false;

	public var CASTLE_BOX:Bool = false;

	public var CASTLE_SPIKES:Bool = false;

	public var CASTLE_KINGSTATUE:Bool = false;

	public var CASTLE_FLAG:Bool = false;

	public var WOLF_PET:Bool = false;

	public var WARCOW_PET:Bool = false;

	public var DEMON_PET:Bool = false;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		BRUTE = ASCompat.toBool(jsonAsset.BRUTE);
		SKELETON_WARRIOR = ASCompat.toBool(jsonAsset.SKELETON_WARRIOR);
		SKELETON_ARCHER = ASCompat.toBool(jsonAsset.SKELETON_ARCHER);
		KNIGHT = ASCompat.toBool(jsonAsset.KNIGHT);
		CASTLE_BARREL = ASCompat.toBool(jsonAsset.CASTLE_BARREL);
		CASTLE_BOX = ASCompat.toBool(jsonAsset.CASTLE_BOX);
		CASTLE_SPIKES = ASCompat.toBool(jsonAsset.CASTLE_SPIKES);
		CASTLE_KINGSTATUE = ASCompat.toBool(jsonAsset.CASTLE_KINGSTATUE);
		CASTLE_FLAG = ASCompat.toBool(jsonAsset.CASTLE_FLAG);
		WOLF_PET = ASCompat.toBool(jsonAsset.WOLF_PET);
		WARCOW_PET = ASCompat.toBool(jsonAsset.WARCOW_PET);
		DEMON_PET = ASCompat.toBool(jsonAsset.DEMON_PET);
	}
}
