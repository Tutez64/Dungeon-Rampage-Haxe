package com.junkbyte.console
;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.geom.Rectangle;
   
    class Cc
   {
      
      static var _console:Console;
      
      static var _config:ConsoleConfig;
      
      public function new()
      {
         
      }
      
      @:isVar public static var config(get,never):ConsoleConfig;
static public function  get_config() : ConsoleConfig
      {
         if(_config == null)
         {
            _config = new ConsoleConfig();
         }
         return _config;
      }
      
      public static function start(param1:DisplayObjectContainer, param2:String = "") 
      {
         if(_console != null)
         {
            if(ASCompat.toBool(param1) && _console.parent == null)
            {
               param1.addChild(_console);
            }
         }
         else
         {
            _console = new Console(param2,config);
            if(param1 != null)
            {
               param1.addChild(_console);
            }
         }
      }
      
      public static function startOnStage(param1:DisplayObject, param2:String = "") 
      {
         if(_console != null)
         {
            if(param1 != null && param1.stage != null && _console.parent != param1.stage)
            {
               param1.stage.addChild(_console);
            }
         }
         else if(ASCompat.toBool(param1) && ASCompat.toBool(param1.stage))
         {
            start(param1.stage,param2);
         }
         else
         {
            _console = new Console(param2,config);
            if(param1 != null)
            {
               param1.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandle);
            }
         }
      }
      
      public static function add(param1:ASAny, param2:Int = 2, param3:Bool = false) 
      {
         if(_console != null)
         {
            _console.add(param1,param2,param3);
         }
      }
      
      public static function ch(param1:ASAny, param2:ASAny, param3:Int = 2, param4:Bool = false) 
      {
         if(_console != null)
         {
            _console.ch(param1,param2,param3,param4);
         }
      }
      
      public static function log(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            ASCompatMacro.applyBoundMethod(_console, "log", rest);
         }
      }
      
      public static function info(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            ASCompatMacro.applyBoundMethod(_console, "info", rest);
         }
      }
      
      public static function debug(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            ASCompatMacro.applyBoundMethod(_console, "debug", rest);
         }
      }
      
      public static function warn(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            ASCompatMacro.applyBoundMethod(_console, "warn", rest);
         }
      }
      
      public static function error(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            ASCompatMacro.applyBoundMethod(_console, "error", rest);
         }
      }
      
      public static function fatal(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            ASCompatMacro.applyBoundMethod(_console, "fatal", rest);
         }
      }
      
      public static function logch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            _console.addCh(param1,rest,(Console.LOG : Int));
         }
      }
      
      public static function infoch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            _console.addCh(param1,rest,(Console.INFO : Int));
         }
      }
      
      public static function debugch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            _console.addCh(param1,rest,(Console.DEBUG : Int));
         }
      }
      
      public static function warnch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            _console.addCh(param1,rest,(Console.WARN : Int));
         }
      }
      
      public static function errorch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            _console.addCh(param1,rest,(Console.ERROR_cpp : Int));
         }
      }
      
      public static function fatalch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            _console.addCh(param1,rest,(Console.FATAL : Int));
         }
      }
      
      public static function stack(param1:ASAny, param2:Int = -1, param3:Int = 5) 
      {
         if(_console != null)
         {
            _console.stack(param1,param2,param3);
         }
      }
      
      public static function stackch(param1:ASAny, param2:ASAny, param3:Int = -1, param4:Int = 5) 
      {
         if(_console != null)
         {
            _console.stackch(param1,param2,param3,param4);
         }
      }
      
      public static function inspect(param1:ASObject, param2:Bool = true) 
      {
         if(_console != null)
         {
            _console.inspect(param1,param2);
         }
      }
      
      public static function inspectch(param1:ASAny, param2:ASObject, param3:Bool = true) 
      {
         if(_console != null)
         {
            _console.inspectch(param1,param2,param3);
         }
      }
      
      public static function explode(param1:ASObject, param2:Int = 3) 
      {
         if(_console != null)
         {
            _console.explode(param1,param2);
         }
      }
      
      public static function explodech(param1:ASAny, param2:ASObject, param3:Int = 3) 
      {
         if(_console != null)
         {
            _console.explodech(param1,param2,param3);
         }
      }
      
      public static function addHTML(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            ASCompatMacro.applyBoundMethod(_console, "addHTML", rest);
         }
      }
      
      public static function addHTMLch(param1:ASAny, param2:Int, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            ASCompatMacro.applyBoundMethod(_console, "addHTMLch", ([param1,param2] : Array<ASAny>).concat(rest));
         }
      }
      
      public static function map(param1:DisplayObjectContainer, param2:UInt = (0 : UInt)) 
      {
         if(_console != null)
         {
            _console.map(param1,param2);
         }
      }
      
      public static function mapch(param1:ASAny, param2:DisplayObjectContainer, param3:UInt = (0 : UInt)) 
      {
         if(_console != null)
         {
            _console.mapch(param1,param2,param3);
         }
      }
      
      public static function clear(param1:String = null) 
      {
         if(_console != null)
         {
            _console.clear(param1);
         }
      }
      
      public static function bindKey(param1:KeyBind, param2:ASFunction = null, param3:Array<ASAny> = null) 
      {
         if(_console != null)
         {
            _console.bindKey(param1,param2,param3);
         }
      }
      
      public static function addMenu(param1:String, param2:ASFunction, param3:Array<ASAny> = null, param4:String = null) 
      {
         if(_console != null)
         {
            _console.addMenu(param1,param2,param3,param4);
         }
      }
      
      public static function listenUncaughtErrors(param1:LoaderInfo) 
      {
         if(_console != null)
         {
            _console.listenUncaughtErrors(param1);
         }
      }
      
      public static function store(param1:String, param2:ASObject, param3:Bool = false) 
      {
         if(_console != null)
         {
            _console.store(param1,param2,param3);
         }
      }
      
      public static function addSlashCommand(param1:String, param2:ASFunction, param3:String = "", param4:Bool = true, param5:String = ";") 
      {
         if(_console != null)
         {
            _console.addSlashCommand(param1,param2,param3,param4,param5);
         }
      }
      
      public static function watch(param1:ASObject, param2:String = null) : String
      {
         if(_console != null)
         {
            return _console.watch(param1,param2);
         }
         return null;
      }
      
      public static function unwatch(param1:String) 
      {
         if(_console != null)
         {
            _console.unwatch(param1);
         }
      }
      
      public static function addGraph(param1:String, param2:ASObject, param3:String, param4:Float = -1, param5:String = null, param6:Rectangle = null, param7:Bool = false) 
      {
         if(_console != null)
         {
            _console.addGraph(param1,param2,param3,param4,param5,param6,param7);
         }
      }
      
      public static function fixGraphRange(param1:String, param2:Float = null, param3:Float = null) 
{
         if (param2 == null) param2 = Math.NaN;
         if (param3 == null) param3 = Math.NaN;
         if(_console != null)
         {
            _console.fixGraphRange(param1,param2,param3);
         }
      }
      
      public static function removeGraph(param1:String, param2:ASObject = null, param3:String = null) 
      {
         if(_console != null)
         {
            _console.removeGraph(param1,param2,param3);
         }
      }
      
      public static function setViewingChannels(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            ASCompatMacro.applyBoundMethod(_console, "setViewingChannels", rest);
         }
      }
      
      public static function setIgnoredChannels(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         if(_console != null)
         {
            ASCompatMacro.applyBoundMethod(_console, "setIgnoredChannels", rest);
         }
      }
      
      @:isVar public static var minimumPriority(never,set):UInt;
