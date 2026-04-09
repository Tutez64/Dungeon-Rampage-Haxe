package town
;
   import brain.logger.Logger;
   import facade.DBFacade;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
    class SMTownAd implements ITownAdProvider
   {
      
      static inline final TOWN_AD_X= 612;
      
      static inline final TOWN_AD_Y= 276;
      
      var mDBFacade:DBFacade;
      
      var mAdsAvailable:Bool = false;
      
      var mResponseCallback:ASFunction = null;
      
      var mResetCallback:ASFunction = null;
      
      var mInitialized:Bool = false;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
      }
      
      public function destroy() 
      {
         mInitialized = false;
         mResponseCallback = null;
         mResetCallback = null;
      }
      
      public function CheckForAds(param1:ASFunction) 
      {
         var accountId:String;
         var query:String;
         var request:URLRequest;
         var urlLoader:URLLoader;
         var callback= param1;
         if(!mDBFacade.isKongregatePlayer)
         {
            mResponseCallback = callback;
            accountId = Std.string(mDBFacade.accountId);
            Logger.debug("SM ad query for account : " + accountId);
            query = "https://ads.sele.co/v2/videos_for/" + accountId + "/on/DungeonRampage_5205_5077.xml";
            request = new URLRequest(query);
            urlLoader = new URLLoader(request);
            urlLoader.addEventListener("ioError",function(param1:Event)
            {
               Logger.warn("IOError on scores logging: " + param1.toString());
            });
            urlLoader.addEventListener("securityError",function(param1:Event)
            {
               Logger.warn("SecurityError on scores logging: " + param1.toString());
            });
            urlLoader.addEventListener("complete",SelectableMediaResponse);
            urlLoader.load(request);
         }
         else
         {
            callback(false);
         }
      }
      
      function SelectableMediaResponse(param1:Event) 
      {
         var _loc2_= new compat.XML(param1.target.data);
         mAdsAvailable = false;
         if(_loc2_.hasOwnProperty("available"))
         {
            Logger.debug("SM json available: " + _loc2_.child("available").toString());
            mAdsAvailable = _loc2_.child("available").toString() == "true";
            Logger.warn("SM ad available: " + Std.string(mAdsAvailable));
         }
         else
         {
            Logger.warn("Unexpected format in SM Response. Response: " + _loc2_.toXMLString());
         }
         if(mResponseCallback != null)
         {
            mResponseCallback(mAdsAvailable);
         }
      }
      
      public function SetResetCallback(param1:ASFunction) 
      {
         mResetCallback = param1;
      }
      
      public function ShowingAdButton() 
      {
         mDBFacade.metrics.log("SMTownButton");
         Logger.debug("SM Ad set up");
      }
      
      public function ShowAdPlayer() 
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(mAdsAvailable && ExternalInterface.available)
         {
            _loc1_ = Std.string(mDBFacade.accountId);
            _loc2_ = mDBFacade.facebookAccountInfo != null ? mDBFacade.facebookAccountInfo.gender : "";
            Logger.warn("Showing SM ads");
            if(!mInitialized)
            {
               ExternalInterface.addCallback("SMInitialized",InitializedCallback);
               ExternalInterface.addCallback("SMOpenedPlayer",OpenedPlayerCallback);
               ExternalInterface.addCallback("SMClosedPlayer",ClosedPlayerCallback);
               ExternalInterface.addCallback("SMAdCompleted",AdCompletedCallback);
               mInitialized = true;
            }
            ExternalInterface.call("DoSelectableMedia",_loc1_,_loc2_);
         }
         else
         {
            Logger.warn("Attempted to show SM ads when none were available");
         }
      }
      
      function InitializedCallback() 
      {
         Logger.debug("SM: InitializedCallback");
      }
      
      function OpenedPlayerCallback() 
      {
         Logger.debug("SM: OpenedPlayerCallback");
         mDBFacade.metrics.log("SMOpenedPlayer");
      }
      
      function ClosedPlayerCallback() 
      {
         Logger.debug("SM: ClosedPlayerCallback");
         mDBFacade.metrics.log("SMClosedPlayer");
         mResetCallback(1);
      }
      
      function AdCompletedCallback() 
      {
         Logger.debug("SM: AdCompletedCallback");
         mDBFacade.metrics.log("SMAdCompleted");
         mDBFacade.dbAccountInfo.getUsersFullAccountInfo();
      }
   }


