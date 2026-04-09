package gameMasterDictionary
;
    class GMProjectile extends GMItem
   {
      
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
      
      public function new(param1:ASObject)
      {
         super(param1);
         ClassType = param1.ClassType;
         Element = param1.Element;
         FlightPattern = param1.FlightPattern;
         Range = ASCompat.toNumberField(param1, "Range");
         CollisionSize = ASCompat.toNumberField(param1, "CollisionSize");
         HitsPerActor = ASCompat.toNumberField(param1, "HitsPerActor");
         MaxCollisions = (ASCompat.toInt(param1.MaxCollisions) : UInt);
         HitRecurDelay = ASCompat.toNumberField(param1, "HitRecurDelay");
         NoGenerations = ASCompat.toBool(param1.NoGenerations);
         ProjSpeedF = ASCompat.toNumberField(param1, "ProjSpeed");
         RotationSpeedF = ASCompat.toNumberField(param1, "RotationSpeed");
         Proj_AOE = ASCompat.toNumberField(param1, "Proj_AOE");
         OnImpactNPC = param1.OnImpactNPC;
         OnImpactVFX = param1.OnImpactVFX;
         OnDeathNPC = param1.OnDeathNPC;
         NumChains = (ASCompat.toInt(param1.NumChains) : UInt);
         ChainDist = ASCompat.toNumberField(param1, "ChainDist");
         CyclicChains = ASCompat.toBool(param1.CyclicChains);
         NumBranches = (ASCompat.toInt(param1.NumBranches) : UInt);
         HomingDistWeight = ASCompat.toNumber(param1.hasOwnProperty("HomingDistWeight") ? ASCompat.toNumberField(param1, "HomingDistWeight") : 1);
         HomingAngleWeight = ASCompat.toNumber(param1.hasOwnProperty("HomingAngleWeight") ? ASCompat.toNumberField(param1, "HomingAngleWeight") : 1);
         SteeringRate = ASCompat.toNumber(param1.hasOwnProperty("SteeringRate") ? ASCompat.toNumberField(param1, "SteeringRate") : 1);
         Lifetime = (Std.int(param1.hasOwnProperty("Lifetime") ? (Std.int(ASCompat.toNumber(param1.Lifetime) * 1000) : UInt) : (1000 : UInt)) : UInt);
         NoFade = param1.hasOwnProperty("NoFade") ? ASCompat.toBool(param1.NoFade) : false;
         IgnoreWalls = param1.hasOwnProperty("IgnoreWalls") ? true : false;
         Tint = ASCompat.toNumberField(param1, "Tint");
         Saturation = ASCompat.toNumberField(param1, "Saturation") / 100 + 1;
         TrailTint = ASCompat.toNumberField(param1, "TrailTint");
         TrailSaturation = ASCompat.toNumberField(param1, "TrailSaturation") / 100 + 1;
         ProjModel = param1.ProjModel;
         SwfFilepath = param1.SwfFilepath;
         ImpactSound = param1.ImpactSound;
         ImpactVolume = ASCompat.toNumberField(param1, "ImpactVol");
         IgnoreGlow = ASCompat.toBool(param1.IgnoreGlow);
      }
   }


