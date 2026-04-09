package uI
;
   import account.PlayerSpecialStatus;
   import actor.ActorGameObject;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import distributedObjects.HeroGameObject;
   import distributedObjects.HeroGameObjectOwner;
   import events.ActorLifetimeEvent;
   import facade.DBFacade;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class UIOffScreenPlayerManager
   {
      
      static inline final EFFECT_RECT_X_OFFSET:Float = 50;
      
      static inline final EFFECT_RECT_Y_OFFSET:Float = 100;
      
      static inline final EFFECT_RECT_WIDTH_OFFSET:Float = 60;
      
      static inline final EFFECT_RECT_HEIGHT_OFFSET:Float = 125;
      
      static inline final OFFSCREEN_UI_SCALE:Float = 1.44;
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      var mOffScreenPlayerMap:Map;
      
      var mSpecialActorsMap:Map;
      
      var mUIRoot:MovieClip;
      
      var mHeroOwner:HeroGameObjectOwner;
      
      var mEffectRect:Rectangle;
      
      var mPreviousFrameState:String;
      
      var mNametagSwfAsset:SwfAsset;
      
      var mUpdateTask:Task;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:HeroGameObjectOwner)
      {
         var effectRectWidth:Float;
         var effectRectHeight:Float;
         var facade= param1;
         var UIRoot= param2;
         var heroOwner= param3;
         
         mDBFacade = facade;
         mUIRoot = UIRoot;
         mHeroOwner = heroOwner;
         effectRectWidth = mDBFacade.viewWidth - 50 - 60;
         effectRectHeight = mDBFacade.viewHeight - 100 - 125;
         mEffectRect = new Rectangle(50,100,effectRectWidth,effectRectHeight);
         mOffScreenPlayerMap = new Map();
         mSpecialActorsMap = new Map();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),function(param1:SwfAsset)
         {
            mNametagSwfAsset = param1;
            mUpdateTask = mLogicalWorkComponent.doEveryFrame(update);
         });
         mEventComponent.addListener("ACTOR_CREATED",storeNewSpecialActor);
         mEventComponent.addListener("ACTOR_DESTROYED",removeSpecialActor);
      }
      
      public function destroy() 
      {
         if(mUpdateTask != null)
         {
            mUpdateTask.destroy();
         }
         mUpdateTask = null;
         var _loc1_= mOffScreenPlayerMap.keysToArray();
         var _loc2_:ASAny;
         if (checkNullIteratee(_loc1_)) for (_tmp_ in _loc1_)
         {
            _loc2_ = _tmp_;
            removeClip(ASCompat.toNumber(_loc2_));
         }
         mOffScreenPlayerMap.clear();
         mOffScreenPlayerMap = null;
         mSpecialActorsMap.clear();
         mSpecialActorsMap = null;
         mDBFacade = null;
         mUIRoot = null;
         mHeroOwner = null;
         mNametagSwfAsset = null;
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
      }
      
      function storeNewSpecialActor(param1:ActorLifetimeEvent) 
      {
         var _loc2_:ActorGameObject = null;
         if(mHeroOwner != null && mHeroOwner.distributedDungeonFloor != null)
         {
            _loc2_ = mHeroOwner.distributedDungeonFloor.getActor(param1.actorId);
            if(_loc2_ != null && _loc2_.actorData.gMActor.HasOffscreenIndicator)
            {
               mSpecialActorsMap.add(param1.actorId,_loc2_);
            }
         }
      }
      
      function removeSpecialActor(param1:ActorLifetimeEvent) 
      {
         mSpecialActorsMap.remove(param1.actorId);
      }
      
      public function update(param1:GameClock) 
      {
         var _loc6_:ASAny;
         var _loc4_:Map = null;
         var _loc5_:Array<ASAny> = null;
         var _loc2_:IMapIterator = null;
         var _loc7_:HeroGameObject = null;
         var _loc3_:ActorGameObject = null;
         if(mHeroOwner != null && mHeroOwner.distributedDungeonFloor != null)
         {
            _loc4_ = mHeroOwner.distributedDungeonFloor.remoteHeroes;
            _loc5_ = mOffScreenPlayerMap.keysToArray();
            if (checkNullIteratee(_loc5_)) for (_tmp_ in _loc5_)
            {
               _loc6_ = _tmp_;
               if(!_loc4_.hasKey(_loc6_) && !mSpecialActorsMap.hasKey(_loc6_))
               {
                  removeClip(ASCompat.toNumber(_loc6_));
               }
            }
            _loc2_ = ASCompat.reinterpretAs(_loc4_.iterator() , IMapIterator);
            while(_loc2_.hasNext())
            {
               _loc7_ = ASCompat.dynamicAs(_loc2_.next(), distributedObjects.HeroGameObject);
               updatePosition(_loc7_);
            }
            _loc2_ = ASCompat.reinterpretAs(mSpecialActorsMap.iterator() , IMapIterator);
            while(_loc2_.hasNext())
            {
               _loc3_ = ASCompat.dynamicAs(_loc2_.next(), actor.ActorGameObject);
               if(_loc3_ != null)
               {
                  updatePosition(_loc3_);
               }
            }
         }
      }
      
      function updatePosition(param1:ActorGameObject) 
      {
         var _loc5_:Dynamic = null;
         var _loc3_:MovieClip = null;
         var _loc12_= Math.NaN;
         var _loc6_:UIOffScreenClip = null;
         var _loc7_:UIOffScreenClip = null;
         var _loc14_= Math.NaN;
         if(param1 == null || param1.view == null)
         {
            return;
         }
         var _loc4_= mDBFacade.viewWidth / mDBFacade.camera.zoom;
         var _loc13_= mDBFacade.viewHeight / mDBFacade.camera.zoom;
         var _loc10_= mHeroOwner.view.position;
         var _loc11_= param1.view.worldCenter;
         var _loc2_= mDBFacade.camera.visibleRectangle;
         var _loc8_= new Vector3D(_loc10_.x - _loc11_.x,_loc10_.y - _loc11_.y,_loc10_.z - _loc11_.z);
         var _loc9_= new Vector3D(-1,0,0);
         if(!mOffScreenPlayerMap.hasKey(param1.id))
         {
            _loc5_ = mNametagSwfAsset.getClass("UI_widget");
            _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc5_, []), flash.display.MovieClip);
            _loc8_ = normalize(_loc8_);
            _loc12_ = Math.acos(_loc8_.dotProduct(_loc9_));
            _loc12_ = _loc12_ * 180 / 3.141592653589793;
            if(_loc11_.y > _loc10_.y)
            {
               ASCompat.setProperty((_loc3_ : ASAny).UI_arrow, "rotation", _loc12_ + 180);
            }
            else
            {
               ASCompat.setProperty((_loc3_ : ASAny).UI_arrow, "rotation", 180 - _loc12_);
            }
            _loc3_.x = calculateEffectXPosition(_loc12_);
            _loc3_.y = calculateEffectYPosition(_loc12_,_loc10_.y,_loc11_.y);
            mUIRoot.addChild(_loc3_);
            ASCompat.setProperty((_loc3_ : ASAny).NametagText, "text", param1.screenName);
            ASCompat.setProperty((_loc3_ : ASAny).NametagText, "textColor", PlayerSpecialStatus.getSpecialTextColor(param1.screenName,(ASCompat.toInt((_loc3_ : ASAny).NametagText.textColor) : UInt)));
            ASCompat.setProperty((_loc3_ : ASAny).AlertText, "text", "");
            _loc3_.scaleX = _loc3_.scaleY = 1.44;
            _loc3_.visible = false;
            _loc6_ = new UIOffScreenClip(mDBFacade,_loc3_,param1,mNametagSwfAsset);
            mOffScreenPlayerMap.add(param1.id,_loc6_);
            _loc6_.setHp(param1.hitPoints,(Std.int(param1.maxHitPoints) : UInt));
         }
         else
         {
            _loc7_ = ASCompat.dynamicAs(mOffScreenPlayerMap.itemFor(param1.id), uI.UIOffScreenClip);
            if(_loc7_ != null && _loc7_.clip != null)
            {
               if(!_loc2_.contains(_loc11_.x,_loc11_.y))
               {
                  if(_loc7_.clip.visible == false)
                  {
                     _loc7_.clip.visible = true;
                  }
                  _loc8_ = normalize(_loc8_);
                  _loc14_ = Math.acos(_loc8_.dotProduct(_loc9_));
                  _loc14_ = _loc14_ * 180 / 3.141592653589793;
                  if(_loc11_.y > _loc10_.y)
                  {
                     ASCompat.setProperty((_loc7_.clip : ASAny).UI_arrow, "rotation", _loc14_ + 180);
                  }
                  else
                  {
                     ASCompat.setProperty((_loc7_.clip : ASAny).UI_arrow, "rotation", 180 - _loc14_);
                  }
                  _loc7_.clip.x = calculateEffectXPosition(_loc14_);
                  _loc7_.clip.y = calculateEffectYPosition(_loc14_,_loc10_.y,_loc11_.y);
               }
               else if(_loc7_.clip.visible == true)
               {
                  _loc7_.clip.visible = false;
                  _loc7_.showFacebookPicture();
               }
            }
         }
      }
      
      function removeClip(param1:Float) 
      {
         var _loc2_= ASCompat.dynamicAs(mOffScreenPlayerMap.itemFor(param1), uI.UIOffScreenClip);
         if(_loc2_ != null)
         {
            if(mUIRoot.contains(_loc2_.clip))
            {
               mUIRoot.removeChild(_loc2_.clip);
            }
            _loc2_.destroy();
         }
         mOffScreenPlayerMap.removeKey(param1);
      }
      
      function calculateEffectXPosition(param1:Float) : Float
      {
         if(param1 <= 45)
         {
            return mEffectRect.right;
         }
         if(param1 >= 135)
         {
            return mEffectRect.left;
         }
         return mEffectRect.right - mEffectRect.width / 90 * (param1 - 45);
      }
      
      function calculateEffectYPosition(param1:Float, param2:Float, param3:Float) : Float
      {
         if(param3 > param2)
         {
            if(param1 > 45 && param1 < 135)
            {
               return mEffectRect.bottom;
            }
            if(param1 <= 45)
            {
               return mEffectRect.top + mEffectRect.height / 2 + mEffectRect.height / 90 * param1;
            }
            return mEffectRect.bottom - mEffectRect.height / 90 * (param1 - 135);
         }
         if(param1 > 45 && param1 < 135)
         {
            return mEffectRect.top;
         }
         if(param1 <= 45)
         {
            return mEffectRect.top + mEffectRect.height / 2 - mEffectRect.height / 90 * param1;
         }
         return mEffectRect.top + mEffectRect.height / 90 * (param1 - 135);
      }
      
      function normalize(param1:Vector3D) : Vector3D
      {
         var _loc2_= param1.length;
         param1.x /= _loc2_;
         param1.y /= _loc2_;
         param1.z /= _loc2_;
         return param1;
      }
      
      public function handlePicChange(param1:Int, param2:String) 
      {
         var _loc3_:UIOffScreenClip = null;
         if(mOffScreenPlayerMap.hasKey(param1))
         {
            _loc3_ = ASCompat.dynamicAs(mOffScreenPlayerMap.itemFor(param1), uI.UIOffScreenClip);
            if(_loc3_ == null)
            {
               return;
            }
            _loc3_.handlePicChange(param2);
         }
      }
   }


