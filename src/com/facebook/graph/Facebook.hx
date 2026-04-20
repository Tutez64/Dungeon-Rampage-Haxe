package com.facebook.graph
;
   import com.adobe.serialization.json.JSON;
   import com.facebook.graph.core.AbstractFacebook;
   import com.facebook.graph.core.FacebookJSBridge;
   import com.facebook.graph.core.FacebookURLDefaults;
   import com.facebook.graph.data.Batch;
   import com.facebook.graph.data.FQLMultiQuery;
   import com.facebook.graph.data.FacebookAuthResponse;
   import com.facebook.graph.net.FacebookRequest;
   import com.facebook.graph.utils.IResultParser;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   
    class Facebook extends AbstractFacebook
   {
      
      static var _instance:Facebook;
      
      static var _canInit:Bool = false;
      
      var jsCallbacks:ASObject;
      
      var openUICalls:ASDictionary<ASAny,ASAny>;
      
      var jsBridge:FacebookJSBridge;
      
      var applicationId:String;
      
      var _initCallback:ASFunction;
      
      var _loginCallback:ASFunction;
      
      var _logoutCallback:ASFunction;
      
      public function new()
      {
         super();
         if(_canInit == false)
         {
            throw new Error("Facebook is an singleton and cannot be instantiated.");
         }
         this.jsBridge = new FacebookJSBridge();
         this.jsCallbacks = {};
         this.openUICalls = new ASDictionary<ASAny,ASAny>();
      }
      
      public static function init(param1:String, param2:ASFunction = null, param3:ASObject = null, param4:String = null) 
      {
         getInstance()._init(param1,param2,param3,param4);
      }
      
      @:isVar public static var locale(never,set):String;
static public function  set_locale(param1:String) :String      {
         return getInstance()._locale = param1;
      }
      
      public static function login(param1:ASFunction, param2:ASObject = null) 
      {
         getInstance()._login(param1,param2);
      }
      
      public static function mobileLogin(param1:String, param2:String = "touch", param3:Array<ASAny> = null) 
      {
         var _loc4_= new URLVariables();
         ASCompat.setProperty(_loc4_, "client_id", getInstance().applicationId);
         ASCompat.setProperty(_loc4_, "redirect_uri", param1);
         ASCompat.setProperty(_loc4_, "display", param2);
         if(param3 != null)
         {
            ASCompat.setProperty(_loc4_, "scope", param3.join(","));
         }
         var _loc5_= new URLRequest(FacebookURLDefaults.AUTH_URL);
         _loc5_.method = URLRequestMethod.GET;
         _loc5_.data = _loc4_;
         flash.Lib.getURL(_loc5_,"_self");
      }
      
      public static function mobileLogout(param1:String) 
      {
         getInstance().authResponse = null;
         var _loc2_= new URLVariables();
         ASCompat.setProperty(_loc2_, "confirm", 1);
         ASCompat.setProperty(_loc2_, "next", param1);
         var _loc3_= new URLRequest("http://m.facebook.com/logout.php");
         _loc3_.method = URLRequestMethod.GET;
         _loc3_.data = _loc2_;
         flash.Lib.getURL(_loc3_,"_self");
      }
      
      public static function logout(param1:ASFunction) 
      {
         getInstance()._logout(param1);
      }
      
      public static function ui(param1:String, param2:ASObject, param3:ASFunction = null, param4:String = null) 
      {
         getInstance()._ui(param1,param2,param3,param4);
      }
      
      public static function api(param1:String, param2:ASFunction = null, param3:ASAny = null, param4:String = "GET") 
      {
         getInstance()._api(param1,param2,param3,param4);
      }
      
      public static function getRawResult(param1:ASObject) : ASObject
      {
         return getInstance()._getRawResult(param1);
      }
      
      public static function hasNext(param1:ASObject) : Bool
      {
         var _loc2_:ASObject = getInstance()._getRawResult(param1);
         if(!ASCompat.toBool(_loc2_.paging))
         {
            return false;
         }
         return _loc2_.paging.next != null;
      }
      
      public static function hasPrevious(param1:ASObject) : Bool
      {
         var _loc2_:ASObject = getInstance()._getRawResult(param1);
         if(!ASCompat.toBool(_loc2_.paging))
         {
            return false;
         }
         return _loc2_.paging.previous != null;
      }
      
      public static function nextPage(param1:ASObject, param2:ASFunction) : FacebookRequest
      {
         return getInstance()._nextPage(param1,param2);
      }
      
      public static function previousPage(param1:ASObject, param2:ASFunction) : FacebookRequest
      {
         return getInstance()._previousPage(param1,param2);
      }
      
      public static function postData(param1:String, param2:ASFunction = null, param3:ASObject = null) 
      {
         api(param1,param2,param3,URLRequestMethod.POST);
      }
      
      public static function uploadVideo(param1:String, param2:ASFunction = null, param3:ASAny = null) 
      {
         getInstance()._uploadVideo(param1,param2,param3);
      }
      
      public static function fqlQuery(param1:String, param2:ASFunction = null, param3:ASObject = null) 
      {
         getInstance()._fqlQuery(param1,param2,param3);
      }
      
      public static function fqlMultiQuery(param1:FQLMultiQuery, param2:ASFunction = null, param3:IResultParser = null) 
      {
         getInstance()._fqlMultiQuery(param1,param2,param3);
      }
      
      public static function batchRequest(param1:Batch, param2:ASFunction = null) 
      {
         getInstance()._batchRequest(param1,param2);
      }
      
      public static function callRestAPI(param1:String, param2:ASFunction, param3:ASAny = null, param4:String = "GET") 
      {
         getInstance()._callRestAPI(param1,param2,param3,param4);
      }
      
      public static function getImageUrl(param1:String, param2:String = null) : String
      {
         return getInstance()._getImageUrl(param1,param2);
      }
      
      public static function deleteObject(param1:String, param2:ASFunction = null) 
      {
         getInstance()._deleteObject(param1,param2);
      }
      
      public static function addJSEventListener(param1:String, param2:ASFunction) 
      {
         getInstance()._addJSEventListener(param1,param2);
      }
      
      public static function removeJSEventListener(param1:String, param2:ASFunction) 
      {
         getInstance()._removeJSEventListener(param1,param2);
      }
      
      public static function hasJSEventListener(param1:String, param2:ASFunction) : Bool
      {
         return getInstance()._hasJSEventListener(param1,param2);
      }
      
      public static function setCanvasAutoResize(param1:Bool = true, param2:UInt = (100 : UInt)) 
      {
         getInstance()._setCanvasAutoResize(param1,param2);
      }
      
      public static function setCanvasSize(param1:Float, param2:Float) 
      {
         getInstance()._setCanvasSize(param1,param2);
      }
      
      public static function callJS(param1:String, param2:ASObject) 
      {
         getInstance()._callJS(param1,param2);
      }
      
      public static function getAuthResponse() : FacebookAuthResponse
      {
         return getInstance()._getAuthResponse();
      }
      
      public static function getLoginStatus() 
      {
         getInstance()._getLoginStatus();
      }
      
      static function getInstance() : Facebook
      {
         if(_instance == null)
         {
            _canInit = true;
            _instance = new Facebook();
            _canInit = false;
         }
         return _instance;
      }
      
      function _init/*renamed*/(param1:String, param2:ASFunction = null, param3:ASObject = null, param4:String = null) 
      {
         ExternalInterface.addCallback("handleJsEvent",this.handleJSEvent);
         ExternalInterface.addCallback("authResponseChange",this.handleAuthResponseChange);
         ExternalInterface.addCallback("logout",this.handleLogout);
         ExternalInterface.addCallback("uiResponse",this.handleUI);
         this._initCallback = param2;
         this.applicationId = param1;
         this.oauth2 = true;
         if(param3 == null)
         {
            param3 = {};
         }
         ASCompat.setProperty(param3, "appId", param1);
         ASCompat.setProperty(param3, "oauth", true);
         ExternalInterface.call("FBAS.init",com.adobe.serialization.json.JSON.encode(param3));
         if(param4 != null)
         {
            authResponse = new FacebookAuthResponse();
            authResponse.accessToken = param4;
         }
         if(param3.status != false)
         {
            this._getLoginStatus();
         }
         else if(this._initCallback != null)
         {
            this._initCallback(authResponse,null);
            this._initCallback = null;
         }
      }
      
      function _getLoginStatus/*renamed*/() 
      {
         ExternalInterface.call("FBAS.getLoginStatus");
      }
      
      function _callJS/*renamed*/(param1:String, param2:ASObject) 
      {
         ExternalInterface.call(param1,param2);
      }
      
      function _setCanvasSize/*renamed*/(param1:Float, param2:Float) 
      {
         ExternalInterface.call("FBAS.setCanvasSize",param1,param2);
      }
      
      function _setCanvasAutoResize/*renamed*/(param1:Bool = true, param2:UInt = (100 : UInt)) 
      {
         ExternalInterface.call("FBAS.setCanvasAutoResize",param1,param2);
      }
      
      function _login/*renamed*/(param1:ASFunction, param2:ASObject = null) 
      {
         this._loginCallback = param1;
         ExternalInterface.call("FBAS.login",com.adobe.serialization.json.JSON.encode(param2));
      }
      
      function _logout/*renamed*/(param1:ASFunction) 
      {
         this._logoutCallback = param1;
         ExternalInterface.call("FBAS.logout");
      }
      
      function _getAuthResponse/*renamed*/() : FacebookAuthResponse
      {
         var a:FacebookAuthResponse;
         var authResponseObj:ASObject = null;
         var result:String = ExternalInterface.call("FBAS.getAuthResponse");
         try
         {
            authResponseObj = com.adobe.serialization.json.JSON.decode(result);
         }
         catch(e:ASAny)
         {
            return null;
         }
         a = new FacebookAuthResponse();
         a.fromJSON(authResponseObj);
         this.authResponse = a;
         return authResponse;
      }
      
      function _ui/*renamed*/(param1:String, param2:ASObject, param3:ASFunction = null, param4:String = null) 
      {
         ASCompat.setProperty(param2, "method", param1);
         if(param3 != null)
         {
            this.openUICalls[param1] = param3;
         }
         if(ASCompat.stringAsBool(param4))
         {
            ASCompat.setProperty(param2, "display", param4);
         }
         ExternalInterface.call("FBAS.ui",com.adobe.serialization.json.JSON.encode(param2));
      }
      
      function _addJSEventListener/*renamed*/(param1:String, param2:ASFunction) 
      {
         if(this.jsCallbacks[param1] == null)
         {
            this.jsCallbacks[param1] = new ASDictionary<ASAny,ASAny>();
            ExternalInterface.call("FBAS.addEventListener",param1);
         }
         this.jsCallbacks[param1][param2] = null;
      }
      
      function _removeJSEventListener/*renamed*/(param1:String, param2:ASFunction) 
      {
         if(this.jsCallbacks[param1] == null)
         {
            return;
         }
         ASCompat.deleteProperty(this.jsCallbacks[param1], param2);
      }
      
      function _hasJSEventListener/*renamed*/(param1:String, param2:ASFunction) : Bool
      {
         if(this.jsCallbacks[param1] == null || this.jsCallbacks[param1][param2] != null)
         {
            return false;
         }
         return true;
      }
      
      function handleUI(param1:String, param2:String) 
      {
         var _loc3_:ASObject = ASCompat.stringAsBool(param1) ? com.adobe.serialization.json.JSON.decode(param1) : null;
         var _loc4_= ASCompat.asFunction(this.openUICalls[param2]);
         if(_loc4_ == null)
         {
            this.openUICalls.remove(param2);
         }
         else
         {
            _loc4_(_loc3_);
            this.openUICalls.remove(param2);
         }
      }
      
      function handleLogout() 
      {
         authResponse = null;
         if(this._logoutCallback != null)
         {
            this._logoutCallback(true);
            this._logoutCallback = null;
         }
      }
      
      function handleJSEvent(param1:String, param2:String = null) 
      {
         var __ax4_iter_154:ASAny;
         var _loc3_:ASObject = null;
         var _loc4_:ASObject = null;
         if(this.jsCallbacks[param1] != null)
         {
            try
            {
               _loc3_ = com.adobe.serialization.json.JSON.decode(param2);
            }
            catch(e:com.adobe.serialization.json.JSONParseError)
            {
            }
            __ax4_iter_154 = this.jsCallbacks[param1];
            if (checkNullIteratee(__ax4_iter_154)) for(_tmp_ in __ax4_iter_154.___keys())
            {
               _loc4_  = _tmp_;
               ASCompat.asFunction(_loc4_ )(_loc3_);
               ASCompat.deleteProperty(this.jsCallbacks[param1], _loc4_);
            }
         }
      }
      
      function handleAuthResponseChange(param1:String) 
      {
         var resultObj:ASObject = null;
         var result= param1;
         var success= true;
         if(result != null)
         {
            try
            {
               resultObj = com.adobe.serialization.json.JSON.decode(result);
            }
            catch(e:com.adobe.serialization.json.JSONParseError)
            {
               success = false;
            }
         }
         else
         {
            success = false;
         }
         if(success)
         {
            if(authResponse == null)
            {
               authResponse = new FacebookAuthResponse();
               authResponse.fromJSON(resultObj);
            }
            else
            {
               authResponse.fromJSON(resultObj);
            }
         }
         if(this._initCallback != null)
         {
            this._initCallback(authResponse,null);
            this._initCallback = null;
         }
         if(this._loginCallback != null)
         {
            this._loginCallback(authResponse,null);
            this._loginCallback = null;
         }
      }
   }


