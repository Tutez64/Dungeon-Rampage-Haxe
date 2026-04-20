package effects
;
   import actor.ActorGameObject;
   import brain.event.EventComponent;
   import facade.DBFacade;
   import com.greensock.TimelineMax;
   import com.greensock.TweenMax;
   import com.greensock.easing.Circ;
   import com.greensock.easing.Sine;
   import flash.events.Event;
   import flash.geom.Vector3D;
   
    class LerpEffectGameObject extends EffectGameObject
   {
      
      var mLerpTargetActor:ActorGameObject;
      
      var mLerpSpeed:Float = Math.NaN;
      
      public var mLerpTempSpeed:Float = Math.NaN;
      
      var mLerpTimeline:TimelineMax;
      
      var mLerpTargetPositionVector:Vector3D;
      
      var mLerpGlowColor:UInt = 0;
      
      var mEventComponent:EventComponent;
      
      public function new(param1:DBFacade, param2:String, param3:String, param4:Float, param5:UInt = (0 : UInt), param6:ASFunction = null, param7:ActorGameObject = null, param8:Float = 1, param9:UInt = (13369344 : UInt))
      {
         var facade= param1;
         var swfPath= param2;
         var className= param3;
         var playRate= param4;
         var remoteId= param5;
         var assetLoadedCallback= param6;
         var lerpToActor= param7;
         var lerpSpeed= param8;
         var lerpGlowColor= param9;
         super(facade,swfPath,className,playRate,remoteId,assetLoadedCallback);
         mLerpTargetActor = lerpToActor;
         mLerpSpeed = lerpSpeed + Math.random() * lerpSpeed / 2;
         mLerpGlowColor = lerpGlowColor;
         mLerpTargetPositionVector = new Vector3D(0,-50,0);
         mEventComponent = new EventComponent(facade);
         mEventComponent.addListener("enterFrame",update);
         mLerpTempSpeed = 0;
         mLerpTimeline = new TimelineMax();
         mLerpTimeline.append(new TweenMax(this,0.1,{
            "mLerpTempSpeed":-mLerpSpeed,
            "onComplete":function()
            {
               mLerpTempSpeed = 0;
            }
         }));
         mLerpTimeline.append(new TweenMax(this,0.65,{
            "mLerpTempSpeed":mLerpSpeed,
            "ease":Circ.easeIn
         }));
         mLerpTimeline.play();
      }
      
      function update(param1:Event) 
      {
         var _loc3_:Vector3D = null;
         var _loc4_:Vector3D = null;
         var _loc2_= Math.NaN;
         if(mLerpTargetActor != null && mLerpTargetActor.position != null)
         {
            _loc3_ = mLerpTargetActor.position.add(mLerpTargetPositionVector);
            _loc4_ = _loc3_.subtract(mEffectView.position);
            _loc2_ = _loc4_.length;
            _loc4_.normalize();
            _loc4_.scaleBy(mLerpTempSpeed);
            mEffectView.position = mEffectView.position.add(_loc4_);
            if(_loc2_ < 15)
            {
               TweenMax.to(mLerpTargetActor.actorView.body,0.05,{"glowFilter":{
                  "color":mLerpGlowColor,
                  "alpha":1,
                  "blurX":15,
                  "blurY":15,
                  "remove":true,
                  "ease":Sine.easeInOut
               }});
               destroy();
            }
         }
         else
         {
            destroy();
         }
      }
      
      override public function destroy() 
      {
         if(mEventComponent != null)
         {
            mEventComponent.removeListener("enterFrame");
            mEventComponent.destroy();
            mEventComponent = null;
         }
         super.destroy();
      }
   }


