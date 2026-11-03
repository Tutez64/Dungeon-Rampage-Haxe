package gameMasterDictionary;

import dBGlobals.As3Compat;
import flash.Boot;

class GMProjectile extends GMItem {
	public var TrailTint:Float = Math.NaN;

	public var TrailSaturation:Float = Math.NaN;

	public var Tint:Float = Math.NaN;

	public var SwfFilepath:String;

	public var SteeringRate:Float = Math.NaN;

	public var Saturation:Float = Math.NaN;

	public var RotationSpeedF:Float = Math.NaN;

	public var Range:Float = Math.NaN;

	public var Proj_AOE:Float = Math.NaN;

	public var ProjSpeedF:Float = Math.NaN;

	public var ProjModel:String;

	public var OnImpactVFX:String;

	public var OnImpactNPC:String;

	public var OnDeathNPC:String;

	public var NumChains:UInt = 0;

	public var NumBranches:UInt = 0;

	public var NoGenerations:Bool = false;

	public var NoFade:Bool = false;

	public var MaxCollisions:UInt = 0;

	public var Lifetime:UInt = 0;

	public var ImpactVolume:Float = Math.NaN;

	public var ImpactSound:String;

	public var IgnoreWalls:Bool = false;

	public var IgnoreGlow:Bool = false;

	public var HomingDistWeight:Float = Math.NaN;

	public var HomingAngleWeight:Float = Math.NaN;

	public var HitsPerActor:Float = Math.NaN;

	public var HitRecurDelay:Float = Math.NaN;

	public var FlightPattern:String;

	public var Element:String;

	public var CyclicChains:Bool = false;

	public var CollisionSize:Float = Math.NaN;

	public var ClassType:String;

	public var ChainDist:Float = Math.NaN;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		var _loc2_:Float;
		var _loc3_:Float;
		if (!Boot.skip_constructor) {
			super(jsonAsset);
			ClassType = jsonAsset.ClassType;
			Element = jsonAsset.Element;
			FlightPattern = jsonAsset.FlightPattern;
			Range = ASCompat.toNumber(jsonAsset.Range);
			CollisionSize = ASCompat.toNumber(jsonAsset.CollisionSize);
			HitsPerActor = ASCompat.toNumber(jsonAsset.HitsPerActor);
			MaxCollisions = (ASCompat.toInt(jsonAsset.MaxCollisions) : UInt);
			HitRecurDelay = ASCompat.toNumber(jsonAsset.HitRecurDelay);
			NoGenerations = ASCompat.toBool(jsonAsset.NoGenerations);
			ProjSpeedF = ASCompat.toNumber(jsonAsset.ProjSpeed);
			RotationSpeedF = ASCompat.toNumber(jsonAsset.RotationSpeed);
			Proj_AOE = ASCompat.toNumber(jsonAsset.Proj_AOE);
			OnImpactNPC = jsonAsset.OnImpactNPC;
			OnImpactVFX = jsonAsset.OnImpactVFX;
			OnDeathNPC = jsonAsset.OnDeathNPC;
			NumChains = (ASCompat.toInt(jsonAsset.NumChains) : UInt);
			ChainDist = ASCompat.toNumber(jsonAsset.ChainDist);
			CyclicChains = ASCompat.toBool(jsonAsset.CyclicChains);
			NumBranches = (ASCompat.toInt(jsonAsset.NumBranches) : UInt);
			HomingDistWeight = Reflect.hasField(jsonAsset, "HomingDistWeight") ? ASCompat.toNumber(jsonAsset.HomingDistWeight) : 1;
			HomingAngleWeight = Reflect.hasField(jsonAsset, "HomingAngleWeight") ? ASCompat.toNumber(jsonAsset.HomingAngleWeight) : 1;
			SteeringRate = Reflect.hasField(jsonAsset, "SteeringRate") ? ASCompat.toNumber(jsonAsset.SteeringRate) : 1;
			Lifetime = (Reflect.hasField(jsonAsset,
				"Lifetime") ? (ASCompat.floatToInt(As3Compat.toFloat(jsonAsset.Lifetime) * 1000) : UInt) : (1000 : UInt):UInt);
			NoFade = Reflect.hasField(jsonAsset, "NoFade") && As3Compat.truthy(jsonAsset.NoFade);
			IgnoreWalls = Reflect.hasField(jsonAsset, "IgnoreWalls");
			Tint = ASCompat.toNumber(jsonAsset.Tint);
			_loc2_ = ASCompat.toNumber(jsonAsset.Saturation);
			Saturation = _loc2_ / 100 + 1;
			TrailTint = ASCompat.toNumber(jsonAsset.TrailTint);
			_loc3_ = ASCompat.toNumber(jsonAsset.TrailSaturation);
			TrailSaturation = _loc3_ / 100 + 1;
			ProjModel = jsonAsset.ProjModel;
			SwfFilepath = jsonAsset.SwfFilepath;
			ImpactSound = jsonAsset.ImpactSound;
			ImpactVolume = ASCompat.toNumber(jsonAsset.ImpactVol);
			IgnoreGlow = ASCompat.toBool(jsonAsset.IgnoreGlow);
		}
	}
}