static public function  set_minimumPriority(param1:UInt) :UInt      {
         if(_console != null)
         {
            _console.minimumPriority = param1;
         }
return param1;
      }
      
            
      @:isVar public static var width(get,set):Float;
static public function  get_width() : Float
      {
         if(_console != null)
         {
            return _console.width;
         }
         return 0;
      }
static function  set_width(param1:Float) :Float      {
         if(_console != null)
         {
            _console.width = param1;
         }
return param1;
      }
      
            
      @:isVar public static var height(get,set):Float;
static public function  get_height() : Float
      {
         if(_console != null)
         {
            return _console.height;
         }
         return 0;
      }
static function  set_height(param1:Float) :Float      {
         if(_console != null)
         {
            _console.height = param1;
         }
return param1;
      }
      
            
      @:isVar public static var x(get,set):Float;
static public function  get_x() : Float
      {
         if(_console != null)
         {
            return _console.x;
         }
         return 0;
      }
static function  set_x(param1:Float) :Float      {
         if(_console != null)
         {
            _console.x = param1;
         }
return param1;
      }
      
            
      @:isVar public static var y(get,set):Float;
static public function  get_y() : Float
      {
         if(_console != null)
         {
            return _console.y;
         }
         return 0;
      }
static function  set_y(param1:Float) :Float      {
         if(_console != null)
         {
            _console.y = param1;
         }
return param1;
      }
      
            
      @:isVar public static var visible(get,set):Bool;
