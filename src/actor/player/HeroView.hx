package actor.player
;
   import actor.ActorView;
   import distributedObjects.HeroGameObject;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class HeroView extends ActorView
   {
      
      var mHeroPlayerObject:HeroGameObject;
      
      public function new(param1:DBFacade, param2:HeroGameObject)
      {
         mHeroPlayerObject = param2;
         super(param1,param2);
         mWantNametag = true;
      }
      
      override public function destroy() 
      {
         mHeroPlayerObject = null;
         super.destroy();
      }
      
      public function playHeroLevelUpEffects() 
      {
         mHeroPlayerObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),"db_fx_levelup",new Vector3D(),mHeroPlayerObject);
         mHeroPlayerObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),"db_fx_levelup_background",new Vector3D(),mHeroPlayerObject,true,1,0,0,0,0,false,"background");
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"LevelUp2",function(param1:brain.sound.SoundAsset)
         {
            mSoundComponent.playSfxOneShot(param1,null);
         });
      }
   }


