package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.logger.Logger;
   import distributedObjects.DistributedDungeonFloor;
   import facade.DBFacade;
   import flash.display.MovieClip;
   import flash.geom.Vector3D;
   
    class PlayEffectTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "effect";
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      var mEffectName:String;
      
      var mEffectPath:String;
      
      var mXOffset:Float = Math.NaN;
      
      var mYOffset:Float = Math.NaN;
      
      var mHeadingOffset:Float = Math.NaN;
      
      var mHeadingOffsetAngle:Float = Math.NaN;
      
      var mParentToActor:Bool = false;
      
      var mPlayAtTarget:Bool = false;
      
      var mBehindAvatar:Bool = false;
      
      var mScale:Float = Math.NaN;
      
      var mAutoAdjustHeading:Bool = false;
      
      var mLoop:Bool = false;
      
      var mLayer:String;
      
      var mPlayRate:Float = Math.NaN;
      
      var mUseTimelineSpeed:Bool = false;
      
      var mInsertParentName:String;
      
      var mInsertIconPath:String;
      
      var mInsertIconName:String;
      
      var mInsertIconClip:MovieClip;
      
      var mInsertParentClip:MovieClip;
      
      var mDoIconInsert:Bool = false;
      
      public var mManaged:Bool = false;
      
      var mInvertAngles:Bool = false;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:String, param5:String, param6:Float = 0, param7:Float = 0, param8:Float = 0, param9:Float = 0, param10:Bool = false, param11:Bool = false, param12:Bool = false, param13:Float = 1, param14:Bool = false, param15:Bool = false, param16:String = "sorted", param17:Bool = false, param18:Bool = false, param19:Bool = false, param20:String = null, param21:String = null, param22:String = null)
      {
         super(param1,param2,param3);
         mEffectName = param4;
         mEffectPath = param5;
         mXOffset = param6;
         mYOffset = param7;
         mHeadingOffset = param8;
         mHeadingOffsetAngle = param9;
         mPlayAtTarget = param10;
         mParentToActor = param11;
         mBehindAvatar = param12;
         mScale = param13;
         mAutoAdjustHeading = param14;
         mLoop = param15;
         mLayer = param16 != null ? param16 : "sorted";
         mManaged = param17;
         if(!ASCompat.floatAsBool(mScale))
         {
            mScale = 1;
         }
         mPlayRate = 1;
         mUseTimelineSpeed = false;
         if(param18)
         {
            mUseTimelineSpeed = true;
         }
         mInvertAngles = param19;
         mInsertParentName = param20;
         mInsertIconPath = param21;
         mInsertIconName = param22;
         mDoIconInsert = mInsertParentName != null && mInsertIconPath != null && mInsertIconName != null;
         if(mDoIconInsert)
         {
            mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mInsertIconPath),iconAssetLoaded(this));
         }
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : PlayEffectTimelineAction
      {
         return new PlayEffectTimelineAction(param1,param2,param3,param4.name,param4.path,ASCompat.toNumberField(param4, "xOffset"),ASCompat.toNumberField(param4, "yOffset"),ASCompat.toNumberField(param4, "headingOffset"),ASCompat.toNumberField(param4, "headingOffsetAngle"),ASCompat.toBool(param4.playAtTarget),ASCompat.toBool(param4.parentToActor),ASCompat.toBool(param4.behindAvatar),ASCompat.toNumberField(param4, "scale"),ASCompat.toBool(param4.autoAdjustHeading),ASCompat.toBool(param4.loop),param4.layer,ASCompat.toBool(param4.managed),ASCompat.toBool(param4.useTimelineSpeed),ASCompat.toBool(param4.invertAngles),param4.insertParentName,param4.insertIconPath,param4.insertIconName);
      }
      
      override public function destroy() 
      {
         mDistributedDungeonFloor = null;
         mInsertIconClip = null;
         mInsertParentName = "";
         mInsertIconName = "";
         super.destroy();
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
      }
      
      function TryInsertClipIntoEffect() 
      {
         var _loc1_:MovieClip = null;
         if(mInsertIconClip != null && mInsertParentClip != null)
         {
            if(mInsertParentClip.getChildByName(mInsertParentName) == null)
            {
               Logger.warn("mInsertParentClip.getChildByName( " + mInsertParentClip + " ) == null");
               return;
            }
            _loc1_ = cast(mInsertParentClip.getChildByName(mInsertParentName), MovieClip);
            if(_loc1_ == null)
            {
               Logger.warn("parentNameMovieClip == null");
               return;
            }
            while(_loc1_.numChildren > 0)
            {
               _loc1_.removeChildAt(0);
            }
            _loc1_.addChild(mInsertIconClip);
         }
      }
      
      function iconAssetLoaded(param1:PlayEffectTimelineAction) : ASFunction
      {
         var timeline_action= param1;
         return function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass(timeline_action.mInsertIconName);
            if(_loc2_ == null)
            {
               Logger.error("Unable to find class: " + timeline_action.mInsertIconName);
               return;
            }
            timeline_action.mInsertIconClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
            timeline_action.mInsertIconClip.mouseChildren = false;
            timeline_action.mInsertIconClip.mouseEnabled = false;
            timeline_action.TryInsertClipIntoEffect();
         };
      }
      
      function assetLoadedCallback(param1:PlayEffectTimelineAction) : ASFunction
      {
         var timeline_action= param1;
         return function(param1:MovieClip)
         {
            timeline_action.mInsertParentClip = param1;
            timeline_action.TryInsertClipIntoEffect();
         };
      }
      
      public function calculateHeadingOffset(param1:Float, param2:Float, param3:Vector3D, param4:Float = 0) : Vector3D
      {
         param2 += param4;
         if(param2 < 0)
         {
            param2 = 360 + param2;
         }
         param2 = convertToRadians(param2);
         var _loc5_= new Vector3D(0,0,0);
         _loc5_.x = param3.x + param1 * Math.cos(param2);
         _loc5_.y = param3.y + param1 * Math.sin(param2);
         return _loc5_;
      }
      
      function convertToRadians(param1:Float) : Float
      {
         return param1 * 3.141592653589793 / 180;
      }
      
      @:isVar public var useTimelineSpeed(get,never):Bool;