static public function  get_visible() : Bool
      {
         if(_console != null)
         {
            return _console.visible;
         }
         return false;
      }
static function  set_visible(param1:Bool) :Bool      {
         if(_console != null)
         {
            _console.visible = param1;
         }
return param1;
      }
      
            
      @:isVar public static var fpsMonitor(get,set):Bool;
static public function  get_fpsMonitor() : Bool
      {
         if(_console != null)
         {
            return _console.fpsMonitor;
         }
         return false;
      }
static function  set_fpsMonitor(param1:Bool) :Bool      {
         if(_console != null)
         {
            _console.fpsMonitor = param1;
         }
return param1;
      }
      
            
      @:isVar public static var memoryMonitor(get,set):Bool;
static public function  get_memoryMonitor() : Bool
      {
         if(_console != null)
         {
            return _console.memoryMonitor;
         }
         return false;
      }
static function  set_memoryMonitor(param1:Bool) :Bool      {
         if(_console != null)
         {
            _console.memoryMonitor = param1;
         }
return param1;
      }
      
            
      @:isVar public static var commandLine(get,set):Bool;
static public function  get_commandLine() : Bool
      {
         if(_console != null)
         {
            return _console.commandLine;
         }
         return false;
      }
static function  set_commandLine(param1:Bool) :Bool      {
         if(_console != null)
         {
            _console.commandLine = param1;
         }
return param1;
      }
      
            
      @:isVar public static var displayRoller(get,set):Bool;
static public function  get_displayRoller() : Bool
      {
         if(_console != null)
         {
            return _console.displayRoller;
         }
         return false;
      }
static function  set_displayRoller(param1:Bool) :Bool      {
         if(_console != null)
         {
            _console.displayRoller = param1;
         }
return param1;
      }
      
      public static function setRollerCaptureKey(param1:String, param2:Bool = false, param3:Bool = false, param4:Bool = false) 
      {
         if(_console != null)
         {
            _console.setRollerCaptureKey(param1,param4,param2,param3);
         }
      }
      
            
      @:isVar public static var remoting(get,set):Bool;
static public function  get_remoting() : Bool
      {
         if(_console != null)
         {
            return _console.remoting;
         }
         return false;
      }
static function  set_remoting(param1:Bool) :Bool      {
         if(_console != null)
         {
            _console.remoting = param1;
         }
return param1;
      }
      
      public static function remotingSocket(param1:String, param2:Int) 
      {
         if(_console != null)
         {
            _console.remotingSocket(param1,param2);
         }
      }
      
      public static function remove() 
      {
         if(_console != null)
         {
            if(_console.parent != null)
            {
               _console.parent.removeChild(_console);
            }
            _console = null;
         }
      }
      
      public static function getAllLog(param1:String = "\r\n") : String
      {
         if(_console != null)
         {
            return _console.getAllLog(param1);
         }
         return "";
      }
      
      @:isVar public static var instance(get,never):Console;
static public function  get_instance() : Console
      {
         return _console;
      }
      
      static function addedToStageHandle(param1:Event) 
      {
         var _loc2_= ASCompat.dynamicAs(param1.currentTarget , DisplayObjectContainer);
         _loc2_.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandle);
         if(ASCompat.toBool(_console) && _console.parent == null)
         {
            _loc2_.stage.addChild(_console);
         }
      }
   }


