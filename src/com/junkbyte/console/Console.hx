package com.junkbyte.console
;
   import com.junkbyte.console.core.CommandLine;
   import com.junkbyte.console.core.ConsoleTools;
   import com.junkbyte.console.core.Graphing;
   import com.junkbyte.console.core.KeyBinder;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.core.Logs;
   import com.junkbyte.console.core.MemoryMonitor;
   import com.junkbyte.console.core.Remoting;
   import com.junkbyte.console.view.PanelsManager;
   import com.junkbyte.console.view.RollerPanel;
   import com.junkbyte.console.vos.Log;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import flash.net.SharedObject;
   import flash.system.Capabilities;
   
    class Console extends Sprite
   {
      
      public static inline final VERSION:Float = 2.6;
      
      public static inline final VERSION_STAGE= "";
      
      public static inline final BUILD= 611;
      
      public static inline final BUILD_DATE= "2012/02/22 00:11";
      
      public static inline final LOG= (1 : UInt);
      
      public static inline final INFO= (3 : UInt);
      
      public static inline final DEBUG= (6 : UInt);
      
      public static inline final WARN= (8 : UInt);
      
      public static inline final ERROR_cpp/*cpp macro conflict*/= (9 : UInt);
      
      public static inline final FATAL= (10 : UInt);
      
      public static inline final GLOBAL_CHANNEL= " * ";
      
      public static inline final DEFAULT_CHANNEL= "-";
      
      public static inline final CONSOLE_CHANNEL= "C";
      
      public static inline final FILTER_CHANNEL= "~";
      
      var _config:ConsoleConfig;
      
      var _panels:PanelsManager;
      
      var _cl:CommandLine;
      
      var _kb:KeyBinder;
      
      var _refs:LogReferences;
      
      var _mm:MemoryMonitor;
      
      var _graphing:Graphing;
      
      var _remoter:Remoting;
      
      var _tools:ConsoleTools;
      
      var _topTries:Int = 50;
      
      var _paused:Bool = false;
      
      var _rollerKey:KeyBind;
      
      var _logs:Logs;
      
      var _so:SharedObject;
      
      var _soData:ASObject;
      
      public function new(param1:String = "", param2:ConsoleConfig = null)
      {
         var password= param1;
         var config= param2;
         this._soData = {};
         super();
         name = "Console";
         if(config == null)
         {
            config = new ConsoleConfig();
         }
         this._config = config;
         if(ASCompat.stringAsBool(password))
         {
            this._config.keystrokePassword = password;
         }
         this._remoter = new Remoting(this);
         this._logs = new Logs(this);
         this._refs = new LogReferences(this);
         this._cl = new CommandLine(this);
         this._tools = new ConsoleTools(this);
         this._graphing = new Graphing(this);
         this._mm = new MemoryMonitor(this);
         this._kb = new KeyBinder(this);
         this.cl.addCLCmd("remotingSocket",function(param1:String = "")
         {
            var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+|\\:").split(param1));
            remotingSocket(_loc2_[0],ASCompat.toInt(_loc2_[1]));
         },"Connect to socket remote. /remotingSocket ip port");
         if(ASCompat.stringAsBool(this._config.sharedObjectName))
         {
            try
            {
               this._so = SharedObject.getLocal(this._config.sharedObjectName,this._config.sharedObjectPath);
               this._soData = this._so.data;
            }
            catch(e:Dynamic)
            {
            }
         }
         this._config.style.updateStyleSheet();
         this._panels = new PanelsManager(this);
         if(ASCompat.stringAsBool(password))
         {
            this.visible = false;
         }
         this.report("<b>Console v" + VERSION + VERSION_STAGE + "</b> build " + BUILD + ". " + Capabilities.playerType + " " + Capabilities.version + ".",-2);
         addEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         addEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle);
      }
      
      public static function MakeChannelName(param1:ASAny) : String
      {
         if(Std.isOfType(param1 , String))
         {
            return ASCompat.asString(param1 );
         }
         if(ASCompat.toBool(param1))
         {
            return LogReferences.ShortClassName(param1);
         }
         return DEFAULT_CHANNEL;
      }
      
      function stageAddedHandle(param1:Event = null) 
      {
         if(this._cl.base == null)
         {
            this._cl.base = parent;
         }
         if(loaderInfo != null)
         {
            this.listenUncaughtErrors(loaderInfo);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle);
         addEventListener(Event.REMOVED_FROM_STAGE,this.stageRemovedHandle);
         stage.addEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this._kb.keyDownHandler,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_UP,this._kb.keyUpHandler,false,0,true);
      }
      
      function stageRemovedHandle(param1:Event = null) 
      {
         this._cl.base = null;
         removeEventListener(Event.REMOVED_FROM_STAGE,this.stageRemovedHandle);
         addEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle);
         stage.removeEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this._kb.keyDownHandler);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this._kb.keyUpHandler);
      }
      
      function onStageMouseLeave(param1:Event) 
      {
         this._panels.tooltip(null);
      }
      
      public function listenUncaughtErrors(param1:LoaderInfo) 
      {
         var uncaughtErrorEvents:IEventDispatcher = null;
         var loaderinfo= param1;
         try
         {
            uncaughtErrorEvents = ASCompat.dynamicAs((loaderinfo : ASAny)["uncaughtErrorEvents"], flash.events.IEventDispatcher);
            if(uncaughtErrorEvents != null)
            {
               uncaughtErrorEvents.addEventListener("uncaughtError",this.uncaughtErrorHandle,false,0,true);
            }
         }
         catch(err:Dynamic)
         {
         }
      }
      
      function uncaughtErrorHandle(param1:Event) 
      {
         var _loc3_:String = null;
         var _loc2_:ASAny = (param1 : ASAny).hasOwnProperty("error") ? (param1 : ASAny)["error"] : param1;
         if(Std.isOfType(_loc2_ , Error))
         {
            _loc3_ = this._refs.makeString(_loc2_);
         }
         else if(Std.isOfType(_loc2_ , ErrorEvent))
         {
            _loc3_ = cast(_loc2_, ErrorEvent).text;
         }
         if(!ASCompat.stringAsBool(_loc3_))
         {
            _loc3_ = ASCompat.toString(_loc2_);
         }
         this.report(_loc3_,(FATAL : Int),false);
      }
      
      public function addGraph(param1:String, param2:ASObject, param3:String, param4:Float = -1, param5:String = null, param6:Rectangle = null, param7:Bool = false) 
      {
         this._graphing.add(param1,param2,param3,param4,param5,param6,param7);
      }
      
      public function fixGraphRange(param1:String, param2:Float = null, param3:Float = null) 
{
         if (param2 == null) param2 = Math.NaN;
         if (param3 == null) param3 = Math.NaN;
         this._graphing.fixRange(param1,param2,param3);
      }
      
      public function removeGraph(param1:String, param2:ASObject = null, param3:String = null) 
      {
         this._graphing.remove(param1,param2,param3);
      }
      
      public function bindKey(param1:KeyBind, param2:ASFunction, param3:Array<ASAny> = null) 
      {
         if(param1 != null)
         {
            this._kb.bindKey(param1,param2,param3);
         }
      }
      
      public function addMenu(param1:String, param2:ASFunction, param3:Array<ASAny> = null, param4:String = null) 
      {
         this.panels.mainPanel.addMenu(param1,param2,param3,param4);
      }
      
            
      @:isVar public var displayRoller(get,set):Bool;
