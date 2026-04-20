package com.junkbyte.console.core
;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.WeakObject;
   import com.junkbyte.console.vos.WeakRef;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.utils.ByteArray;
   
    class CommandLine extends ConsoleCore
   {
      
      static inline final DISABLED= "<b>Advanced CommandLine is disabled.</b>\nEnable by setting `Cc.config.commandLineAllowed = true;´\nType <b>/commands</b> for permitted commands.";
      
      static final RESERVED:Array<ASAny> = [Executer.RETURNED,"base","C"];
      
      var _saved:WeakObject;
      
      var _scope:ASAny;
      
      var _prevScope:WeakRef;
      
      var _scopeStr:String = "";
      
      var _slashCmds:ASObject;
      
      public var localCommands:Array<ASAny>;
      
      public function new(param1:Console)
      {
         var m= param1;
         this.localCommands = ["filter","filterexp"];
         super(m);
         this._saved = new WeakObject();
         this._scope = m;
         this._slashCmds = new ASObject();
         this._prevScope = new WeakRef(m);
         this._saved.set("C",m);
         remoter.registerCallback("cmd",function(param1:ByteArray)
         {
            run(param1.readUTF());
         });
         remoter.registerCallback("scope",function(param1:ByteArray)
         {
            handleScopeEvent(param1.readUnsignedInt());
         });
         remoter.registerCallback("cls",this.handleScopeString);
         remoter.addEventListener(Event.CONNECT,this.sendCmdScope2Remote);
         this.addCLCmd("help",this.printHelp,"How to use command line");
         this.addCLCmd("save|store",this.saveCmd,"Save current scope as weak reference. (same as Cc.store(...))");
         this.addCLCmd("savestrong|storestrong",this.saveStrongCmd,"Save current scope as strong reference");
         this.addCLCmd("saved|stored",this.savedCmd,"Show a list of all saved references");
         this.addCLCmd("string",this.stringCmd,"Create String, useful to paste complex strings without worrying about \" or \'",false,null);
         this.addCLCmd("commands",this.cmdsCmd,"Show a list of all slash commands",true);
         this.addCLCmd("inspect",this.inspectCmd,"Inspect current scope");
         this.addCLCmd("explode",this.explodeCmd,"Explode current scope to its properties and values (similar to JSON)");
         this.addCLCmd("map",this.mapCmd,"Get display list map starting from current scope");
         this.addCLCmd("function",this.funCmd,"Create function. param is the commandline string to create as function. (experimental)");
         this.addCLCmd("autoscope",this.autoscopeCmd,"Toggle autoscoping.");
         this.addCLCmd("base",this.baseCmd,"Return to base scope");
         this.addCLCmd("/",this.prevCmd,"Return to previous scope");
      }
      
            
      @:isVar public var base(get,set):ASObject;
public function  set_base(param1:ASObject) :ASObject      {
         if(ASCompat.toBool(this.base))
         {
            report("Set new commandLine base from " + Std.string(this.base) + " to " + Std.string(param1),10);
         }
         else
         {
            this._prevScope.reference = this._scope;
            this._scope = param1;
            this._scopeStr = LogReferences.ShortClassName(param1,false);
         }
         this._saved.set("base",param1);
return param1;
      }
function  get_base() : ASObject
      {
         return this._saved.get("base");
      }
      
      public function handleScopeString(param1:ByteArray) 
      {
         this._scopeStr = param1.readUTF();
      }
      
      public function handleScopeEvent(param1:UInt) 
      {
         var _loc2_:ByteArray = null;
         var _loc3_:ASAny = /*undefined*/null;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeUnsignedInt(param1);
            remoter.send("scope",_loc2_);
         }
         else
         {
            _loc3_ = console.refs.getRefById(param1);
            if(ASCompat.toBool(_loc3_))
            {
               console.cl.setReturned(_loc3_,true,false);
            }
            else
            {
               console.report("Reference no longer exist.",-2);
            }
         }
      }
      
      public function store(param1:String, param2:ASObject, param3:Bool = false) 
      {
         if(!ASCompat.stringAsBool(param1))
         {
            report("ERROR: Give a name to save.",10);
            return;
         }
         if(Reflect.isFunction(param2 ))
         {
            param3 = true;
         }
         param1 = new compat.RegExp("[^\\w]*", "g").replace(param1,"");
         if(RESERVED.indexOf(param1) >= 0)
         {
            report("ERROR: The name [" + param1 + "] is reserved",10);
            return;
         }
         this._saved.set(param1,param2,param3);
      }
      
      public function getHintsFor(param1:String, param2:UInt) : Array<ASAny>
      {
         var __ax4_iter_110:WeakObject;
         var hints:Array<ASAny>;
         var X:String = null;
         var canadate:Array<ASAny> = null;
         var cmd:ASObject = null;
         var Y:String = null;
         var str= param1;
         var max= param2;
         var all= new Array<ASAny>();
         final __ax4_iter_109:ASObject = this._slashCmds;
         if (checkNullIteratee(__ax4_iter_109)) for(_tmp_ in __ax4_iter_109.___keys())
         {
            X  = _tmp_;
            cmd = this._slashCmds[X];
            if(config.commandLineAllowed || ASCompat.toBool(cmd.allow))
            {
               all.push((["/" + X + " ",ASCompat.toBool(cmd.d) ? cmd.d : null] : Array<ASAny>));
            }
         }
         if(config.commandLineAllowed)
         {
            __ax4_iter_110 = this._saved;
            if (checkNullIteratee(__ax4_iter_110)) for(_tmp_ in (__ax4_iter_110 : ASAny).___keys())
            {
               Y  = _tmp_;
               all.push(["$" + Y,LogReferences.ShortClassName(this._saved.get(Y))]);
            }
            if(ASCompat.toBool(this._scope))
            {
               all.push(["this",LogReferences.ShortClassName(this._scope)]);
               all = all.concat(console.refs.getPossibleCalls(this._scope));
            }
         }
         str = str.toLowerCase();
         hints = new Array<ASAny>();
         if (checkNullIteratee(all)) for (_tmp_ in all)
         {
            canadate  = ASCompat.dynamicAs(_tmp_, Array);
            if(ASCompat.toNumber(Std.string(canadate[0]).toLowerCase().indexOf(str)) == 0)
            {
               hints.push(canadate);
            }
         }
         hints = ASCompat.ASArray.sort(hints, function(param1:Array<ASAny>, param2:Array<ASAny>):Int
         {
            if(param1[0].length < param2[0].length)
            {
               return -1;
            }
            if(param1[0].length > param2[0].length)
            {
               return 1;
            }
            return 0;
         });
         if(max > 0 && (hints.length : UInt) > max)
         {
            ASCompat.arraySpliceAll(hints, (max : Int));
            hints.push(["..."]);
         }
         return hints;
      }
      
      @:isVar public var scopeString(get,never):String;
