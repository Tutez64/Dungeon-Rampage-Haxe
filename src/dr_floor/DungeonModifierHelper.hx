package dr_floor
;
   import brain.logger.Logger;
   import facade.DBFacade;
   import gameMasterDictionary.GMDungeonModifier;
   
    class DungeonModifierHelper
   {
      
      public var GMDungeonMod:GMDungeonModifier;
      
      public var NewThisFloor:Bool = false;
      
      public function new(param1:UInt, param2:Bool, param3:DBFacade)
      {
         
         GMDungeonMod = ASCompat.dynamicAs(param3.gameMaster.dungeonModifierById.itemFor(param1), gameMasterDictionary.GMDungeonModifier);
         if(GMDungeonMod == null)
         {
            Logger.error("Unable to find GMDungeonModifier with ID: " + param1);
         }
         NewThisFloor = param2;
      }
   }


