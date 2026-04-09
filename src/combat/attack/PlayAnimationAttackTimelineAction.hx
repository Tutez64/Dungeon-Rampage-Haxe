package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   
    class PlayAnimationAttackTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "playAnim";
      
      var mAnimName:String;
      
      public var mStartFrame:UInt = 0;
      
      var mScriptTimeline:ScriptTimeline;
      
      public function new(param1:ScriptTimeline, param2:ActorGameObject, param3:ActorView, param4:DBFacade, param5:String, param6:UInt)
      {
         super(param2,param3,param4);
         mStartFrame = param6;
         mAnimName = param5;
         mScriptTimeline = param1;
      }
      
      public static function buildFromJson(param1:ScriptTimeline, param2:ActorGameObject, param3:ActorView, param4:DBFacade, param5:ASObject) : PlayAnimationAttackTimelineAction
      {
         var _loc7_:String = param5.animName;
         var _loc6_= (ASCompat.toInt(param5.startFrame) : UInt);
         return new PlayAnimationAttackTimelineAction(param1,param2,param3,param4,_loc7_,_loc6_);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mActorView.playAnim(mAnimName,(mStartFrame : Int),true,false,mScriptTimeline.playSpeed);
      }
   }