public function  get_scopeString() : String
      {
         return config.commandLineAllowed ? this._scopeStr : "";
      }
      
      public function addCLCmd(param1:String, param2:ASFunction, param3:String, param4:Bool = false, param5:String = ";") 
      {
         var _loc6_:Array<ASAny> = (cast param1.split("|"));
         var _loc7_= 0;
         while(_loc7_ < _loc6_.length)
         {
            param1 = _loc6_[_loc7_];
            this._slashCmds[param1] = new SlashCommand(param1,param2,param3,false,param4,param5);
            if(_loc7_ > 0)
            {
            }
            _loc7_++;
         }
      }
      
      public function addSlashCommand(param1:String, param2:ASFunction, param3:String = "", param4:Bool = true, param5:String = ";") 
      {
         var _loc6_:SlashCommand = null;
         param1 = new compat.RegExp("[^\\w]*", "g").replace(param1,"");
         if(this._slashCmds[param1] != null)
         {
            _loc6_ = ASCompat.dynamicAs(this._slashCmds[param1], SlashCommand);
            if(!_loc6_.user)
            {
               throw new Error("Can not alter build-in slash command [" + param1 + "]");
            }
         }
         if(param2 == null)
         {
            ASCompat.deleteProperty(this._slashCmds, param1);
         }
         else
         {
            this._slashCmds[param1] = new SlashCommand(param1,param2,LogReferences.EscHTML(param3),true,param4,param5);
         }
      }
      
      public function run(param1:String, param2:ASObject = null) : ASAny
      {
         var __ax4_iter_111:WeakObject;
         var v:ASAny;
         var bytes:ByteArray = null;
         var exe:Executer = null;
         var X:String = null;
         var str= param1;
         var saves:ASObject = param2;
         if(!ASCompat.stringAsBool(str))
         {
            return null;
         }
         str = new compat.RegExp("\\s*").replace(str,"");
         if(remoter.remoting == Remoting.RECIEVER)
         {
            if(str.charAt(0) == "~")
            {
               str = str.substring(1);
            }
            else if(new compat.RegExp("/" + this.localCommands.join("|/")).search(str) != 0)
            {
               report("Run command at remote: " + str,-2);
               bytes = new ByteArray();
               bytes.writeUTF(str);
               if(!console.remoter.send("cmd",bytes))
               {
                  report("Command could not be sent to client.",10);
               }
               return null;
            }
         }
         report("&gt; " + str,4,false);
         v = null;
         try
         {
            if(str.charAt(0) == "/")
            {
               this.execCommand(str.substring(1));
            }
            else
            {
               if(!config.commandLineAllowed)
               {
                  report(DISABLED,9);
                  return null;
               }
               exe = new Executer();
               exe.addEventListener(Event.COMPLETE,this.onExecLineComplete,false,0,true);
               if(ASCompat.toBool(saves))
               {
                  __ax4_iter_111 = this._saved;
                  if (checkNullIteratee(__ax4_iter_111)) for(_tmp_ in (__ax4_iter_111 : ASAny).___keys())
                  {
                     X  = _tmp_;
                     if(!ASCompat.toBool(saves[X]))
                     {
                        saves[X] = (this._saved : ASAny)[X];
                     }
                  }
               }
               else
               {
                  saves = this._saved;
               }
               exe.setStored(saves);
               exe.setReserved(RESERVED);
               exe.autoScope = config.commandLineAutoScope;
               v = exe.exec(this._scope,str);
            }
         }
         catch(e:Dynamic)
         {
            reportError(e);
         }
         return v;
      }
      
      function onExecLineComplete(param1:Event) 
      {
         var _loc2_= ASCompat.dynamicAs(param1.currentTarget , Executer);
         if(this._scope == _loc2_.scope)
         {
            this.setReturned(_loc2_.returned);
         }
         else if(_loc2_.scope == _loc2_.returned)
         {
            this.setReturned(_loc2_.scope,true);
         }
         else
         {
            this.setReturned(_loc2_.returned);
            this.setReturned(_loc2_.scope,true);
         }
      }
      
      function execCommand(param1:String) 
      {
         var param:String;
         var slashcmd:SlashCommand = null;
         var restStr:String = null;
         var endInd= 0;
         var str= param1;
         var brk= new compat.RegExp("[^\\w]").search(str);
         var cmd= str.substring(0,brk > 0 ? brk : str.length);
         if(cmd == "")
         {
            this.setReturned(this._saved.get(Executer.RETURNED),true);
            return;
         }
         param = brk > 0 ? str.substring(brk + 1) : "";
         if(this._slashCmds[cmd] != null)
         {
            try
            {
               slashcmd = ASCompat.dynamicAs(this._slashCmds[cmd], SlashCommand);
               if(!config.commandLineAllowed && !slashcmd.allow)
               {
                  report(DISABLED,9);
                  return;
               }
               if(ASCompat.stringAsBool(slashcmd.endMarker))
               {
                  endInd = param.indexOf(slashcmd.endMarker);
                  if(endInd >= 0)
                  {
                     restStr = param.substring(endInd + slashcmd.endMarker.length);
                     param = param.substring(0,endInd);
                  }
               }
               if(param.length == 0)
               {
                  slashcmd.f();
               }
               else
               {
                  slashcmd.f(param);
               }
               if(ASCompat.stringAsBool(restStr))
               {
                  this.run(restStr);
               }
            }
            catch(err:Dynamic)
            {
               reportError(err);
            }
         }
         else
         {
            report("Undefined command <b>/commands</b> for list of all commands.",10);
         }
      }
      
      public function setReturned(param1:ASAny, param2:Bool = false, param3:Bool = true) 
      {
         if(!config.commandLineAllowed)
         {
            report(DISABLED,9);
            return;
         }
         if(param1 != /*undefined*/null)
         {
            this._saved.set(Executer.RETURNED,param1,true);
            if(param2 && param1 != this._scope)
            {
               this._prevScope.reference = this._scope;
               this._scope = param1;
               if(remoter.remoting != Remoting.RECIEVER)
               {
                  this._scopeStr = LogReferences.ShortClassName(this._scope,false);
                  this.sendCmdScope2Remote();
               }
               report("Changed to " + console.refs.makeRefTyped(param1),-1);
            }
            else if(param3)
            {
               report("Returned " + console.refs.makeString(param1),-1);
            }
         }
         else if(param3)
         {
            report("Exec successful, undefined return.",-1);
         }
      }
      
      public function sendCmdScope2Remote(param1:Event = null) 
      {
         var _loc2_= new ByteArray();
         _loc2_.writeUTF(this._scopeStr);
         console.remoter.send("cls",_loc2_);
      }
      
      function reportError(param1:Error) 
      {
         var _loc10_:String = null;
         var _loc2_= console.refs.makeString(param1);
         var _loc3_:Array<ASAny> = (cast new compat.RegExp("\\n\\s*").split(_loc2_));
         var _loc4_= 10;
         var _loc5_= 0;
         var _loc6_= _loc3_.length;
         var _loc7_:Array<ASAny> = [];
         var _loc8_= new compat.RegExp("\\s*at\\s+(" + Executer.CLASSES + "|" + ASCompat.getQualifiedClassName(this) + ")");
         var _loc9_= 0;
         while(_loc9_ < _loc6_)
         {
            _loc10_ = _loc3_[_loc9_];
            if(_loc8_.search(_loc10_) == 0)
            {
               if(_loc5_ > 0 && _loc9_ > 0)
               {
                  break;
               }
               _loc5_++;
            }
            _loc7_.push("<p" + _loc4_ + "> " + _loc10_ + "</p" + _loc4_ + ">");
            if(_loc4_ > 6)
            {
               _loc4_--;
            }
            _loc9_++;
         }
         report(_loc7_.join("\n"),9);
      }
      
      function saveCmd(param1:String = null) 
      {
         this.store(param1,this._scope,false);
      }
      
      function saveStrongCmd(param1:String = null) 
      {
         this.store(param1,this._scope,true);
      }
      
      function savedCmd(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         var _loc4_:String = null;
         var _loc5_:WeakRef = null;
         report("Saved vars: ",-1);
         var _loc2_= (0 : UInt);
         var _loc3_= (0 : UInt);
         final __ax4_iter_112 = this._saved;
         if (checkNullIteratee(__ax4_iter_112)) for(_tmp_ in (__ax4_iter_112 : ASAny).___keys())
         {
            _loc4_  = _tmp_;
            _loc5_ = this._saved.getWeakRef(_loc4_);
            _loc2_++;
            if(_loc5_.reference == null)
            {
               _loc3_++;
            }
            report((_loc5_.strong ? "strong" : "weak") + " <b>$" + _loc4_ + "</b> = " + console.refs.makeString(_loc5_.reference),-2);
         }
         report("Found " + _loc2_ + " item(s), " + _loc3_ + " empty.",-1);
      }
      
      function stringCmd(param1:String) 
      {
         report("String with " + param1.length + " chars entered. Use /save <i>(name)</i> to save.",-2);
         this.setReturned(param1,true);
      }
      
      function cmdsCmd(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         var _loc4_:SlashCommand = null;
         var _loc2_:Array<ASAny> = [];
         var _loc3_:Array<ASAny> = [];
         final __ax4_iter_113:ASObject = this._slashCmds;
         if (checkNullIteratee(__ax4_iter_113)) for (_tmp_ in iterateDynamicValues(__ax4_iter_113))
         {
            _loc4_  = ASCompat.dynamicAs(_tmp_, SlashCommand);
            if(config.commandLineAllowed || _loc4_.allow)
            {
               if(_loc4_.user)
               {
                  _loc3_.push(_loc4_);
               }
               else
               {
                  _loc2_.push(_loc4_);
               }
            }
         }
         _loc2_ = ASCompat.ASArray.sortOn(_loc2_, "n", 0);
         report("Built-in commands:" + (!config.commandLineAllowed ? " (limited permission)" : ""),4);
         if (checkNullIteratee(_loc2_)) for (_tmp_ in _loc2_)
         {
            _loc4_  = ASCompat.dynamicAs(_tmp_, SlashCommand);
            report("<b>/" + _loc4_.n + "</b> <p-1>" + _loc4_.d + "</p-1>",-2);
         }
         if(_loc3_.length != 0)
         {
            _loc3_ = ASCompat.ASArray.sortOn(_loc3_, "n", 0);
            report("User commands:",4);
            if (checkNullIteratee(_loc3_)) for (_tmp_ in _loc3_)
            {
               _loc4_  = ASCompat.dynamicAs(_tmp_, SlashCommand);
               report("<b>/" + _loc4_.n + "</b> <p-1>" + _loc4_.d + "</p-1>",-2);
            }
         }
      }
      
      function inspectCmd(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         console.refs.focus(this._scope);
      }
      
      function explodeCmd(param1:String = "0") 
      {
         var _loc2_= ASCompat.toInt(param1);
         console.explodech(console.panels.mainPanel.reportChannel,this._scope,_loc2_ <= 0 ? 3 : _loc2_);
      }
      
      function mapCmd(param1:String = "0") 
      {
         console.mapch(console.panels.mainPanel.reportChannel,ASCompat.dynamicAs(this._scope , DisplayObjectContainer),(ASCompat.toInt(param1) : UInt));
      }
      
      function funCmd(param1:String = "") 
      {
         var _loc2_= new FakeFunction(this.run,param1);
         report("Function created. Use /savestrong <i>(name)</i> to save.",-2);
         this.setReturned(_loc2_.exec,true);
      }
      
      function autoscopeCmd(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         config.commandLineAutoScope = !config.commandLineAutoScope;
         report("Auto-scoping <b>" + (config.commandLineAutoScope ? "enabled" : "disabled") + "</b>.",10);
      }
      
      function baseCmd(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.setReturned(this.base,true);
      }
      
      function prevCmd(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this.setReturned(this._prevScope.reference,true);
      }
      
      function printHelp(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         report("____Command Line Help___",10);
         report("/filter (text) = filter/search logs for matching text",5);
         report("/commands to see all slash commands",5);
         report("Press up/down arrow keys to recall previous line",2);
         report("__Examples:",10);
         report("<b>stage.stageWidth</b>",5);
         report("<b>stage.scaleMode = flash.display.StageScaleMode.NO_SCALE</b>",5);
         report("<b>stage.frameRate = 12</b>",5);
         report("__________",10);
      }
   }


private class FakeFunction
{
   
   var line:String;
   
   var run:ASFunction;
   
   public function new(param1:ASFunction, param2:String)
   {
      
      this.run = param1;
      this.line = param2;
   }
   
   public function exec(..._rest:ASAny) : ASAny
   {
      var rest = ASCompat.restToArray(_rest);
      return this.run(this.line,rest);
   }
}

private class SlashCommand
{
   
   public var n:String;
   
   public var f:ASFunction;
   
   public var d:String;
   
   public var user:Bool = false;
   
   public var allow:Bool = false;
   
   public var endMarker:String;
   
   public function new(param1:String, param2:ASFunction, param3:String, param4:Bool, param5:Bool, param6:String)
   {
      
      this.n = param1;
      this.f = param2;
      this.d = ASCompat.stringAsBool(param3) ? param3 : "";
      this.user = param4;
      this.allow = param5;
      this.endMarker = param6;
   }
}
