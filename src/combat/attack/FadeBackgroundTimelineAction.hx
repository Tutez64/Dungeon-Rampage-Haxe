package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class FadeBackgroundTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "fadebackground";
      
      var mDuration:UInt = 0;
      
      var mTransitionDuration:Float = Math.NaN;
      
      var mColor:Vector3D;
      
      var mOffset:Float = Math.NaN;
      
      var mAlpha:Float = Math.NaN;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:UInt, param5:Vector3D, param6:Float, param7:Float)
      {
         mDuration = param4;
         mTransitionDuration = param7;
         mColor = new Vector3D(param5.x,param5.y,param5.z);
         mAlpha = param6;
         mOffset = param6 / param7;
         super(param1,param2,param3);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : FadeBackgroundTimelineAction
      {
         var _loc5_= (ASCompat.toInt(param4.duration) : UInt);
         var _loc6_= new Vector3D(ASCompat.toNumberField(param4, "color_r"),ASCompat.toNumberField(param4, "color_g"),ASCompat.toNumberField(param4, "color_b"));
         var _loc8_= ASCompat.toNumber(param4.alpha);
         var _loc7_= ASCompat.toNumber(param4.transitionDur);
         return new FadeBackgroundTimelineAction(param1,param2,param3,_loc5_,_loc6_,_loc8_,_loc7_);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         if(!mActorGameObject.isOwner && !mDBFacade.camera.isPointOnScreen(mActorGameObject.position))
         {
            return;
         }
         super.execute(param1);
         var _loc2_:Array<ASAny> = [];
         _loc2_.push(mActorView.root);
         mDBFacade.camera.fadeBackground(_loc2_,mDuration,mTransitionDuration,mColor,mAlpha);
      }
      
      override public function stop() 
      {
         mDBFacade.camera.killBackgroundFader();
      }
   }


