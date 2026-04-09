package com.wildtangent
;
   import flash.display.Loader;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   
   @:bind
   @:native("symbol43")
    class WildTangentAPI extends Sprite
   {
      
      public var Ads:Ads = new Ads();
      
      public var BrandBoost:BrandBoost = new BrandBoost();
      
      public var Stats:Stats = new Stats();
      
      public var Vex:Vex = new Vex();
      
      public var Store:Store = new Store();
      
      var myVex:ASAny = null;
      
      var _vexReady:Bool = false;
      
      var _dpName:String;
      
      var _gameName:String;
      
      var _adServerGameName:String;
      
      var _partnerName:String;
      
      var _siteName:String;
      
      var _userId:String;
      
      var _cipherKey:String;
      
      var _vexUrl:String = "http://vex.wildtangent.com";
      
      var _sandbox:Bool = false;
      
      var _javascriptReady:Bool = false;
      
      var _adComplete:ASFunction;
      
      var _closed:ASFunction;
      
      var _error:ASFunction;
      
      var _handlePromo:ASFunction;
      
      var _redeemCode:ASFunction;
      
      var _requireLogin:ASFunction;
      
      var _localMode:Bool = false;
      
      var methodStorage:Array<ASAny> = [];
      
      public function new()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,loadVex);
      }
      
      function loadVex(param1:Event) 
      {
         var context:LoaderContext = null;
         var request:URLRequest = null;
         var e= param1;
         var loader= new Loader();
         loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadAPI);
         loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onLoadFailure);
         loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
         try
         {
            _localMode = loaderInfo.url.indexOf("file") == 0;
         }
         catch(e:ASAny)
         {
         }
         if(!_localMode)
         {
            context = new LoaderContext();
            context.securityDomain = SecurityDomain.currentDomain;
            request = new URLRequest(_vexUrl + "/swf/VexAPI");
            request.data = new URLVariables("cache=" + Date.now().getTime());
            request.method = URLRequestMethod.POST;
            loader.load(request,context);
         }
         else
         {
            loader.load(new URLRequest("VexAPI.swf"));
         }
      }
      
      function loadAPI(param1:Event) 
      {
         var e= param1;
         myVex = e.target.content;
         addChild(ASCompat.dynamicAs(myVex, flash.display.DisplayObject));
         if(root.loaderInfo.parameters.canvasSize != null)
         {
            ASCompat.setProperty(myVex, "canvasSize", root.loaderInfo.parameters.canvasSize);
         }
         vexReady = true;
         ASCompat.setProperty(myVex, "loaderParameters", root.loaderInfo.parameters);
         try
         {
            ASCompat.setProperty(myVex, "localMode", _localMode);
         }
         catch(e:ASAny)
         {
         }
         sendExistingParameters();
         initBrandBoost();
         initVex();
         initStats();
         initAds();
         initStore();
         dispatchEvent(e);
      }
      
      function initBrandBoost() 
      {
         BrandBoost.myVex = myVex;
         BrandBoost.sendExistingParameters();
         BrandBoost.launchMethods();
      }
      
      function initVex() 
      {
         Vex.myVex = myVex;
         Vex.sendExistingParameters();
         Vex.launchMethods();
      }
      
      function initStats() 
      {
         Stats.myVex = myVex;
         Stats.sendExistingParameters();
         Stats.launchMethods();
      }
      
      function initAds() 
      {
         Ads.myVex = myVex;
         Ads.sendExistingParameters();
         Ads.launchMethods();
      }
      
      function initStore() 
      {
         Store.myVex = myVex;
         Store.sendExistingParameters();
         Store.launchMethods();
      }
      
      function onLoadFailure(param1:IOErrorEvent) 
      {
         trace("[VEX] failed to load API");
         Ads.vexFailed = true;
         Ads.launchMethods();
         BrandBoost.vexFailed = true;
         BrandBoost.launchMethods();
      }
      
      function onSecurityError(param1:SecurityErrorEvent) 
      {
         trace("[VEX] security error trying to load files");
         Ads.vexFailed = true;
         Ads.launchMethods();
         BrandBoost.vexFailed = true;
         BrandBoost.launchMethods();
      }
      
      function sendExistingParameters() 
      {
         if(ASCompat.stringAsBool(_dpName))
         {
            ASCompat.setProperty(myVex, "dpName", _dpName);
         }
         if(ASCompat.stringAsBool(_gameName))
         {
            ASCompat.setProperty(myVex, "gameName", _gameName);
         }
         if(ASCompat.stringAsBool(_adServerGameName))
         {
            ASCompat.setProperty(myVex, "adServerGameName", _adServerGameName);
         }
         if(ASCompat.stringAsBool(_partnerName))
         {
            ASCompat.setProperty(myVex, "partnerName", _partnerName);
         }
         if(ASCompat.stringAsBool(_siteName))
         {
            ASCompat.setProperty(myVex, "siteName", _siteName);
         }
         if(ASCompat.stringAsBool(_userId))
         {
            ASCompat.setProperty(myVex, "userId", _userId);
         }
         if(_sandbox)
         {
            ASCompat.setProperty(myVex, "sandbox", _sandbox);
         }
         if(ASCompat.stringAsBool(_cipherKey))
         {
            ASCompat.setProperty(myVex, "cipherKey", _cipherKey);
         }
         if(_adComplete != null)
         {
            ASCompat.setProperty(myVex, "adComplete", _adComplete);
         }
         if(_closed != null)
         {
            ASCompat.setProperty(myVex, "closed", _closed);
         }
         if(_error != null)
         {
            ASCompat.setProperty(myVex, "error", _error);
         }
         if(_redeemCode != null)
         {
            ASCompat.setProperty(myVex, "redeemCode", _redeemCode);
         }
      }
      
            
      @:isVar var vexReady(get,set):Bool;
