package events
;
    class ManaEvent extends GameObjectEvent
   {
      
      public static inline final MANA_UPDATE= "ManaEvent_MANA_UPDATE";
      
      public var mana:UInt = 0;
      
      public var maxMana:UInt = 0;
      
      public function new(param1:String, param2:UInt, param3:UInt, param4:UInt, param5:Bool = false, param6:Bool = false)
      {
         this.mana = param3;
         this.maxMana = param4;
         super(param1,param2,param5,param6);
      }
   }


