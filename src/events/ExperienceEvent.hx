package events
;
    class ExperienceEvent extends GameObjectEvent
   {
      
      public static inline final EXPERIENCE_UPDATE= "ExperienceEvent_EXPERIENCE_UPDATE";
      
      public var experience:UInt = 0;
      
      public function new(param1:String, param2:UInt, param3:UInt, param4:Bool = false, param5:Bool = false)
      {
         this.experience = param3;
         super(param1,param2,param4,param5);
      }
   }