function  set_vexReady(param1:Bool) :Bool      {
         BrandBoost.vexReady = param1;
         Ads.vexReady = param1;
         Stats.vexReady = param1;
         Vex.vexReady = param1;
         Store.vexReady = param1;
         return _vexReady = param1;
      }
function  get_vexReady() : Bool
      {
         return _vexReady;
      }
      
      @:isVar var javascriptReady(never,set):Bool;
function  set_javascriptReady(param1:Bool) :Bool      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "javascriptReady", param1);
         }
         else
         {
            _javascriptReady = param1;
         }
return param1;
      }
      
            
      @:isVar public var userId(get,set):String;
public function  get_userId() : String
      {
         return vexReady ? myVex.userId : _userId;
      }
function  set_userId(param1:String) :String      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "userId", param1);
         }
         else
         {
            _userId = param1;
         }
return param1;
      }
      
            
      @:isVar public var partnerName(get,set):String;
public function  set_partnerName(param1:String) :String      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "partnerName", param1);
         }
         else
         {
            _partnerName = param1;
         }
return param1;
      }
function  get_partnerName() : String
      {
         return vexReady ? myVex.partnerName : _partnerName;
      }
      
            
      @:isVar public var siteName(get,set):String;
public function  set_siteName(param1:String) :String      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "siteName", param1);
         }
         else
         {
            _siteName = param1;
         }
return param1;
      }
function  get_siteName() : String
      {
         return vexReady ? myVex.siteName : _siteName;
      }
      
            
      @:isVar public var gameName(get,set):String;
public function  set_gameName(param1:String) :String      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "gameName", param1);
         }
         else
         {
            _gameName = param1;
         }
return param1;
      }
function  get_gameName() : String
      {
         return vexReady ? myVex.gameName : _gameName;
      }
      
      @:isVar public var adServerGameName(never,set):String;
public function  set_adServerGameName(param1:String) :String      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "adServerGameName", param1);
         }
         else
         {
            _adServerGameName = param1;
         }
return param1;
      }
      
            
      @:isVar public var dpName(get,set):String;
public function  set_dpName(param1:String) :String      {
         if(vexReady)
         {
            ASCompat.setProperty(myVex, "dpName", param1);
         }
         else
         {
            _dpName = param1;
         }
return param1;
      }
function  get_dpName() : String
      {
         return vexReady ? myVex.dpName : _dpName;
      }
      
      @:isVar public var sandbox(never,set):Bool;
public function  set_sandbox(param1:Bool) :Bool      {
         _vexUrl = param1 ? "http://vex.bpi.wildtangent.com" : "http://vex.wildtangent.com";
         return _sandbox = param1;
      }
      
      @:isVar public var VERSION(get,never):String;
public function  get_VERSION() : String
      {
         return vexReady ? myVex.VERSION : "Not yet loaded";
      }
   }