public function  get_displayRoller() : Bool
      {
         return this._panels.displayRoller;
      }
function  set_displayRoller(param1:Bool) :Bool      {
         return this._panels.displayRoller = param1;
      }
      
      public function setRollerCaptureKey(param1:String, param2:Bool = false, param3:Bool = false, param4:Bool = false) 
      {
         if(this._rollerKey != null)
         {
            this.bindKey(this._rollerKey,null);
            this._rollerKey = null;
         }
         if(ASCompat.toBool(param1) && param1.length == 1)
         {
            this._rollerKey = new KeyBind(param1,param2,param3,param4);
            this.bindKey(this._rollerKey,this.onRollerCaptureKey);
         }
      }
      
      @:isVar public var rollerCaptureKey(get,never):KeyBind;
public function  get_rollerCaptureKey() : KeyBind
      {
         return this._rollerKey;
      }
      
      function onRollerCaptureKey() 
      {
         if(this.displayRoller)
         {
            this.report("Display Roller Capture:<br/>" + cast(this._panels.getPanel(RollerPanel.NAME), RollerPanel).getMapString(true),-1);
         }
      }
      
            
      @:isVar public var fpsMonitor(get,set):Bool;
public function  get_fpsMonitor() : Bool
      {
         return this._graphing.fpsMonitor;
      }
