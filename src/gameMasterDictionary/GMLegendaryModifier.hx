package gameMasterDictionary
;
    class GMLegendaryModifier extends GMItem
   {
      
      public var IconName:String;
      
      public var Description:String;
      
      public function new(param1:ASObject)
      {
         super(param1);
         IconName = param1.IconName;
         Description = param1.Description;
      }
   }


