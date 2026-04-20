package effects
;
   import actor.ActorGameObject;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.sceneGraph.SceneGraphManager;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import facade.DBFacade;
   import dr_floor.FloorObject;
   import sound.DBSoundComponent;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class EffectManager
   {
      
      static inline final OUT_OF_MANA_DISPLAY_TIME:Float = 2;
      
      var mDBFacade:DBFacade;
      
      var mManagedEffects:Map;
      
      var mSoundComponent:DBSoundComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mNotEnoughManaDisplayTask:Task;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
         mManagedEffects = new Map();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"EffectManager");
         mSoundComponent = new DBSoundComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"EffectManager");
      }
      
      public function playLerpedEffect(param1:String, param2:String, param3:Vector3D, param4:FloorObject = null, param5:ActorGameObject = null, param6:Float = 1, param7:UInt = (13369344 : UInt), param8:Bool = false, param9:Float = 1, param10:Float = 0, param11:Float = 0, param12:Float = 0, param13:Float = 0, param14:Bool = false, param15:String = "sorted", param16:Bool = false, param17:Float = 1, param18:ASFunction = null) 
      {
         var _loc19_= new LerpEffectGameObject(mDBFacade,param1,param2,param17,(0 : UInt),param18,param5,param6,param7);
         MemoryTracker.track(_loc19_,"LerpEffectGameObject \'" + param1 + ":" + param2 + "\' - created in EffectManager.playLerpedEffect()","pool");
         _loc19_.view.root.scaleX = _loc19_.view.root.scaleY = param9;
         _loc19_.position = param4.position.add(param3);
         _loc19_.layer = SceneGraphManager.getLayerFromName(param15);
         _loc19_.view.addToStage();
      }
      
      public function playEffect(param1:String, param2:String, param3:Vector3D, param4:FloorObject = null, param5:Bool = false, param6:Float = 1, param7:Float = 0, param8:Float = 0, param9:Float = 0, param10:Float = 0, param11:Bool = false, param12:String = "sorted", param13:Bool = false, param14:Float = 1, param15:ASFunction = null) : UInt
      {
         var effectGameObject:EffectGameObject;
         var pool:EffectPool;
         var swfPath= param1;
         var className= param2;
         var position= param3;
         var parentObject= param4;
         var behindAvatar= param5;
         var scale= param6;
         var rotation= param7;
         var rotationX= param8;
         var rotationY= param9;
         var rotationZ= param10;
         var loop= param11;
         var layerName= param12;
         var isManaged= param13;
         var playRate= param14;
         var assetLoadedCallback= param15;
         if(isManaged)
         {
            effectGameObject = new EffectGameObject(mDBFacade,swfPath,className,playRate,(0 : UInt),assetLoadedCallback);
            MemoryTracker.track(effectGameObject,"EffectGameObject \'" + swfPath + ":" + className + "\' - created in EffectManager.playEffect()","pool");
         }
         else
         {
            effectGameObject = ASCompat.reinterpretAs(mDBFacade.effectPool.checkout(mDBFacade,swfPath,className,assetLoadedCallback) , EffectGameObject);
         }
         effectGameObject.view.root.scaleX = effectGameObject.view.root.scaleY = scale;
         effectGameObject.rotation = rotation;
         effectGameObject.position = position;
         if(parentObject != null)
         {
            if(behindAvatar)
            {
               parentObject.view.root.addChildAt(effectGameObject.view.root,0);
            }
            else
            {
               parentObject.view.root.addChild(effectGameObject.view.root);
            }
         }
         else
         {
            effectGameObject.layer = SceneGraphManager.getLayerFromName(layerName);
            effectGameObject.view.addToStage();
         }
         pool = mDBFacade.effectPool;
         cast(effectGameObject.view, EffectView).play(loop,function()
         {
            if(!isManaged)
            {
               pool.checkin(effectGameObject);
            }
         });
         if(isManaged)
         {
            mManagedEffects.add(effectGameObject.id,effectGameObject);
         }
         return effectGameObject.id;
      }
      
      public function playSoundEffect(param1:String, param2:String) 
      {
         var soundSwfPath= param1;
         var soundName= param2;
         mAssetLoadingComponent.getSoundAsset(soundSwfPath,soundName,function(param1:brain.sound.SoundAsset)
         {
            mSoundComponent.playSfxOneShot(param1,null);
         });
      }
      
      public function endManagedEffect(param1:UInt) 
      {
         var _loc2_= ASCompat.dynamicAs(mManagedEffects.itemFor(param1), effects.EffectGameObject);
         if(_loc2_ != null)
         {
            mManagedEffects.remove(_loc2_);
            _loc2_.destroy();
         }
      }
      
      public function playNotEnoughManaEffects() 
      {
         if(mNotEnoughManaDisplayTask == null)
         {
            playSoundEffect(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"OutOfMana");
            mDBFacade.hud.showNotEnoughMana();
            mNotEnoughManaDisplayTask = mLogicalWorkComponent.doLater(2,function(param1:brain.clock.GameClock)
            {
               mNotEnoughManaDisplayTask = null;
               mDBFacade.hud.hideNotEnoughMana();
            });
         }
      }
      
      public function destroy() 
      {
         var _loc2_:IMapIterator = null;
         var _loc1_:EffectGameObject = null;
         mDBFacade = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mSoundComponent.destroy();
         mSoundComponent = null;
         if(mManagedEffects != null)
         {
            _loc2_ = ASCompat.reinterpretAs(mManagedEffects.iterator() , IMapIterator);
            while(_loc2_.hasNext())
            {
               _loc1_ = ASCompat.dynamicAs(_loc2_.next(), effects.EffectGameObject);
               _loc1_.destroy();
            }
            mManagedEffects.clear();
            mManagedEffects = null;
         }
         if(mNotEnoughManaDisplayTask != null)
         {
            mNotEnoughManaDisplayTask.destroy();
            mNotEnoughManaDisplayTask = null;
         }
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
      }
   }


