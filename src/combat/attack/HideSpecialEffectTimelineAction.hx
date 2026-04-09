package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   
    class HideSpecialEffectTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "hideSpecialEffect";
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         super(param1,param2,param3);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : HideSpecialEffectTimelineAction
      {
         return new HideSpecialEffectTimelineAction(param1,param2,param3);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mActorView.hideSpecialEffect();
      }
      
      override public function stop() 
      {
         mActorView.showSpecialEffect();
         super.stop();
      }
   }


