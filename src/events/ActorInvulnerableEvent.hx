package events
;
    class ActorInvulnerableEvent extends GameObjectEvent
   {
      
      public var mIsInvulnerable:Bool = false;
      
      public function new(param1:String, param2:UInt, param3:Bool, param4:Bool = false, param5:Bool = false)
      {
         super(param1,param2,param4,param5);
         mIsInvulnerable = param3;
      }
   }


