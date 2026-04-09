package events
;
   import flash.events.Event;
   
    class ActorLifetimeEvent extends Event
   {
      
      public static inline final ACTOR_CREATE_EVENT= "ACTOR_CREATED";
      
      public static inline final ACTOR_DESTROY_EVENT= "ACTOR_DESTROYED";
      
      var mActorId:UInt = 0;
      
      public function new(param1:String, param2:UInt, param3:Bool = false, param4:Bool = false)
      {
         super(param1,param3,param4);
         mActorId = param2;
      }
      
      @:isVar public var actorId(get,never):UInt;
public function  get_actorId() : UInt
      {
         return mActorId;
      }
   }


