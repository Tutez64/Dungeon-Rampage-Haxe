package events
;
    class BusterPointsEvent extends GameObjectEvent
   {
      
      public static inline final BUSTER_POINTS_UPDATE= "BusterPointEvent_BUSTER_POINTS_UPDATE";
      
      public var busterPoints:UInt = 0;
      
      public var maxBusterPoints:UInt = 0;
      
      public function new(param1:String, param2:UInt, param3:UInt, param4:UInt, param5:Bool = false, param6:Bool = false)
      {
         this.busterPoints = param3;
         this.maxBusterPoints = param4;
         super(param1,param2,param5,param6);
      }
   }


