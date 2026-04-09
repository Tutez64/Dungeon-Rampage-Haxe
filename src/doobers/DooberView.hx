package doobers
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.render.MovieClipRenderController;
   import brain.sound.SoundAsset;
   import distributedObjects.HeroGameObject;
   import facade.DBFacade;
   import dr_floor.FloorView;
   import sound.DBSoundComponent;
   import com.greensock.*;
   import com.greensock.easing.*;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Map;
   
    class DooberView extends FloorView
   {
      
      static inline final LOOP_HEIGHT= 270;
      
      static inline final LOOP_DURATION:Float = 0.9;
      
      static inline final LOOP_DURATION_RAND:Float = 0.3;
      
      static inline final LOOP1_TIME= 60;
      
      static inline final LOOP2_TIME= 40;
      
      static inline final LOOP1_HEIGHT= 75;
      
      static inline final LOOP2_HEIGHT= 25;
      
      static inline final TWEEN_TO_UI_TIME:Float = 0.5;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mDoober:MovieClip;
      
      var mBody:Sprite;
      
      var mDooberGameObject:DooberGameObject;
      
      var mBounceTimeline:TimelineMax;
      
      var mMoveToUITween:TweenMax;
      
      var mEndPos:Vector3D;
      
      var mSoundComponent:DBSoundComponent;
      
      var mPickupSound:SoundAsset;
      
      var mDooberRenderer:MovieClipRenderController;
      
      var mDooberSwfAsset:SwfAsset;
      
      public function new(param1:DBFacade, param2:DooberGameObject)
      {
         super(param1,param2);
         mDooberGameObject = param2;
         mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
         mSoundComponent = new DBSoundComponent(param1);
         mRoot.name = "DooberView_" + mDooberGameObject.id;
         mBody = new Sprite();
         mBody.name = "mBody";
         mRoot.addChild(mBody);
      }
      
      override public function init() 
      {
         super.init();
         mBody.scaleX = mBody.scaleY = mDooberGameObject.mDooberData.ScaleVisual;
         mAssetLoadingComponent.getSwfAsset(mDooberGameObject.swfPath,assetLoaded);
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mDooberGameObject.mDooberData.PickupSound,soundLoaded);
         mRoot.mouseEnabled = false;
         mRoot.mouseChildren = false;
      }
      
      function soundLoaded(param1:SoundAsset) 
      {
         mPickupSound = param1;
      }
      
      function assetLoaded(param1:SwfAsset) 
      {
         mDooberRenderer = ASCompat.reinterpretAs(mDBFacade.movieClipPool.checkout(mDBFacade,param1,mDooberGameObject.className) , MovieClipRenderController);
         mDoober = mDooberRenderer.clip;
         if(ASCompat.toBool((mDoober : ASAny).doober_shadow))
         {
            ASCompat.setProperty((mDoober : ASAny).doober_shadow, "visible", true);
         }
         mBody.addChild(mDoober);
         mDooberRenderer.play((0 : UInt),true);
         this.layer = mDooberGameObject.layer;
      }
      
      function checkinDoober() 
      {
         mDBFacade.movieClipPool.checkin(mDooberRenderer);
         mDooberRenderer = null;
         mDoober = null;
      }
      
      public function collectedEffect(param1:Bool, param2:UInt, param3:ASFunction) 
      {
         var localPoint:Point;
         var globalPoint:Point;
         var dooberType:String;
         var dooberId:UInt;
         var isHeroOwner= param1;
         var playerId= param2;
         var animationComplete= param3;
         var callback:ASFunction = function()
         {
            checkinDoober();
            animationComplete();
         };
         if(mBounceTimeline != null)
         {
            mBounceTimeline.kill();
            mBounceTimeline = null;
         }
         if(mPickupSound != null)
         {
            mSoundComponent.playSfxOneShot(mPickupSound,worldCenter,0,mDooberGameObject != null ? mDooberGameObject.mDooberData.PickupVolume : 1);
         }
         localPoint = new Point(0,0);
         globalPoint = mRoot.localToGlobal(localPoint);
         this.removeFromStage();
         mDooberGameObject.layer = 50;
         this.addToStage();
         mRoot.x = globalPoint.x;
         mRoot.y = globalPoint.y;
         mBody.x = mBody.y = 0;
         if(mDooberRenderer != null)
         {
            mDooberRenderer.stop();
            mDooberRenderer.setFrame((0 : UInt));
         }
         if(mDoober != null && ASCompat.toBool((mDoober : ASAny).doober_shadow))
         {
            ASCompat.setProperty((mDoober : ASAny).doober_shadow, "visible", false);
         }
         dooberType = mDooberGameObject.mDooberData.DooberType;
         dooberId = mDooberGameObject.mDooberData.ChestId;
         if(mDooberGameObject.mDooberData.InstantReward != "1")
         {
            mMoveToUITween = moveToTeamUI(callback,dooberId);
         }
         else if(isHeroOwner)
         {
            mMoveToUITween = moveToUI(dooberType,callback);
         }
         else if(mDooberGameObject.mDooberData.SharedReward == "1" && checkPlayerOnScreen(playerId))
         {
            mMoveToUITween = moveToUI(dooberType,callback);
         }
         else
         {
            callback();
         }
      }
      
      public function animateDooberBounce(param1:Vector3D, param2:Vector3D) 
      {
         if(mDoober == null)
         {
            return;
         }
         if(mDoober != null && ASCompat.toBool((mDoober : ASAny).doober_shadow))
         {
            ASCompat.setProperty((mDoober : ASAny).doober_shadow, "visible", false);
         }
         mEndPos = param2;
         this.mRoot.x = param1.x;
         this.mRoot.y = param1.y;
         mBounceTimeline = new TimelineMax();
         var _loc6_= 0.9 + Math.random() * 0.3;
         var _loc3_= _loc6_ * 60 / (60 + 40);
         var _loc4_= _loc6_ * 40 / (60 + 40);
         var _loc8_= Vector3D.distance(param1,param2);
         var _loc11_= Math.atan2(param2.y - param1.y,param2.x - param1.x);
         var _loc5_= _loc8_ * 60 / (60 + 40);
         var _loc10_= new Vector3D(param1.x + _loc5_ * Math.cos(_loc11_),param1.y + _loc5_ * Math.sin(_loc11_));
         var _loc9_= new Vector3D((param1.x + _loc10_.x) / 2,param1.y - 270 * 75 / (75 + 25));
         var _loc7_= new Vector3D((_loc10_.x + param2.x) / 2,_loc10_.y - 270 * 25 / (75 + 25));
         mBounceTimeline.addLabel("start",0);
         mBounceTimeline.addLabel("loop1",_loc3_ / 2);
         mBounceTimeline.addLabel("mid",_loc3_);
         mBounceTimeline.addLabel("loop2",_loc3_ + _loc4_ / 2);
         mBounceTimeline.addLabel("end",_loc3_ + _loc4_);
         var _loc12_= _loc3_ + _loc4_;
         mBounceTimeline.append(new TweenMax(this.mRoot,_loc12_,{"x":param2.x}));
         mBounceTimeline.insert(new TweenMax(this.mBody,_loc3_ / 2,{
            "y":_loc9_.y - param1.y,
            "ease":Quad.easeOut
         }),"start");
         mBounceTimeline.insert(new TweenMax(this.mBody,_loc3_ / 2,{
            "y":_loc10_.y - param1.y,
            "ease":Quad.easeIn
         }),"loop1");
         mBounceTimeline.insert(new TweenMax(this.mBody,_loc4_ / 2,{
            "y":_loc7_.y - param1.y,
            "ease":Quad.easeOut
         }),"mid");
         mBounceTimeline.insert(new TweenMax(this.mBody,_loc4_ / 2,{
            "y":param2.y - param1.y,
            "ease":Quad.easeIn,
            "onComplete":timelineComplete
         }),"loop2");
         mBounceTimeline.play();
      }
      
      function timelineComplete() 
      {
         mRoot.x = mEndPos.x;
         mRoot.y = mEndPos.y;
         mBody.x = mBody.y = 0;
         if(mDooberRenderer != null)
         {
            mDooberRenderer.play((0 : UInt),true);
         }
         if(mDoober != null && ASCompat.toBool((mDoober : ASAny).doober_shadow))
         {
            ASCompat.setProperty((mDoober : ASAny).doober_shadow, "visible", true);
         }
      }
      
      function moveToUI(param1:String, param2:ASFunction) : TweenMax
      {
         var _loc3_:ASAny = null;
         var _loc4_:Vector3D = null;
         switch(param1)
         {
            case "GOLD"
               | "COIN"
               | "TREASURE":
               _loc4_ = mDBFacade.hud.coinsDestination;
               
            case "EXP":
               _loc4_ = mDBFacade.hud.expDestination;
               
            case "CROWD"
               | "FAME":
               _loc4_ = mDBFacade.hud.crowdDestination;
               
            default:
               _loc4_ = mDBFacade.hud.profileDestination;
         }
         return TweenMax.to(this.mRoot,0.5,{
            "x":_loc4_.x,
            "y":_loc4_.y,
            "onComplete":param2
         });
      }
      
      function moveToTeamUI(param1:ASFunction, param2:UInt) : TweenMax
      {
         var _loc3_= new Vector3D();
         if(this.mDBFacade.hud != null)
         {
            _loc3_ = mDBFacade.hud.teamLootDestination;
            this.mDBFacade.hud.openTeamLoot(param2);
         }
         if(param2 == 60001)
         {
            return TweenMax.to(this.mRoot,0.5,{
               "x":_loc3_.x,
               "y":_loc3_.y,
               "scaleX":0.8,
               "scaleY":0.8,
               "alpha":0.2,
               "onComplete":param1
            });
         }
         if(param2 == 60004)
         {
            return TweenMax.to(this.mRoot,0.5,{
               "x":_loc3_.x,
               "y":_loc3_.y,
               "scaleX":0.5,
               "scaleY":0.5,
               "alpha":0.2,
               "onComplete":param1
            });
         }
         return TweenMax.to(this.mRoot,0.5,{
            "x":_loc3_.x,
            "y":_loc3_.y,
            "scaleX":0.6,
            "scaleY":0.6,
            "alpha":0.2,
            "onComplete":param1
         });
      }
      
      function checkPlayerOnScreen(param1:UInt) : Bool
      {
         var _loc2_:Map = null;
         var _loc3_:HeroGameObject = null;
         if(mDooberGameObject != null && mDooberGameObject.distributedDungeonFloor != null && mDooberGameObject.distributedDungeonFloor.remoteHeroes.size > 0)
         {
            _loc2_ = mDooberGameObject.distributedDungeonFloor.remoteHeroes;
            _loc3_ = ASCompat.dynamicAs(_loc2_.itemFor(param1) , HeroGameObject);
            if(_loc3_ != null)
            {
               return mFacade.camera.isPointOnScreen(_loc3_.view.position);
            }
         }
         return false;
      }
      
      override public function destroy() 
      {
         if(mDooberRenderer != null)
         {
            this.checkinDoober();
         }
         if(mBounceTimeline != null)
         {
            mBounceTimeline.kill();
            mBounceTimeline = null;
         }
         if(mMoveToUITween != null)
         {
            mMoveToUITween.kill();
            mMoveToUITween = null;
         }
         TweenMax.killTweensOf(this.mRoot);
         TweenMax.killTweensOf(this.mBody);
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mSoundComponent.destroy();
         mSoundComponent = null;
         mPickupSound = null;
         mDoober = null;
         mDooberRenderer = null;
         mBody = null;
         mDooberGameObject = null;
         super.destroy();
      }
   }