function  set_fpsMonitor(param1:Bool) :Bool      {
         return this._graphing.fpsMonitor = param1;
      }
      
            
      @:isVar public var memoryMonitor(get,set):Bool;
public function  get_memoryMonitor() : Bool
      {
         return this._graphing.memoryMonitor;
      }
function  set_memoryMonitor(param1:Bool) :Bool      {
         return this._graphing.memoryMonitor = param1;
      }
      
      public function watch(param1:ASObject, param2:String = null) : String
      {
         return this._mm.watch(param1,param2);
      }
      
      public function unwatch(param1:String) 
      {
         this._mm.unwatch(param1);
      }
      
      public function gc() 
      {
         this._mm.gc();
      }
      
      public function store(param1:String, param2:ASObject, param3:Bool = false) 
      {
         this._cl.store(param1,param2,param3);
      }
      
      public function map(param1:DisplayObjectContainer, param2:UInt = (0 : UInt)) 
      {
         this._tools.map(param1,param2,DEFAULT_CHANNEL);
      }
      
      public function mapch(param1:ASAny, param2:DisplayObjectContainer, param3:UInt = (0 : UInt)) 
      {
         this._tools.map(param2,param3,MakeChannelName(param1));
      }
      
      public function inspect(param1:ASObject, param2:Bool = true) 
      {
         this._refs.inspect(param1,param2,DEFAULT_CHANNEL);
      }
      
      public function inspectch(param1:ASAny, param2:ASObject, param3:Bool = true) 
      {
         this._refs.inspect(param2,param3,MakeChannelName(param1));
      }
      
      public function explode(param1:ASObject, param2:Int = 3) 
      {
         this.addLine([this._tools.explode(param1,param2)],1,null,false,true);
      }
      
      public function explodech(param1:ASAny, param2:ASObject, param3:Int = 3) 
      {
         this.addLine([this._tools.explode(param2,param3)],1,param1,false,true);
      }
      
            
      @:isVar public var paused(get,set):Bool;
public function  get_paused() : Bool
      {
         return this._paused;
      }
