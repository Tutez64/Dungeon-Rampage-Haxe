package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   
    class BlockAttackTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "block";
      
      var mMaximumDotForBlocking:Float = Math.NaN;
      
      var mPreviousBlockValue:Float = Math.NaN;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:Float)
      {
         super(param1,param2,param3);
         mMaximumDotForBlocking = param4;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : BlockAttackTimelineAction
      {
         var _loc5_= ASCompat.toNumber(param4.blockDot);
         return new BlockAttackTimelineAction(param1,param2,param3,_loc5_);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         mActorGameObject.isBlocking = true;
         mActorGameObject.maximumDotForBlocking = mMaximumDotForBlocking;
         mPreviousBlockValue = mActorGameObject.maximumDotForBlocking;
      }
      
      override public function stop() 
      {
         if(mActorGameObject != null)
         {
            mActorGameObject.maximumDotForBlocking = mPreviousBlockValue;
            mActorGameObject.isBlocking = false;
         }
         super.stop();
      }
   }


