package events
;
    class HpEvent extends GameObjectEvent
   {
      
      public static inline final HP_UPDATE= "HpEvent_HP_UPDATE";
      
      public var hp:UInt = 0;
      
      public var maxHp:UInt = 0;
      
      public function new(param1:String, param2:UInt, param3:UInt, param4:UInt, param5:Bool = false, param6:Bool = false)
      {
         this.hp = param3;
         this.maxHp = param4;
         super(param1,param2,param5,param6);
      }
   }


