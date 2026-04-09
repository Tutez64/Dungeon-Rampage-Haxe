

   import brain.GameEntry;
   import brain.logger.Logger;
   import brain.mouseScrollPlugin.*;
   import facade.DBFacade;
   import com.amanitadesign.steam.SteamEvent;
   import flash.desktop.NativeApplication;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.InvokeEvent;
@:meta(SWF(width="1920", height="1080", backgroundColor="#000000", frameRate="60"))
    class DungeonBustersProject extends GameEntry
   {
      
      var mDBFacade:DBFacade;
      
      public function new()
      {
         super();
         stage.scaleMode = "showAll";
         stage.quality = "high";
         stage.align = "";
         mDBFacade = new DBFacade();
         mDBFacade.init(this.stage);
         NativeApplication.nativeApplication.addEventListener("invoke",onInvoke);
         MouseWheelEnabler.init(this.stage);
         this.loaderInfo.uncaughtErrorEvents.addEventListener("uncaughtError",function(param1:flash.events.UncaughtErrorEvent)
         {
            var _loc2_:String = null;
            var _loc5_:Error = null;
            param1.preventDefault();
            var _loc4_= false;
            if(Std.isOfType(param1.error , Error))
            {
               _loc5_ = ASCompat.dynamicAs(param1.error , Error);
               _loc2_ = (_loc5_ : ASAny).hasOwnProperty("getStackTrace") ? _loc5_.getStackTrace() : Std.string(_loc5_);
               if(_loc5_ != null && ASCompat.toBool(_loc5_.name) && ASCompat.toNumber(_loc5_.name.indexOf("LOGGED")) == 0)
               {
                  _loc4_ = true;
               }
            }
            else if(Std.isOfType(param1.error , ErrorEvent))
            {
               _loc2_ = cast(param1.error, ErrorEvent).text;
            }
            else
            {
               _loc2_ = "Unknown error";
            }
            var _loc3_= 0;
            if(mDBFacade != null && mDBFacade.gameClock != null)
            {
               _loc3_ = mDBFacade.gameClock.gameTime;
            }
            if(!_loc4_)
            {
               Logger.error("UncaughtError: " + _loc2_);
            }
            mDBFacade.loggerErrorCall("UncaughtError: " + _loc2_ + " GameTime: " + _loc3_);
         });
      }
      
      public function onInvoke(param1:InvokeEvent = null) 
      {
         NativeApplication.nativeApplication.addEventListener("exiting",onExit);
         try
         {
            if(!mDBFacade.mSteamworks.init())
            {
               Logger.warn("STEAMWORKS API is NOT available");
            }
            else
            {
               Logger.info("STEAMWORKS API is available\n");
               mDBFacade.mSteamworks.addEventListener(SteamEvent.STEAM_RESPONSE,onSteamResponse);
               mDBFacade.mSteamUserId = mDBFacade.mSteamworks.getUserID();
               Logger.info("STEAMWORKS User ID: " + mDBFacade.mSteamUserId);
               mDBFacade.mSteamAppId = mDBFacade.mSteamworks.getAppID();
               Logger.info("STEAMWORKS App ID: " + mDBFacade.mSteamAppId);
               mDBFacade.mSteamPersonaName = mDBFacade.mSteamworks.getPersonaName();
               Logger.info("STEAMWORKS Persona name: " + mDBFacade.mSteamPersonaName);
               mDBFacade.mSteamworks.getAuthTicketForWebApi();
            }
         }
         catch(e:Dynamic)
         {
            Logger.warn("*** STEAMWORKS ERROR ***");
            Logger.error(e.message,e);
         }
         processArguments(param1.arguments);
      }
      
      function onSteamResponse(param1:SteamEvent) 
      {
         switch(param1.req_type - 27)
         {
            case 0:
               Logger.info("[Steam] RESPONSE_OnGetAuthTicketForWebApiResponse: " + param1.response);
               mDBFacade.mSteamWebApiAuthTicket = mDBFacade.mSteamworks.getAuthTicketForWebApiResultHexString();
               mDBFacade.mSteamAuthTicketHandle = mDBFacade.mSteamworks.getAuthTicketForWebApiResultHandle();
         }
      }
      
      function onExit(param1:Event) 
      {
         Logger.info("Exiting application, cleaning up Steam");
         if(mDBFacade.mSteamworks != null)
         {
            mDBFacade.mSteamworks.dispose();
         }
      }
      
      function processArguments(param1:Array<ASAny>) 
      {
         var _loc3_= 0;
         var _loc2_:String = null;
         mDBFacade.featureFlags.loadFeatureFlagValuesFromCli(param1);
         var _loc4_= 0;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = param1[_loc3_];
            if(endsWith(_loc2_,".json"))
            {
               if(++_loc4_ > 2)
               {
                  Logger.warn("GBS: Too many JSON files passed in! Only supports two json files, ignoring: " + _loc2_);
               }
               else
               {
                  mDBFacade.mAdditionalConfigFilesToLoad.push("DBConfiguration/" + _loc2_);
               }
            }
            _loc3_++;
         }
      }
      
      public function endsWith(param1:String, param2:String) : Bool
      {
         return param2 == param1.substring(param1.length - param2.length);
      }
   }