function  set_paused(param1:Bool) :Bool      {
         if(this._paused == param1)
         {
            return param1;
         }
         if(param1)
         {
            this.report("Paused",10);
         }
         else
         {
            this.report("Resumed",-1);
         }
         this._paused = param1;
         this._panels.mainPanel.setPaused(param1);
return param1;
      }
      
      override public function  get_width() : Float
      {
         return this._panels.mainPanel.width;
      }
      
      override public function  set_width(param1:Float)       {
         return this._panels.mainPanel.width = param1;
      }
      
      override public function  set_height(param1:Float)       {
         return this._panels.mainPanel.height = param1;
      }
      
      override public function  get_height() : Float
      {
         return this._panels.mainPanel.height;
      }
      
      override public function  get_x() : Float
      {
         return this._panels.mainPanel.x;
      }
      
      override public function  set_x(param1:Float)       {
         return this._panels.mainPanel.x = param1;
      }
      
      override public function  set_y(param1:Float)       {
         return this._panels.mainPanel.y = param1;
      }
      
      override public function  get_y() : Float
      {
         return this._panels.mainPanel.y;
      }
      
      override public function  set_visible(param1:Bool)       {
         super.visible = param1;
         if(param1)
         {
            this._panels.mainPanel.visible = true;
         }
return param1;
      }
      
      function _onEnterFrame(param1:Event) 
      {
         var _loc4_:Array<ASAny> = null;
         var _loc2_= flash.Lib.getTimer();
         var _loc3_= this._logs.update((_loc2_ : UInt));
         this._refs.update((_loc2_ : UInt));
         this._mm.update();
         if(this.remoter.remoting != Remoting.RECIEVER)
         {
            _loc4_ = this._graphing.update(stage != null ? stage.frameRate : 0);
         }
         this._remoter.update();
         if(visible && ASCompat.toBool(parent))
         {
            if(this.config.alwaysOnTop && parent.getChildAt(parent.numChildren - 1) != this && this._topTries > 0)
            {
               --this._topTries;
               parent.addChild(this);
               this.report("Moved console on top (alwaysOnTop enabled), " + this._topTries + " attempts left.",-1);
            }
            this._panels.update(this._paused,_loc3_);
            if(_loc4_ != null)
            {
               this._panels.updateGraphs(_loc4_);
            }
         }
      }
      
            
      @:isVar public var remoting(get,set):Bool;
public function  get_remoting() : Bool
      {
         return this._remoter.remoting == Remoting.SENDER;
      }
function  set_remoting(param1:Bool) :Bool      {
         this._remoter.remoting = param1 ? Remoting.SENDER : Remoting.NONE;
return param1;
      }
      
      public function remotingSocket(param1:String, param2:Int) 
      {
         this._remoter.remotingSocket(param1,param2);
      }
      
      public function setViewingChannels(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         Reflect.callMethod(this,this._panels.mainPanel.setViewingChannels, rest);
      }
      
      public function setIgnoredChannels(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         Reflect.callMethod(this,this._panels.mainPanel.setIgnoredChannels, rest);
      }
      
      @:isVar public var minimumPriority(never,set):UInt;
public function  set_minimumPriority(param1:UInt) :UInt      {
         return this._panels.mainPanel.priority = param1;
      }
      
      public function report(param1:ASAny, param2:Int = 0, param3:Bool = true, param4:String = null) 
      {
         if(!ASCompat.stringAsBool(param4))
         {
            param4 = this._panels.mainPanel.reportChannel;
         }
         this.addLine([param1],param2,param4,false,param3,0);
      }
      
      public function addLine(param1:Array<ASAny>, param2:Int = 0, param3:ASAny = null, param4:Bool = false, param5:Bool = false, param6:Int = -1) 
      {
         var _loc7_= "";
         var _loc8_= param1.length;
         var _loc9_= 0;
         while(_loc9_ < _loc8_)
         {
            _loc7_ += (_loc9_ != 0 ? " " : "") + this._refs.makeString(param1[_loc9_],null,param5);
            _loc9_++;
         }
         if(param2 >= this._config.autoStackPriority && param6 < 0)
         {
            param6 = this._config.defaultStackDepth;
         }
         if(!param5 && param6 > 0)
         {
            _loc7_ += this._tools.getStack(param6,param2);
         }
         this._logs.add(new Log(_loc7_,MakeChannelName(param3),param2,param4,param5));
      }
      
            
      @:isVar public var commandLine(get,set):Bool;
public function  set_commandLine(param1:Bool) :Bool      {
         return this._panels.mainPanel.commandLine = param1;
      }
