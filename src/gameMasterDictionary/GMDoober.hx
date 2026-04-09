package gameMasterDictionary
;
    class GMDoober extends GMItem
   {
      
      public var DooberType:String;
      
      public var SharedReward:String;
      
      public var InstantReward:String;
      
      public var ScaleVisual:Float = Math.NaN;
      
      public var AssetClassName:String;
      
      public var SwfFilePath:String;
      
      public var PickupSound:String;
      
      public var PickupVolume:Float = Math.NaN;
      
      public var Exp:UInt = 0;
      
      public var ChestId:UInt = 0;
      
      public var Rarity:String;
      
      public var HPPercentage:Float = Math.NaN;
      
      public var MPPercentage:Float = Math.NaN;
      
      public function new(param1:ASObject)
      {
         super(param1);
         DooberType = param1.DooberType;
         SharedReward = param1.SharedReward;
         ScaleVisual = 1;
         if(ASCompat.toBool(param1.ScaleVisual))
         {
            ScaleVisual = ASCompat.toNumberField(param1, "ScaleVisual");
         }
         InstantReward = param1.InstantReward;
         AssetClassName = param1.AssetClassName;
         SwfFilePath = param1.SwfFilepath;
         PickupSound = param1.PickupSound;
         PickupVolume = ASCompat.toNumberField(param1, "PickupVol");
         Exp = (ASCompat.toInt(param1.Exp) : UInt);
         ChestId = (ASCompat.toInt(param1.ChestId) : UInt);
         Rarity = param1.Rarity;
         HPPercentage = ASCompat.toNumberField(param1, "HP_PERCENTAGE");
         MPPercentage = ASCompat.toNumberField(param1, "MP_PERCENTAGE");
      }
      
      public function isFood() : Bool
      {
         return DooberType == "FOOD" || DooberType == "FOOD_COOK" || DooberType == "CHEF_FOOD";
      }
   }


