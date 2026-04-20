package brain.logger
;
   import brain.clock.GameClock;
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.KeyBind;
   import flash.display.Stage;
   import flash.system.Capabilities;
   
    class Logger
   {
      
      static var mReentrentLock:Bool = false;
      
      static var mWantConsole:Bool = false;
      
      static var mWantCommandLine:Bool = false;
      
      static var mWantThrowErrors:Bool = true;
      
      static var mShowDebug:Bool = true;
      
      static var mShowInfo:Bool = true;
      
      public static var errorCallback:ASFunction;
      
      public static var customLoggerString:String;
      
      static var mListSlashCommands:Array<ASAny> = [];
      
      public function new()
      {
         
      }
      
      public static function init(param1:Stage, param2:Bool = false) 
      {
         mWantConsole = param2;
         if(mWantConsole)
         {
            Cc.startOnStage(param1,"0");
         }
      }
      
      public static function displayConsole() 
      {
         Cc.visible = true;
      }
      
      public static function hideConsole() 
      {
         Cc.visible = false;
      }
      
      public static function isConsoleVisible() : Bool
      {
         if(Cc.visible)
         {
            return true;
         }
         return false;
      }
      
      public static function enableCommandLine() 
      {
         mWantCommandLine = true;
         Cc.config.commandLineAllowed = mWantCommandLine;
         mShowDebug = true;
         mShowInfo = true;
      }
      
      public static function setDebugMessages(param1:Bool) 
      {
         mShowDebug = param1;
      }
      
      public static function setInfoMessages(param1:Bool) 
      {
         mShowInfo = param1;
      }
      
      public static function addSlashCommand(param1:String, param2:ASFunction, param3:String = "", param4:Bool = true) 
      {
         Cc.addSlashCommand(param1,param2,param3,param4);
         mListSlashCommands.push(param1);
      }
      
      public static function listSlashCommands() 
      {
         var _loc1_:ASAny;
         final __ax4_iter_119 = mListSlashCommands;
         if (checkNullIteratee(__ax4_iter_119)) for (_tmp_ in __ax4_iter_119)
         {
            _loc1_ = _tmp_;
            log(_loc1_);
         }
      }
      
      public static function bindKey(param1:KeyBind, param2:ASFunction, param3:Array<ASAny> = null) 
      {
         Cc.bindKey(param1,param2,param3);
      }
      
      @:isVar public static var CustomLoggerString(never,set):String;
static public function  set_CustomLoggerString(param1:String) :String      {
         return customLoggerString = param1;
      }
      
      static function pad(param1:Float, param2:UInt) : String
      {
         var _loc3_= Std.string(param1);
         while((_loc3_.length : UInt) < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
      
            
      @:isVar public static var errorsCanThrow(get,set):Bool;
static public function  set_errorsCanThrow(param1:Bool) :Bool      {
         return mWantThrowErrors = param1;
      }
static function  get_errorsCanThrow() : Bool
      {
         return mWantThrowErrors;
      }
      
      static function getDateString() : String
      {
         var _loc1_= GameClock.date;
         return "[" + _loc1_.getFullYear() + "-" + pad(_loc1_.getMonth() + 1,(2 : UInt)) + "-" + pad(_loc1_.getDate(),(2 : UInt)) + " " + pad(_loc1_.getHours(),(2 : UInt)) + ":" + pad(_loc1_.getMinutes(),(2 : UInt)) + ":" + pad(_loc1_.getSeconds(),(2 : UInt)) + "." + pad(ASCompat.ASDate.getMilliseconds(_loc1_),(3 : UInt)) + "] ";
      }
      
      public static function log(param1:String) 
      {
         param1 = "" + param1;
         trace(param1);
         if(mWantConsole)
         {
            Cc.log(param1);
         }
      }
      
      public static function debug(param1:String) 
      {
         if(!mShowDebug || customLoggerString != null)
         {
            return;
         }
         param1 = "[DEBUG] " + getDateString() + param1;
         trace(param1);
         if(mWantConsole)
         {
            Cc.debug(param1);
         }
      }
      
      public static function debugch(param1:String, param2:String) 
      {
         if(!mShowDebug || customLoggerString != null)
         {
            return;
         }
         param2 = "[DEBUG] " + getDateString() + param2;
         trace(param2);
         if(mWantConsole)
         {
            Cc.debugch(param1,param2);
         }
      }
      
      public static function info(param1:String) 
      {
         if(!mShowInfo)
         {
            return;
         }
         param1 = "[INFO]  " + getDateString() + param1;
         trace(param1);
         if(mWantConsole)
         {
            Cc.info(param1);
         }
      }
      
      public static function infoch(param1:String, param2:String) 
      {
         if(!mShowInfo)
         {
            return;
         }
         param2 = "[INFO] " + getDateString() + param2;
         trace(param2);
         if(mWantConsole)
         {
            Cc.infoch(param1,param2);
         }
      }
      
      public static function warn(param1:String) 
      {
         if(customLoggerString != null)
         {
            return;
         }
         param1 = "[WARN]  " + getDateString() + param1;
         trace(param1);
         if(mWantConsole)
         {
            Cc.warn(param1);
         }
      }
      
      public static function warnch(param1:String, param2:String) 
      {
         if(customLoggerString != null)
         {
            return;
         }
         param2 = "[WARN] " + getDateString() + param2;
         trace(param2);
         if(mWantConsole)
         {
            Cc.warnch(param1,param2);
         }
      }
      
      public static function error(param1:String, param2:Error = null) 
      {
         var _loc5_= param2 != null ? param2 : new Error(param1);
         var _loc4_:String = (_loc5_ : ASAny).hasOwnProperty("getStackTrace") ? _loc5_.getStackTrace() : null;
         var _loc3_= ASCompat.stringAsBool(_loc4_) ? param1 + "\n" + _loc4_ : param1;
         tryErrorCallback(_loc3_);
         param1 = "[ERROR] " + getDateString() + _loc3_;
         trace(param1);
         if(mWantConsole)
         {
            Cc.error(param1);
         }
         if(mWantThrowErrors && Capabilities.isDebugger)
         {
            displayConsole();
            Cc.minimumPriority = (8 : UInt);
            _loc5_.name = "LOGGED " + Std.string(_loc5_.name);
            throw _loc5_;
         }
      }
      
      static function tryErrorCallback(param1:String) 
      {
         if(errorCallback != null && !mReentrentLock)
         {
            mReentrentLock = true;
            errorCallback(param1);
            mReentrentLock = false;
         }
      }
      
      public static function fatal(param1:String, param2:Error = null) 
      {
         var _loc5_= param2 != null ? param2 : new Error(param1);
         var _loc4_:String = (_loc5_ : ASAny).hasOwnProperty("getStackTrace") ? _loc5_.getStackTrace() : null;
         param1 = "[FATAL] " + getDateString() + param1;
         var _loc3_= param1 + "\n" + _loc4_;
         trace(_loc3_);
         if(mWantConsole)
         {
            displayConsole();
            Cc.minimumPriority = (8 : UInt);
            Cc.height = 250;
            Cc.warn(_loc3_);
            Cc.fatal(param1);
            Cc.warn("If you are reporting this error please click \'Sv\' at the top to copy the logs to your clipboard");
         }
         tryErrorCallback(param1);
         if(mWantThrowErrors)
         {
            _loc5_.name = "LOGGED " + Std.string(_loc5_.name);
            throw _loc5_;
         }
      }
      
      public static function reloadPage() 
      {
      }
      
      public static function custom(param1:String, param2:String) 
      {
         if(customLoggerString != param1)
         {
            return;
         }
         param2 = "[" + customLoggerString + "]  " + getDateString() + param2;
         trace(param2);
         if(mWantConsole)
         {
            Cc.warn(param2);
         }
      }
   }


