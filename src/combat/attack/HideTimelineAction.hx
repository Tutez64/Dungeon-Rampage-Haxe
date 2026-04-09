package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   
    class HideTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "visible";
      
      var value:Bool = false;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject)
      {
         super(param1,param2,param3);
         value = ASCompat.toBool(param4.value);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : HideTimelineAction
      {
         return new HideTimelineAction(param1,param2,param3,param4);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mActorGameObject.view.root.visible = value;
      }
      
      override public function stop() 
      {
         mActorGameObject.view.root.visible = true;
      }
   }


