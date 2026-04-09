package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import distributedObjects.HeroGameObjectOwner;
   import facade.DBFacade;
   
    class ProposeReviveTimeLineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "proposeRevive";
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         super(param1,param2,param3);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : ProposeReviveTimeLineAction
      {
         return new ProposeReviveTimeLineAction(param1,param2,param3);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         var _loc2_= ASCompat.reinterpretAs(mActorGameObject , HeroGameObjectOwner);
         if(_loc2_ != null)
         {
            _loc2_.proposeRevive();
         }
      }
   }


