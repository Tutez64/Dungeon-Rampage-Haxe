package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   
    class AnimationFrameAttackTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "animFrame";
      
      var mAnimName:String;
      
      public var mFrameNumber:UInt = 0;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:String, param5:UInt)
      {
         super(param1,param2,param3);
         mFrameNumber = param5;
         mAnimName = param4;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : AnimationFrameAttackTimelineAction
      {
         var _loc6_:String = param4.animName;
         var _loc5_= (ASCompat.toInt(param4.frame) : UInt);
         return new AnimationFrameAttackTimelineAction(param1,param2,param3,_loc6_,_loc5_);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mActorView.setAnimAt(mAnimName,mFrameNumber);
      }
   }


