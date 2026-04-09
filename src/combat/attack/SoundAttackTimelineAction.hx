package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.assetRepository.AssetLoadingComponent;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import sound.DBSoundComponent;
   
    class SoundAttackTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "attackSound";
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSoundComponent:DBSoundComponent;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade)
      {
         super(param1,param2,param3);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSoundComponent = new DBSoundComponent(mDBFacade);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : SoundAttackTimelineAction
      {
         return new SoundAttackTimelineAction(param1,param2,param3);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         var gmAttack:GMAttack;
         var timeline= param1;
         super.execute(timeline);
         gmAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(mAttackType), gameMasterDictionary.GMAttack);
         if(gmAttack != null && ASCompat.stringAsBool(gmAttack.AttackSound))
         {
            mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),gmAttack.AttackSound,function(param1:brain.sound.SoundAsset)
            {
               mSoundComponent.playSfxOneShot(param1,mActorView.worldCenter,0,gmAttack.AttackVolume);
            });
         }
      }
      
      override public function destroy() 
      {
         mSoundComponent.destroy();
         mSoundComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         super.destroy();
      }
   }


