package brain.facebookAPI
;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import com.facebook.graph.Facebook;
   import flash.external.ExternalInterface;
   
    class FacebookAPIController
   {
      
      var mAccessToken:String = "";
      
      var mScope:String;
      
      var mUserId:String = "";
      
      public function new(param1:Facade, param2:String)
      {
         
         var _loc3_:ASObject = {
            "appId":param2,
            "status":true,
            "cookie":true,
            "xfbml":true,
            "frictionlessRequests":true,
            "oauth":true
         };
         Logger.debug("Initing app: " + param2.toString());
         if(ExternalInterface.available)
         {
            Facebook.addJSEventListener("auth.authResponseChange",onAuthResponseChange);
            Facebook.init(param2,handleInit,_loc3_);
         }
      }
      
      @:isVar public var accessToken(get,never):String;
public function  get_accessToken() : String
      {
         return mAccessToken;
      }
      
      @:isVar public var fbUserId(get,never):String;
public function  get_fbUserId() : String
      {
         return mUserId;
      }
      
      function onAuthResponseChange(param1:ASObject) 
      {
         Logger.debug("Auth response Changed");
      }
      
      function handleLogin(param1:ASFunction) 
      {
         var successCallback= param1;
         Facebook.login(ASCompat.asFunction((function():ASAny
         {
            var detectLogin:ASFunction;
            return detectLogin = function(param1:ASObject, param2:ASObject)
            {
               if(ASCompat.toBool(param1))
               {
                  Logger.debug("Logged in to FB");
                  mAccessToken = param1.accessToken;
                  successCallback();
               }
               else
               {
                  Logger.debug("Login Failed ");
               }
            };
         })()),{"scope":mScope});
      }
      
      function handleInit(param1:ASObject, param2:ASObject) 
      {
         if(ASCompat.toBool(param1))
         {
            Logger.debug("Init Success ");
            if(ASCompat.toBool(param1.accessToken))
            {
               mAccessToken = param1.accessToken;
            }
         }
         else
         {
            Logger.debug("Init Failed");
         }
      }
      
      function detectLogin(param1:ASObject, param2:ASObject) 
      {
         if(ASCompat.toBool(param1))
         {
            Logger.debug("Logged in to FB");
            mAccessToken = param1.accessToken;
         }
         else
         {
            Logger.debug("Login Failed ");
         }
      }
      
      function feedPost(param1:String = " ", param2:String = " ", param3:String = " ", param4:String = "", param5:String = "", param6:String = "dialog", param7:ASFunction = null, param8:String = "", param9:ASObject = null, param10:ASObject = null) 
      {
         var _loc11_:ASObject = {
            "name":param1,
            "link":param4,
            "picture":param5,
            "caption":param2,
            "description":param3,
            "to":param8,
            "properties":param9,
            "actions":param10
         };
         Facebook.ui("feed",_loc11_,param7,param6);
      }
      
      function friendRequests(param1:String, param2:String = "Invite Friends", param3:String = "dialog", param4:ASFunction = null, param5:Array<ASAny> = null, param6:ASObject = null, param7:String = "50", param8:String = "", param9:Array<ASAny> = null) 
      {
         var _loc10_:ASObject = {
            "message":param1,
            "title":param2,
            "filters":param5,
            "max_recipients":param7,
            "data":param6,
            "to":param8,
            "exclude_ids":param9
         };
         Facebook.ui("apprequests",_loc10_,param4,param3);
      }
      
      function postAchievement(param1:String, param2:ASObject, param3:ASFunction = null) 
      {
         var _loc4_= "/" + param1 + "/achievements";
         Facebook.api(_loc4_,param3,param2,"POST");
      }
   }


