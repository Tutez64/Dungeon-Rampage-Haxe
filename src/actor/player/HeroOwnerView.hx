package actor.player
;
   import actor.DamageFloater;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.sound.SoundAsset;
   import brain.sound.SoundHandle;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import distributedObjects.HeroGameObject;
   import dungeon.Tile;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import org.as3commons.collections.framework.IIterator;
   
    class HeroOwnerView extends HeroView
   {
      
      public static var HIT_AREA_HALF_WIDTH:Float = 15;
      
      public static var HIT_AREA_HALF_HEIGHT:Float = 25;
      
      public static var HIT_AREA_Y_OFFSET:Float = 10;
      
      public static var ACTIVATE_HEARTBEAT_AT_HEALTH_LEVEL:Float = 0.25;
      
      public var wantMouseEnabled:Bool = false;
      
      var mWorkComponent:LogicalWorkComponent;
      
      var mVisibilityTask:Task;
      
      var mNotEnoughManaSoundEffect:SoundAsset;
      
      var mFootRing:MovieClip;
      
      var mHeartbeatSoundEffect:SoundAsset;
      
      var mHeartbeatSoundHandle:SoundHandle;
      
      public function new(param1:DBFacade, param2:HeroGameObject)
      {
         super(param1,param2);
      }
      
      function fadeOccludingObjects(param1:GameClock) 
      {
         var _loc9_:FloorObject = null;
         var _loc6_:Point = null;
         var _loc10_:ASAny = null;
         var _loc7_:ASAny = null;
         var _loc3_:IIterator = null;
         var _loc5_:Tile = null;
         if(mHeroPlayerObject.tile == null)
         {
            Logger.warn("mHeroPlayerObject.tile is null.");
            return;
         }
         var _loc4_= new Point();
         var _loc8_:Float = 4;
         var _loc2_= mHeroPlayerObject.distributedDungeonFloor.GetTilesAroundAvatar(_loc8_);
         if (checkNullIteratee(_loc2_)) for (_tmp_ in _loc2_)
         {
            _loc5_  = _tmp_;
            _loc3_ = ASCompat.dynamicAs(_loc5_.floorObjects.iterator(), org.as3commons.collections.framework.IIterator);
            while(_loc3_.hasNext())
            {
               _loc9_ = ASCompat.dynamicAs(_loc3_.next(), dr_floor.FloorObject);
               if(_loc9_.archwayAlpha && _loc9_.view.root.hitTestObject(mBody))
               {
                  _loc4_.x = mBody.x;
                  _loc4_.y = mBody.y;
                  _loc6_ = mBody.localToGlobal(_loc4_);
                  if(_loc9_.view.root.hitTestPoint(_loc6_.x,_loc6_.y,false))
                  {
                     _loc9_.view.doFade();
                  }
               }
            }
         }
      }
      
      override public function init() 
      {
         var hitSprite:Sprite;
         super.init();
         this.nametag.hpBarVisible = false;
         mWorkComponent = new LogicalWorkComponent(mDBFacade);
         mVisibilityTask = mWorkComponent.doEveryFrame(fadeOccludingObjects);
         if(!wantMouseEnabled)
         {
            root.mouseEnabled = false;
            root.mouseChildren = false;
         }
         else
         {
            hitSprite = new Sprite();
            hitSprite.mouseEnabled = false;
            hitSprite.graphics.beginFill((0 : UInt),0);
            hitSprite.graphics.drawRect(-HIT_AREA_HALF_WIDTH,-HIT_AREA_HALF_HEIGHT + actor.ActorView.BODY_Y_OFFSET + HIT_AREA_Y_OFFSET,HIT_AREA_HALF_WIDTH * 2,HIT_AREA_HALF_HEIGHT * 2);
            hitSprite.graphics.endFill();
            root.mouseChildren = false;
            root.mouseEnabled = true;
            root.hitArea = hitSprite;
            root.addChild(root.hitArea);
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass("db_fx_player_ring");
            if(_loc2_ != null)
            {
               mFootRing = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
               mFootRing.scaleX = mFootRing.scaleY = 0.75;
               mBody.addChildAt(mFootRing,0);
            }
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"TEMP_Heartbeat1",function(param1:SoundAsset)
         {
            mHeartbeatSoundEffect = param1;
         });
      }
      
      override public function setHp(param1:UInt, param2:UInt) 
      {
         super.setHp(param1,param2);
         if(param1 <= param2 * ACTIVATE_HEARTBEAT_AT_HEALTH_LEVEL)
         {
            if(mHeartbeatSoundHandle != null)
            {
               return;
            }
            if(mHeartbeatSoundEffect != null)
            {
               mHeartbeatSoundHandle = mSoundComponent.playSfxManaged(mHeartbeatSoundEffect);
               mHeartbeatSoundHandle.play(2147483647);
            }
         }
         else
         {
            stopHeartbeatSound();
         }
      }
      
      public function stopHeartbeatSound() 
      {
         if(mHeartbeatSoundHandle == null)
         {
            return;
         }
         mHeartbeatSoundHandle.stop();
         mHeartbeatSoundHandle.destroy();
         mHeartbeatSoundHandle = null;
      }
      
      override public function  set_position(param1:Vector3D) :Vector3D      {
         mRoot.x = param1.x;
         mRoot.y = param1.y;
return param1;
      }
      
      @:isVar public var outOfManaSoundEffect(get,never):SoundAsset;
public function  get_outOfManaSoundEffect() : SoundAsset
      {
         return mNotEnoughManaSoundEffect;
      }
      
      override public function spawnDamageFloater(param1:Bool, param2:Int, param3:Bool, param4:Bool, param5:Int, param6:UInt = (0 : UInt), param7:String = "DAMAGE_MOVEMENT_TYPE") 
      {
         var _loc8_:DamageFloater = null;
         if(mDBFacade.featureFlags.getFlagValue("want-damage-floaters"))
         {
            _loc8_ = new DamageFloater(mDBFacade,param2,mParentActorObject,(0 : UInt),(24 : UInt),1.2,90,null,param3,param4,true,param1,param5,param6,param7);
         }
      }
      
      override public function destroy() 
      {
         mNotEnoughManaSoundEffect = null;
         mVisibilityTask.destroy();
         if(mHeartbeatSoundEffect != null)
         {
            mHeartbeatSoundEffect = null;
         }
         if(mHeartbeatSoundHandle != null)
         {
            mHeartbeatSoundHandle.destroy();
            mHeartbeatSoundHandle = null;
         }
         super.destroy();
      }
   }


