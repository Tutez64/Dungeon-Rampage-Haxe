package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   import com.greensock.TweenMax;
   
    class GlowTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "glow";
      
      var mDuration:Float = Math.NaN;
      
      var mGlowColor:String;
      
      var mBlurX:UInt = 0;
      
      var mBlurY:UInt = 0;
      
      var mGlowStrength:Float = Math.NaN;
      
      var mAlpha:Float = Math.NaN;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:Float, param5:String, param6:UInt, param7:UInt, param8:UInt, param9:Float)
      {
         mDuration = param4;
         mGlowColor = param5;
         mBlurX = param6;
         mBlurY = param7;
         mGlowStrength = param8;
         mAlpha = param9;
         super(param1,param2,param3);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : GlowTimelineAction
      {
         var _loc5_= ASCompat.toNumber(param4.duration);
         var _loc6_:String = param4.color;
         var _loc9_= (ASCompat.toInt(param4.blurX) : UInt);
         var _loc8_= (ASCompat.toInt(param4.blurY) : UInt);
         var _loc7_= (ASCompat.toInt(param4.strength) : UInt);
         var _loc10_= ASCompat.toNumber(param4.alpha);
         return new GlowTimelineAction(param1,param2,param3,_loc5_,_loc6_,_loc9_,_loc8_,_loc7_,_loc10_);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         TweenMax.to(mActorView.body,mDuration,{"glowFilter":{
            "color":mGlowColor,
            "blurX":mBlurX,
            "blurY":mBlurY,
            "strength":mGlowStrength,
            "alpha":mAlpha,
            "quality":3,
            "remove":true
         }});
      }
      
      override public function destroy() 
      {
         super.destroy();
      }
   }


