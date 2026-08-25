package gameMasterDictionary;

class GMProjectile extends GMItem {
	public var ClassType:String;

	public var Element:String;

	public var FlightPattern:String;

	public var Range:Float = Math.NaN;

	public var CollisionSize:Float = Math.NaN;

	public var HitsPerActor:Float = Math.NaN;

	public var HitRecurDelay:Float = Math.NaN;

	public var MaxCollisions:UInt = 0;

	public var NoGenerations:Bool = false;

	public var ProjSpeedF:Float = Math.NaN;

	public var RotationSpeedF:Float = Math.NaN;

	public var Proj_AOE:Float = Math.NaN;

	public var OnImpactNPC:String;

	public var OnDeathNPC:String;

	public var OnImpactVFX:String;

	public var NumChains:UInt = 0;

	public var ChainDist:Float = Math.NaN;

	public var CyclicChains:Bool = false;

	public var NumBranches:UInt = 0;

	public var HomingDistWeight:Float = Math.NaN;

	public var HomingAngleWeight:Float = Math.NaN;

	public var SteeringRate:Float = Math.NaN;

	public var Lifetime:UInt = 0;

	public var SwfFilepath:String;

	public var ImpactSound:String;

	public var ImpactVolume:Float = Math.NaN;

	public var NoFade:Bool = false;

	public var IgnoreWalls:Bool = false;

	public var Tint:Float = Math.NaN;

	public var Saturation:Float = Math.NaN;

	public var TrailTint:Float = Math.NaN;

	public var TrailSaturation:Float = Math.NaN;

	public var ProjModel:String;

	public var IgnoreGlow:Bool = false;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		ClassType = jsonAsset.ClassType;
		Element = jsonAsset.Element;
		FlightPattern = jsonAsset.FlightPattern;
		Range = ASCompat.toNumberField(jsonAsset, "Range");
		CollisionSize = ASCompat.toNumberField(jsonAsset, "CollisionSize");
		HitsPerActor = ASCompat.toNumberField(jsonAsset, "HitsPerActor");
		MaxCollisions = (ASCompat.toInt(jsonAsset.MaxCollisions) : UInt);
		HitRecurDelay = ASCompat.toNumberField(jsonAsset, "HitRecurDelay");
		NoGenerations = ASCompat.toBool(jsonAsset.NoGenerations);
		ProjSpeedF = ASCompat.toNumberField(jsonAsset, "ProjSpeed");
		RotationSpeedF = ASCompat.toNumberField(jsonAsset, "RotationSpeed");
		Proj_AOE = ASCompat.toNumberField(jsonAsset, "Proj_AOE");
		OnImpactNPC = jsonAsset.OnImpactNPC;
		OnImpactVFX = jsonAsset.OnImpactVFX;
		OnDeathNPC = jsonAsset.OnDeathNPC;
		NumChains = (ASCompat.toInt(jsonAsset.NumChains) : UInt);
		ChainDist = ASCompat.toNumberField(jsonAsset, "ChainDist");
		CyclicChains = ASCompat.toBool(jsonAsset.CyclicChains);
		NumBranches = (ASCompat.toInt(jsonAsset.NumBranches) : UInt);
		HomingDistWeight = ASCompat.toNumber(jsonAsset.hasOwnProperty("HomingDistWeight") ? ASCompat.toNumberField(jsonAsset, "HomingDistWeight") : 1);
		HomingAngleWeight = ASCompat.toNumber(jsonAsset.hasOwnProperty("HomingAngleWeight") ? ASCompat.toNumberField(jsonAsset, "HomingAngleWeight") : 1);
		SteeringRate = ASCompat.toNumber(jsonAsset.hasOwnProperty("SteeringRate") ? ASCompat.toNumberField(jsonAsset, "SteeringRate") : 1);
		Lifetime = (Std.int(jsonAsset.hasOwnProperty("Lifetime") ? (Std.int(ASCompat.toNumber(jsonAsset.Lifetime) * 1000) : UInt) : (1000 : UInt)) : UInt);
		NoFade = jsonAsset.hasOwnProperty("NoFade") ? ASCompat.toBool(jsonAsset.NoFade) : false;
		IgnoreWalls = jsonAsset.hasOwnProperty("IgnoreWalls") ? true : false;
		Tint = ASCompat.toNumberField(jsonAsset, "Tint");
		Saturation = ASCompat.toNumberField(jsonAsset, "Saturation") / 100 + 1;
		TrailTint = ASCompat.toNumberField(jsonAsset, "TrailTint");
		TrailSaturation = ASCompat.toNumberField(jsonAsset, "TrailSaturation") / 100 + 1;
		ProjModel = jsonAsset.ProjModel;
		SwfFilepath = jsonAsset.SwfFilepath;
		ImpactSound = jsonAsset.ImpactSound;
		ImpactVolume = ASCompat.toNumberField(jsonAsset, "ImpactVol");
		IgnoreGlow = ASCompat.toBool(jsonAsset.IgnoreGlow);
	}
}
