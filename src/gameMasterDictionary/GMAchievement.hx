package gameMasterDictionary
;
    class GMAchievement
   {
      
      public var Id:String;
      
      public var Name:String;
      
      public var Descriptions:String;
      
      public var ImageLink:String;
      
      public var Points:UInt = 0;
      
      public function new(param1:ASObject)
      {
         
         Id = param1.Id;
         Name = param1.Name;
         Descriptions = param1.Descriptions;
         ImageLink = param1.ImageLink;
         Points = (ASCompat.toInt(param1.Points) : UInt);
      }
   }


