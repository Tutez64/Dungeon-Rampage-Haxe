package town
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import flash.display.MovieClip;
   
    class AdManager
   {
      
      static inline final MIN_AD_AVATAR_LEVEL_DFLT= 0;
      
      static inline final TOWN_AD_X= 612;
      
      static inline final TOWN_AD_Y= 276;
      
      var mSMTownAd:SMTownAd;
      
      var mWTTownAd:WTTownAd;
      
      var mDBFacade:DBFacade;
      
      var mTownStateMachine:TownStateMachine;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mTownClip:MovieClip;
      
      var mAdButtonClip:MovieClip;
      
      var mAdButton:UIButton;
      
      var mShowingAdButton:Bool = false;
      
      static inline final RESPONSE_PENDING= -1;
      
      static inline final RESPONSE_NO_ADS= 0;
      
      static inline final RESPONSE_HAS_ADS= 1;
      
      var mProviderResponses:Vector<Int>;
      
      var mAdProviders:Vector<ITownAdProvider>;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:TownStateMachine)
      {
         
         mDBFacade = param1;
         mTownClip = param2;
         mTownStateMachine = param3;
         initialize();
      }
      
      function initialize() 
      {
         var _loc1_= 0;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mAdProviders = new Vector<ITownAdProvider>();
         mProviderResponses = new Vector<Int>();
         _loc1_ = 0;
         while(_loc1_ < mAdProviders.length)
         {
            mProviderResponses.push(-1);
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      public function destroy() 
      {
         Logger.debug("AdManager: destroy called");
         if(mSMTownAd != null)
         {
            mSMTownAd.destroy();
            mSMTownAd = null;
         }
         if(mWTTownAd != null)
         {
            mWTTownAd.destroy();
            mWTTownAd = null;
         }
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         clearProviderResponses();
         removeAdButton();
      }
      
      public function resetWT() 
      {
         Logger.debug("AdManager: resetWT called");
         if(mWTTownAd != null)
         {
            mWTTownAd.removeWildTangentAPI();
         }
      }
      
      public function assignTownClip(param1:MovieClip) 
      {
         Logger.debug("AdManager: assignTownClip called");
         mTownClip = param1;
         if(mWTTownAd != null)
         {
            mWTTownAd.assignTownClip(mTownClip);
         }
      }
      
      public function clearProviderResponses() 
      {
         var _loc1_= 0;
         Logger.debug("AdManager: clearProviderResponses called");
         _loc1_ = 0;
         while(_loc1_ < mAdProviders.length)
         {
            mProviderResponses[_loc1_] = -1;
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      public function removeAdButton() 
      {
         Logger.debug("AdManager: removeAdButton called");
         if(mAdButtonClip != null)
         {
            mTownClip.removeChild(mAdButtonClip);
            mAdButtonClip = null;
         }
         if(mAdButton != null)
         {
            mAdButton.destroy();
            mAdButton = null;
         }
      }
      
      function reset(param1:UInt) 
      {
         Logger.debug("AdManager: reset called");
         if(param1 < (mProviderResponses.length : UInt))
         {
            mProviderResponses[(param1 : Int)] = -1;
         }
         if(ShouldShowAdButton())
         {
            InitializeAds();
         }
      }
      
      public function InitializeAds() 
      {
         var _loc1_= 0;
         Logger.debug("AdManager: removeAdButton called");
         _loc1_ = 0;
         while(_loc1_ < mAdProviders.length)
         {
            mAdProviders[_loc1_].CheckForAds(receivedAdResponse((_loc1_ : UInt)));
            mAdProviders[_loc1_].SetResetCallback(reset);
            _loc1_++;
         }
      }
      
      public function ShouldShowAdButton() : Bool
      {
         var _loc1_= Std.int(mDBFacade.dbConfigManager.getConfigNumber("min_avlevel_for_ad",0));
         Logger.debug("minAvLevForAd= " + _loc1_);
         return _loc1_ >= 0 && !mDBFacade.isKongregatePlayer && mDBFacade.dbAccountInfo.inventoryInfo.highestAvatarLevel >= (_loc1_ : UInt);
      }
      
      public function TryDisplayAdButton() 
      {
         var _loc2_= 0;
         var _loc1_= new Vector<Int>();
         _loc2_ = 0;
         while(_loc2_ < mProviderResponses.length)
         {
            if(mProviderResponses[_loc2_] == 1)
            {
               Logger.debug("TryDisplayAdButton: " + Std.string(_loc2_) + " has ads");
               _loc1_.push(_loc2_);
            }
            _loc2_++;
         }
         var _loc3_= (0 : UInt);
         if(_loc1_.length > 0)
         {
            _loc3_ = (Math.floor(Math.random() * _loc1_.length) : UInt);
            Logger.debug("TryDisplayAdButton: random Provider " + Std.string(_loc3_) + ";Ad Provider picked: " + _loc1_[(_loc3_ : Int)]);
            ShowAdButton((_loc1_[(_loc3_ : Int)] : UInt));
         }
      }
      
      function receivedAdResponse(param1:UInt) : ASFunction
      {
         var adProvider= param1;
         return function(param1:Bool)
         {
            mProviderResponses[(adProvider : Int)] = param1 ? 1 : 0;
            TryDisplayAdButton();
         };
      }
      
      function ShowAdButton(param1:UInt) 
      {
         var adProvider= param1;
         if(mAdButton != null)
         {
            removeAdButton();
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass("UI_icon_wild_tangent");
            mAdButtonClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
            mAdButtonClip.x = 612;
            mAdButtonClip.y = 276;
            mTownClip.addChild(mAdButtonClip);
            mAdButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mAdButtonClip : ASAny).button, flash.display.MovieClip));
            mAdButton.releaseCallback = mAdProviders[(adProvider : Int)].ShowAdPlayer;
            mAdProviders[(adProvider : Int)].ShowingAdButton();
         });
      }
   }