function  get_commandLine() : Bool
      {
         return this._panels.mainPanel.commandLine;
      }
      
      public function addSlashCommand(param1:String, param2:ASFunction, param3:String = "", param4:Bool = true, param5:String = ";") 
      {
         this._cl.addSlashCommand(param1,param2,param3,param4,param5);
      }
      
      public function add(param1:ASAny, param2:Int = 2, param3:Bool = false) 
      {
         this.addLine([param1],param2,DEFAULT_CHANNEL,param3);
      }
      
      public function stack(param1:ASAny, param2:Int = -1, param3:Int = 5) 
      {
         this.addLine([param1],param3,DEFAULT_CHANNEL,false,false,param2 >= 0 ? param2 : this._config.defaultStackDepth);
      }
      
      public function stackch(param1:ASAny, param2:ASAny, param3:Int = -1, param4:Int = 5) 
      {
         this.addLine([param2],param4,param1,false,false,param3 >= 0 ? param3 : this._config.defaultStackDepth);
      }
      
      public function log(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(LOG : Int));
      }
      
      public function info(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(INFO : Int));
      }
      
      public function debug(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(DEBUG : Int));
      }
      
      public function warn(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(WARN : Int));
      }
      
      public function error(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(ERROR_cpp : Int));
      }
      
      public function fatal(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(FATAL : Int));
      }
      
      public function ch(param1:ASAny, param2:ASAny, param3:Int = 2, param4:Bool = false) 
      {
         this.addLine([param2],param3,param1,param4);
      }
      
      public function logch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(LOG : Int),param1);
      }
      
      public function infoch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(INFO : Int),param1);
      }
      
      public function debugch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(DEBUG : Int),param1);
      }
      
      public function warnch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(WARN : Int),param1);
      }
      
      public function errorch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(ERROR_cpp : Int),param1);
      }
      
      public function fatalch(param1:ASAny, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,(FATAL : Int),param1);
      }
      
      public function addCh(param1:ASAny, param2:Array<ASAny>, param3:Int = 2, param4:Bool = false) 
      {
         this.addLine(param2,param3,param1,param4);
      }
      
      public function addHTML(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,2,DEFAULT_CHANNEL,false,this.testHTML(rest));
      }
      
      public function addHTMLch(param1:ASAny, param2:Int, ..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.addLine(rest,param2,param1,false,this.testHTML(rest));
      }
      
      function testHTML(param1:Array<ASAny>) : Bool
      {
         var args= param1;
         try
         {
            new compat.XML("<p>" + args.join("") + "</p>");
         }
         catch(err:Dynamic)
         {
            return false;
         }
         return true;
      }
      
      public function clear(param1:String = null) 
      {
         this._logs.clear(param1);
         if(!this._paused)
         {
            this._panels.mainPanel.updateToBottom();
         }
         this._panels.updateMenu();
      }
      
      public function getAllLog(param1:String = "\r\n") : String
      {
         return this._logs.getLogsAsString(param1);
      }
      
      @:isVar public var config(get,never):ConsoleConfig;
public function  get_config() : ConsoleConfig
      {
         return this._config;
      }
      
      @:isVar public var panels(get,never):PanelsManager;
public function  get_panels() : PanelsManager
      {
         return this._panels;
      }
      
      @:isVar public var cl(get,never):CommandLine;
public function  get_cl() : CommandLine
      {
         return this._cl;
      }
      
      @:isVar public var remoter(get,never):Remoting;
public function  get_remoter() : Remoting
      {
         return this._remoter;
      }
      
      @:isVar public var graphing(get,never):Graphing;
public function  get_graphing() : Graphing
      {
         return this._graphing;
      }
      
      @:isVar public var refs(get,never):LogReferences;
public function  get_refs() : LogReferences
      {
         return this._refs;
      }
      
      @:isVar public var logs(get,never):Logs;
public function  get_logs() : Logs
      {
         return this._logs;
      }
      
      @:isVar public var mapper(get,never):ConsoleTools;
public function  get_mapper() : ConsoleTools
      {
         return this._tools;
      }
      
      @:isVar public var so(get,never):ASObject;
public function  get_so() : ASObject
      {
         return this._soData;
      }
      
      public function updateSO(param1:String = null) 
      {
         if(this._so != null)
         {
            if(ASCompat.stringAsBool(param1))
            {
               this._so.setDirty(param1);
            }
            else
            {
               this._so.clear();
            }
         }
      }
   }


