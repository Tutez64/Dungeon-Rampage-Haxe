package sound
;
   import brain.sound.SoundAsset;
   import brain.sound.SoundComponent;
   import brain.sound.SoundHandle;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   import flash.media.Sound;
   
    class DBSoundComponent extends SoundComponent
   {
      
      var MIN_DISTANCE_FOR_SOUND:Float = 690;
      
      var mDBFacade:DBFacade;
      
      var mDBSoundManager:DBSoundManager;
      
      public function new(param1:DBFacade)
      {
         super(param1);
         mDBFacade = param1;
         mDBSoundManager = ASCompat.reinterpretAs(mDBFacade.soundManager , DBSoundManager);
         MIN_DISTANCE_FOR_SOUND = mDBFacade.dbConfigManager.getConfigNumber("min_sound_distance",690);
      }
      
      override public function destroy() 
      {
         super.destroy();
         mDBFacade = null;
         mDBSoundManager = null;
      }
      
      public function playSfxOneShot(param1:SoundAsset, param2:Vector3D = null, param3:Int = 0, param4:Float = 1, param5:Float = 0, param6:Float = 0) 
      {
         var _loc7_= new Vector3D();
         _loc7_.x = -mDBFacade.camera.rootPosition.x;
         _loc7_.y = -mDBFacade.camera.rootPosition.y;
         if(param2 != null && Vector3D.distance(param2,_loc7_) > MIN_DISTANCE_FOR_SOUND)
         {
            return;
         }
         this.playOneShot(param1,"sfx",param3,param4,param5,param6);
      }
      
      public function playSfxManaged(param1:SoundAsset, param2:Float = 1, param3:Float = 0) : SoundHandle
      {
         return this.playManagedSound(param1,"sfx",param2,param3);
      }
      
      public function playMusic(param1:SoundAsset, param2:Float = 1, param3:Float = 0, param4:Float = 0) : SoundHandle
      {
         return playStreamingMusic(param1.sound,param2,param3,param4);
      }
      
      public function playStreamingMusic(param1:Sound, param2:Float = 1, param3:Float = 0, param4:Float = 0) : SoundHandle
      {
         var _loc5_= new SoundHandle(mDBSoundManager,mDBFacade,param1,"music",unregisterSoundHandle,true,param2,param3);
         mSoundHandles.add(_loc5_);
         _loc5_.play(2147483647);
         return _loc5_;
      }
   }


