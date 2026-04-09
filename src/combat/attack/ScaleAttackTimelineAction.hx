package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   
    class ScaleAttackTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "scale";
      
      var originalScaleValue:Float = Math.NaN;
      
      var scaleValue:Float = Math.NaN;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:Float, param4:DBFacade)
      {
         super(param1,param2,param4);
         scaleValue = param3;
         originalScaleValue = param2.root.scaleX;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : ScaleAttackTimelineAction
      {
         var _loc5_= ASCompat.toNumber(param4.value);
         return new ScaleAttackTimelineAction(param1,param2,_loc5_,param3);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mActorView.root.scaleX = mActorView.root.scaleY = scaleValue;
      }
      
      override public function stop() 
      {
         mActorView.root.scaleX = mActorView.root.scaleY = originalScaleValue;
         super.stop();
      }
   }