public function  get_useTimelineSpeed() : Bool
      {
         return mUseTimelineSpeed;
      }
      
      public function calculatePositionBasedOnOffsets(param1:ActorGameObject) : Vector3D
      {
         var _loc3_:Vector3D = null;
         var _loc2_= new Vector3D(0,0,0);
         if(mPlayAtTarget)
         {
            _loc2_ = param1.position;
         }
         else
         {
            _loc3_ = new Vector3D(0,0,0);
            if(!mParentToActor)
            {
               if(ASCompat.floatAsBool(mHeadingOffset))
               {
                  _loc3_ = mActorGameObject.position;
               }
               else
               {
                  _loc2_ = mActorGameObject.position;
               }
            }
            if(!ASCompat.floatAsBool(mHeadingOffsetAngle))
            {
               mHeadingOffsetAngle = 0;
            }
            if(ASCompat.floatAsBool(mHeadingOffset))
            {
               _loc2_ = calculateHeadingOffset(mHeadingOffset,mActorGameObject.heading,_loc3_,mHeadingOffsetAngle);
            }
         }
         if(!ASCompat.floatAsBool(mYOffset))
         {
            mYOffset = 0;
         }
         if(!ASCompat.floatAsBool(mXOffset))
         {
            mXOffset = 0;
         }
         _loc2_.y += mYOffset;
         _loc2_.x += mXOffset;
         return _loc2_;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         if(mPlayAtTarget && param1.targetActor == null)
         {
            return;
         }
         mPlayRate = param1.playSpeed;
         var _loc2_:ActorGameObject = null;
         if(mParentToActor)
         {
            _loc2_ = mActorGameObject;
         }
         var _loc3_= calculatePositionBasedOnOffsets(param1.targetActor);
         var _loc4_= mActorGameObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(mEffectPath),mEffectName,_loc3_,_loc2_,mBehindAvatar,mScale,0,0,0,0,false,mLayer,mManaged,mPlayRate,ASCompat.asFunction(mDoIconInsert ? assetLoadedCallback(this) : null));
         if(mManaged)
         {
            param1.mManagedEffects.add(_loc4_);
         }
      }
   }


