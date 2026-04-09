package gameMasterDictionary
;
    class GMDooberDrop extends GMItem
   {
      
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
      
      public function new(param1:ASObject)
      {
         super(param1);
         BRUTE = ASCompat.toBool(param1.BRUTE);
         SKELETON_WARRIOR = ASCompat.toBool(param1.SKELETON_WARRIOR);
         SKELETON_ARCHER = ASCompat.toBool(param1.SKELETON_ARCHER);
         KNIGHT = ASCompat.toBool(param1.KNIGHT);
         CASTLE_BARREL = ASCompat.toBool(param1.CASTLE_BARREL);
         CASTLE_BOX = ASCompat.toBool(param1.CASTLE_BOX);
         CASTLE_SPIKES = ASCompat.toBool(param1.CASTLE_SPIKES);
         CASTLE_KINGSTATUE = ASCompat.toBool(param1.CASTLE_KINGSTATUE);
         CASTLE_FLAG = ASCompat.toBool(param1.CASTLE_FLAG);
         WOLF_PET = ASCompat.toBool(param1.WOLF_PET);
         WARCOW_PET = ASCompat.toBool(param1.WARCOW_PET);
         DEMON_PET = ASCompat.toBool(param1.DEMON_PET);
      }
   }


