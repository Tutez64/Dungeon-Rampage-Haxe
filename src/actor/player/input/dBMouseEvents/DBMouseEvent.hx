package actor.player.input.dBMouseEvents
;
   import actor.ActorGameObject;
   import flash.events.Event;
   
    class DBMouseEvent extends Event
   {
      
      var mActor:ActorGameObject;
      
      public function new(param1:String, param2:ActorGameObject, param3:Bool = false, param4:Bool = false)
      {
         super(param1,param3,param4);
         mActor = param2;
      }
      
      @:isVar public var actor(get,never):ActorGameObject;
public function  get_actor() : ActorGameObject
      {
         return mActor;
      }
   }


