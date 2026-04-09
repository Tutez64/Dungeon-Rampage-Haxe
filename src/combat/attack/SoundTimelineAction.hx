package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.logger.Logger;
   import facade.DBFacade;
   import sound.DBSoundComponent;
   
    class SoundTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "sound";
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSoundComponent:DBSoundComponent;
      
      var mSwfPath:String;
      
      var mSoundName:String;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:String, param5:String)
      {
         super(param1,param2,param3);
         mSwfPath = param4;
         mSoundName = param5;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSoundComponent = new DBSoundComponent(mDBFacade);
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : SoundTimelineAction
      {
         return new SoundTimelineAction(param1,param2,param3,param4.path,param4.name);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         var timeline= param1;
         super.execute(timeline);
         if(ASCompat.stringAsBool(mSwfPath) && ASCompat.stringAsBool(mSoundName))
         {
            mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(mSwfPath),mSoundName,function(param1:brain.sound.SoundAsset)
            {
               mSoundComponent.playSfxOneShot(param1,mActorView.worldCenter);
            });
         }
         else
         {
            Logger.error("SoundTimelineAction: invalid sound: swfPath: " + mSwfPath + " soundName: " + mSoundName);
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


