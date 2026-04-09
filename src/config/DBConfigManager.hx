package config
;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.utils.ConfigManager;
   import facade.DBFacade;
   
    class DBConfigManager extends ConfigManager
   {
      
      var mFilePathsToOpen:Array<ASAny> = ["./DbConfiguration/Config.json"];
      
      var mConfigsToLoad:Array<ASAny>;
      
      var mEventComponent:EventComponent;
      
      var mDBFacade:DBFacade;
      
      public function new(param1:DBFacade)
      {
         mDBFacade = param1;
         mEventComponent = new EventComponent(mDBFacade);
         mConfigsToLoad = mDBFacade.mAdditionalConfigFilesToLoad.concat(mFilePathsToOpen);
         super(param1,mConfigsToLoad,null,handleFailure);
      }
      
      override function finishedLoadingFiles() 
      {
         super.finishedLoadingFiles();
         Logger.info("Build Version development");
         mEventComponent.dispatchEvent(new ConfigFileLoadedEvent(this));
      }
      
      function handleFailure() 
      {
         Logger.fatal("Failed to load config files: " + mConfigsToLoad);
      }
   }


