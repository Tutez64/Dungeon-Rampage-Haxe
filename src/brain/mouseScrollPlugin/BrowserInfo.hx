package brain.mouseScrollPlugin
;
    class BrowserInfo
   {
      
      public static inline final WIN_PLATFORM= "win";
      
      public static inline final MAC_PLATFORM= "mac";
      
      public static inline final SAFARI_AGENT= "safari";
      
      public static inline final OPERA_AGENT= "opera";
      
      public static inline final IE_AGENT= "msie";
      
      public static inline final MOZILLA_AGENT= "mozilla";
      
      public static inline final CHROME_AGENT= "chrome";
      
      var _platform:String = "undefined";
      
      var _browser:String = "undefined";
      
      var _version:String = "undefined";
      
      public function new(param1:ASObject, param2:ASObject, param3:String)
      {
         
         if(!ASCompat.toBool(param1) || !ASCompat.toBool(param2) || !ASCompat.stringAsBool(param3))
         {
            return;
         }
         _version = param1.version;
         var _loc5_:String;
         if (checkNullIteratee(param1)) for(_tmp_ in param1.___keys())
         {
            _loc5_ = _tmp_;
            if(_loc5_ != "version")
            {
               if(param1[_loc5_] == true)
               {
                  _browser = _loc5_;
                  break;
               }
            }
         }
         var _loc4_:String;
         if (checkNullIteratee(param2)) for(_tmp_ in param2.___keys())
         {
            _loc4_ = _tmp_;
            if(param2[_loc4_] == true)
            {
               _platform = _loc4_;
            }
         }
      }
      
      @:isVar public var platform(get,never):String;
public function  get_platform() : String
      {
         return _platform;
      }
      
      @:isVar public var browser(get,never):String;
public function  get_browser() : String
      {
         return _browser;
      }
      
      @:isVar public var version(get,never):String;
public function  get_version() : String
      {
         return _version;
      }
   }


