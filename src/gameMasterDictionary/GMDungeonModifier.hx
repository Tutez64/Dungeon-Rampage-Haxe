package gameMasterDictionary
;
    class GMDungeonModifier
   {
      
      public var Id:UInt = 0;
      
      public var Constant:String;
      
      public var Name:String;
      
      public var Description:String;
      
      public var BuffId:UInt = 0;
      
      public var IsPlayerBuff:Bool = false;
      
      public var NPCSpawnId:UInt = 0;
      
      public var NPCDeathSpawnId:UInt = 0;
      
      public var NPCDeathSpawnCharType:String;
      
      public var NPCDeathSpawnMaxGeneration:UInt = 0;
      
      public var NPCDeathSpawnChance:Float = Math.NaN;
      
      public var NPCDeathSpawnMinCount:UInt = 0;
      
      public var NPCDeathSpawnMaxCount:UInt = 0;
      
      public var IconFilepath:String;
      
      public var IconName:String;
      
      public function new(param1:ASObject)
      {
         
         Id = (ASCompat.toInt(param1.Id) : UInt);
         Constant = param1.Constant;
         Name = param1.Name;
         Description = param1.Description;
         BuffId = (ASCompat.toInt(param1.BuffId) : UInt);
         IsPlayerBuff = ASCompat.toBool(param1.IsPlayerBuff);
         NPCSpawnId = (ASCompat.toInt(param1.NPCSpawnId) : UInt);
         NPCDeathSpawnId = (ASCompat.toInt(param1.NPCDeathSpawnId) : UInt);
         NPCDeathSpawnCharType = param1.NPCDeathSpawnCharType;
         NPCDeathSpawnMaxGeneration = (ASCompat.toInt(param1.NPCDeathSpawnMaxGeneration) : UInt);
         NPCDeathSpawnChance = ASCompat.toNumberField(param1, "NPCDeathSpawnChance");
         NPCDeathSpawnMinCount = (ASCompat.toInt(param1.NPCDeathSpawnMinCount) : UInt);
         NPCDeathSpawnMaxCount = (ASCompat.toInt(param1.NPCDeathSpawnMaxCount) : UInt);
         IconFilepath = param1.IconFilepath;
         IconName = param1.IconName;
      }
   }


