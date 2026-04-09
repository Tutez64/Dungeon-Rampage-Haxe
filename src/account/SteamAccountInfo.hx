package account
;
   import brain.logger.Logger;
   import brain.utils.HttpStatusEventUtils;
   import facade.DBFacade;
   import com.greensock.TweenMax;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   
    class SteamAccountInfo
   {
      
      public static inline final steamRetryDelay:Float = 0.25;
      
      public static inline final maxSteamRetries:Float = 80;
      
      public static var steamRetries:Int = 0;
      
      public function new()
      {
         
      }
      
      public static function getOrCreateAccount(param1:DBFacade, param2:ASFunction) 
      {
         var dbFacade= param1;
         var successCallback= param2;
         if(!dbFacade.mUseSteamLogin)
         {
            Logger.info("Skipping logging into Steam.");
            successCallback();
            return;
         }
         spinWaitOnSteamTokenReceived(dbFacade,function()
         {
            SteamAccountInfo.getOrCreateAccountAfterSteamTokenReceived(dbFacade,successCallback);
         });
      }
      
      public static function spinWaitOnSteamTokenReceived(param1:DBFacade, param2:ASFunction) 
      {
         var dbFacade= param1;
         var successCallback= param2;
         if(ASCompat.stringAsBool(dbFacade.mSteamWebApiAuthTicket))
         {
            successCallback();
         }
         else
         {
            if(steamRetries >= 80)
            {
               Logger.fatal("Steam login ticket not received from Steam SDK after 80 attempts. Aborting. Try restarting Steam completely");
            }
            steamRetries = steamRetries + 1;
            Logger.info("Steam login ticket not received yet from Steam SDK, waiting another 0.25 seconds. [" + steamRetries + "/" + 80 + "]");
            TweenMax.delayedCall(0.25,function()
            {
               spinWaitOnSteamTokenReceived(dbFacade,successCallback);
            });
         }
      }
      
      public static function getOrCreateAccountAfterSteamTokenReceived(param1:DBFacade, param2:ASFunction) 
      {
         var destroyCallbacks:()->Void = null;
         var apiPath:String;
         var request:URLRequest;
         var jsonHeader:URLRequestHeader;
         var requestObject:ASObject;
         var requestJsonString:String;
         var urlLoader:URLLoader = null;
         var responseStatusCode:Int;
         var dbFacade= param1;
         var successCallback= param2;
         var onResponseStatus= function(param1:flash.events.HTTPStatusEvent)
         {
            responseStatusCode = param1.status;
            dbFacade.initialLoginTraceId = HttpStatusEventUtils.getTraceId(param1);
         };
         var onLoadError= function(param1:flash.events.Event)
         {
            destroyCallbacks();
            Logger.info("[Steam] Cancelling Auth token due to failure");
            dbFacade.mSteamworks.cancelAuthTicket(dbFacade.mSteamAuthTicketHandle);
            var _loc2_= "[" + responseStatusCode + "] Error Logging into Dungeon Rampage Server with Steam Login. HTTP Error: " + responseStatusCode + "; TraceId: " + dbFacade.initialLoginTraceId + "; IOError: " + param1.toString();
            if(ASCompat.toBool(param1.target) && ASCompat.toBool(param1.target.data))
            {
               _loc2_ += "; Response: " + Std.string(param1.target.data);
            }
            if(dbFacade.mainStateMachine != null)
            {
               if(responseStatusCode == 0)
               {
                  dbFacade.mainStateMachine.enterSocketErrorState((1503 : UInt));
               }
               else
               {
                  dbFacade.mainStateMachine.enterSocketErrorState((1500 : UInt),Std.string(responseStatusCode));
               }
               Logger.error(_loc2_);
            }
            else
            {
               Logger.fatal(_loc2_);
            }
         };
         var onCompleted= function(param1:flash.events.Event)
         {
            var _loc2_:ASObject = null;
            if(responseStatusCode < 100 || responseStatusCode >= 400)
            {
               onLoadError(param1);
            }
            else
            {
               destroyCallbacks();
               _loc2_ = haxe.Json.parse(param1.target.data);
               dbFacade.accountId = (ASCompat.toInt(_loc2_.playerId) : UInt);
               dbFacade.mSteamIsFlagged = ASCompat.toBool(_loc2_.isFlagged);
               dbFacade.mSteamIsFlaggedDueToFamilySharingOwnerIsFlagged = ASCompat.toBool(_loc2_.isFlaggedDueToFamilySharingOwnerIsFlagged);
               dbFacade.mSteamFlaggedUntilAfterDateString = _loc2_.flaggedUntilAfterDateString;
               dbFacade.mSteamIsFlaggedDueToFamilySharingOwnerName = _loc2_.isFlaggedDueToFamilySharingOwnerName;
               Logger.info("[Steam] Initial login successful! [" + responseStatusCode + "] " + dbFacade.initialLoginTraceId);
               Logger.info("[Steam] Steam account number is " + SteamIdConverter.convertSteamID64ToAccountId(dbFacade.mSteamUserId) + " and shorter id is https://s.team/p/" + SteamIdConverter.convertSteamID64ToSteamHex(dbFacade.mSteamUserId) + " which reverses to " + SteamIdConverter.convertSteamHexToSteamID64(SteamIdConverter.convertSteamID64ToSteamHex(dbFacade.mSteamUserId)));
               dbFacade.validationToken = _loc2_.playerToken;
               Logger.info("[Steam] Cancelling Auth token now that it is used");
               dbFacade.mSteamworks.cancelAuthTicket(dbFacade.mSteamAuthTicketHandle);
               successCallback();
            }
         };
         destroyCallbacks = function()
         {
            urlLoader.removeEventListener("httpResponseStatus",onResponseStatus);
            urlLoader.removeEventListener("ioError",onLoadError);
            urlLoader.removeEventListener("securityError",onLoadError);
            urlLoader.removeEventListener("certificateError",onLoadError);
            urlLoader.removeEventListener("complete",onCompleted);
         };
         Logger.info("Logging into server with id " + dbFacade.mSteamUserId + " and persona name " + dbFacade.mSteamPersonaName + " for app id " + dbFacade.mSteamAppId);
         if(!ASCompat.stringAsBool(dbFacade.mSteamUserId) || !ASCompat.stringAsBool(dbFacade.mSteamPersonaName) || dbFacade.mSteamAppId == 0)
         {
            Logger.fatal("Failed to get user\'s data from Steam. Maybe Steam is not running?");
         }
         apiPath = dbFacade.steamAPIRoot + "login/" + dbFacade.mSteamUserId;
         request = new URLRequest(apiPath);
         request.idleTimeout = 90000;
         request.method = "PUT";
         jsonHeader = new URLRequestHeader("Content-Type","application/json");
         request.requestHeaders.push(jsonHeader);
         requestObject = {
            "steamUserId":dbFacade.mSteamUserId,
            "steamUserPersonaName":dbFacade.mSteamPersonaName,
            "steamWebApiAuthTicket":dbFacade.mSteamWebApiAuthTicket,
            "requestingSteamAppId":dbFacade.mSteamAppId
         };
         requestJsonString = haxe.Json.stringify(requestObject);
         request.data = requestJsonString;
         urlLoader = new URLLoader();
         urlLoader.addEventListener("httpResponseStatus",onResponseStatus);
         urlLoader.addEventListener("ioError",onLoadError);
         urlLoader.addEventListener("securityError",onLoadError);
         urlLoader.addEventListener("certificateError",onLoadError);
         urlLoader.addEventListener("complete",onCompleted);
         responseStatusCode = 0;
         urlLoader.load(request);
      }
   }


