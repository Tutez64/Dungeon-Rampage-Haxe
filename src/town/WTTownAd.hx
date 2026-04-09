package town
;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.jsonRPC.JSONRPCService;
   import facade.DBFacade;
   import com.wildtangent.WildTangentAPI;
   import flash.display.MovieClip;
   
    class WTTownAd implements ITownAdProvider
   {
      
      static inline final TOWN_AD_X= 612;
      
      static inline final TOWN_AD_Y= 276;
      
      static inline final MIN_AD_AVATAR_LEVEL_DFLT= -1;
      
      static inline final WT_RESHOW_TIMER= 300000;
      
      static inline final WT_PARTNER= "rebelentertainment";
      
      static inline final WT_SITE= "dungeonrampage_v1";
      
      static inline final WT_GAME= "dungeonrampage";
      
      static var lastRedeemTime:Float = 0;
      
      var mWildTangentAPI:WildTangentAPI = null;
      
      var mDBFacade:DBFacade;
      
      var mTownClip:MovieClip;
      
      var mTownStateMachine:TownStateMachine;
      
      var wtResponseObject:ASObject = {};
      
      var wtRedeemObject:ASObject = {};
      
      var wtPromoBase:String = "promoId";
      
      var wtLastPromoCtr:Int = 0;
      
      var wtPromoCtr:Int = 1;
      
      var mResponseCallback:ASFunction = null;
      
      var mResetCallback:ASFunction = null;
      
      var mInitialized:Bool = false;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:TownStateMachine)
      {
         
         mDBFacade = param1;
         mTownStateMachine = param3;
         Logger.debug("Initializing WT API");
         mWildTangentAPI = new WildTangentAPI();
         mWildTangentAPI.gameName = "dungeonrampage";
         mWildTangentAPI.partnerName = "rebelentertainment";
         mWildTangentAPI.siteName = "dungeonrampage_v1";
         mWildTangentAPI.userId = Std.string(mDBFacade.dbAccountInfo.id);
         mWildTangentAPI.BrandBoost.closed = closedWT;
         mWildTangentAPI.BrandBoost.handlePromo = WildTangentResponse;
         mWildTangentAPI.Vex.redeemCode = redeemCodeWT;
         assignTownClip(param2);
         addWildTangentAPI();
         mInitialized = true;
      }
      
      public function destroy() 
      {
         Logger.debug("Destroying WT API");
         mInitialized = false;
         if(mWildTangentAPI != null)
         {
            mTownClip.removeChild(mWildTangentAPI);
         }
         mWildTangentAPI = null;
         mResponseCallback = null;
         mResetCallback = null;
      }
      
      public function assignTownClip(param1:MovieClip) 
      {
         Logger.debug("AssignTownClip WT API");
         mTownClip = param1;
      }
      
      public function addWildTangentAPI() 
      {
         Logger.debug("addWildTangentAPI WT API");
         mTownClip.addChildAt(mWildTangentAPI,0);
      }
      
      public function removeWildTangentAPI() 
      {
         Logger.debug("removeWildTangentAPI WT API");
         if(mWildTangentAPI != null)
         {
            mTownClip.removeChild(mWildTangentAPI);
         }
      }
      
      public function CheckForAds(param1:ASFunction) 
      {
         var _loc2_= true;
         if(wtLastPromoCtr == wtPromoCtr)
         {
            Logger.debug("WT CheckForAds already has a promo pending; return");
            return;
         }
         if(lastRedeemTime + 300000 > GameClock.getWebServerDate().getTime())
         {
            Logger.debug("WT CheckForAds returning to wait for a new promo");
            param1(false);
            mResponseCallback = null;
            return;
         }
         mResponseCallback = param1;
         wtLastPromoCtr = wtPromoCtr;
         var _loc3_= wtPromoBase + Std.string(wtPromoCtr);
         Logger.debug("WT Checking for promo " + _loc3_);
         mWildTangentAPI.BrandBoost.getPromo({"promoName":_loc3_});
      }
      
      public function WildTangentResponse(param1:ASObject) 
      {
         Logger.debug("WT Promo Available = " + Std.string(param1.available));
         if(param1 == wtResponseObject)
         {
            Logger.debug("WT Promo called with same obj as last");
         }
         if(mResponseCallback != null)
         {
            Logger.debug("WT Promo Response Callback");
            mResponseCallback(param1.available);
         }
         if(ASCompat.toBool(param1.available))
         {
            wtResponseObject = param1;
            removeWildTangentAPI();
         }
      }
      
      public function SetResetCallback(param1:ASFunction) 
      {
         mResetCallback = param1;
      }
      
      public function ShowingAdButton() 
      {
         mDBFacade.metrics.log("WtTownButton");
         Logger.debug("WT Ad set up");
      }
      
      public function ShowAdPlayer() 
      {
         if(wtResponseObject == null)
         {
            Logger.info("wtResponseObject is null");
            return;
         }
         Logger.debug("Launching WT Ad: " + Std.string(wtResponseObject.available) + "," + Std.string(wtResponseObject.itemKey) + "," + Std.string(wtResponseObject.promoName));
         mDBFacade.metrics.log("WtBrandBoostLaunch");
         mWildTangentAPI.BrandBoost.launch(wtResponseObject);
      }
      
      public function closedWT(param1:ASObject) 
      {
         Logger.debug("Closed WT Ad with reason=" + Std.string(param1.reason));
         switch(param1.reason)
         {
            case "redeemed":
               adRedeemedWT();
               mDBFacade.metrics.log("WtBrandBoostRedeem");
               
            case "abandon":
               mDBFacade.metrics.log("WtBrandBoostAbandon");
               
            case "buy_item":
               adBuyItemWT();
               mDBFacade.metrics.log("WtBrandBoostToShop");
         }
      }
      
      public function adBuyItemWT() 
      {
         Logger.debug("WT causing enter shop state");
         mDBFacade.dbAccountInfo.getUsersFullAccountInfo();
         mTownStateMachine.enterShopState();
      }
      
      public function adRedeemedWT() 
      {
         Logger.debug("WT causing ad UI invisible");
         mDBFacade.dbAccountInfo.getUsersFullAccountInfo();
      }
      
      public function redeemCodeWT(param1:ASObject) 
      {
         lastRedeemTime = GameClock.getWebServerDate().getTime();
         Logger.debug("Calling WT redeem RPC");
         wtRedeemObject = param1;
         var _loc2_= JSONRPCService.getFunction("CodeRedemption",mDBFacade.rpcRoot + "wildtangent");
         _loc2_(mDBFacade.dbAccountInfo.id,mDBFacade.dbAccountInfo.activeAvatarId,param1.vexCode,mDBFacade.validationToken,mDBFacade.demographics,redeemSuccessWT,redeemErrorWT);
      }
      
      public function redeemSuccessWT(param1:ASAny) 
      {
         Logger.debug("WT redeem success");
         mWildTangentAPI.Vex.redemptionComplete(wtRedeemObject);
         wtPromoCtr += 1;
         mResetCallback(0);
      }
      
      public function redeemErrorWT(param1:Error) 
      {
         Logger.debug("WT redeem error");
         mWildTangentAPI.Vex.redemptionComplete(wtRedeemObject);
         wtPromoCtr += 1;
         mResetCallback();
      }
   }


