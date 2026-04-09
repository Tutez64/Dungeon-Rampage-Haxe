package com.junkbyte.console.view
;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.core.Remoting;
   import com.junkbyte.console.vos.Log;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import flash.net.FileReference;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   
    class MainPanel extends ConsolePanel
   {
      
      public static inline final NAME= "mainPanel";
      
      static inline final CL_HISTORY= "clhistory";
      
      static inline final VIEWING_CH_HISTORY= "viewingChannels";
      
      static inline final IGNORED_CH_HISTORY= "ignoredChannels";
      
      static inline final PRIORITY_HISTORY= "priority";
      
      var _traceField:TextField;
      
      var _cmdPrefx:TextField;
      
      var _cmdField:TextField;
      
      var _hintField:TextField;
      
      var _cmdBG:Shape;
      
      var _bottomLine:Shape;
      
      var _mini:Bool = false;
      
      var _shift:Bool = false;
      
      var _ctrl:Bool = false;
      
      var _alt:Bool = false;
      
      var _scroll:Sprite;
      
      var _scroller:Sprite;
      
      var _scrolldelay:UInt = 0;
      
      var _scrolldir:Int = 0;
      
      var _scrolling:Bool = false;
      
      var _scrollHeight:Float = Math.NaN;
      
      var _selectionStart:Int = 0;
      
      var _selectionEnd:Int = 0;
      
      var _viewingChannels:Array<ASAny>;
      
      var _ignoredChannels:Array<ASAny>;
      
      var _extraMenus:ASObject = new ASObject();
      
      var _cmdsInd:Int = -1;
      
      var _priority:UInt = 0;
      
      var _filterText:String;
      
      var _filterRegExp:compat.RegExp;
      
      var _clScope:String = "";
      
      var _needUpdateMenu:Bool = false;
      
      var _needUpdateTrace:Bool = false;
      
      var _lockScrollUpdate:Bool = false;
      
      var _atBottom:Bool = true;
      
      var _enteringLogin:Bool = false;
      
      var _hint:String;
      
      var _cmdsHistory:Array<ASAny>;
      
      public function new(param1:Console)
      {
         super(param1);
         var _loc2_= style.menuFontSize;
         console.cl.addCLCmd("filter",this.setFilterText,"Filter console logs to matching string. When done, click on the * (global channel) at top.",true);
         console.cl.addCLCmd("filterexp",this.setFilterRegExp,"Filter console logs to matching regular expression",true);
         console.cl.addCLCmd("clearhistory",this.clearCommandLineHistory,"Clear history of commands you have entered.",true);
         name = NAME;
         minWidth = 50;
         minHeight = 18;
         this._traceField = makeTF("traceField");
         this._traceField.wordWrap = true;
         this._traceField.multiline = true;
         this._traceField.y = _loc2_;
         this._traceField.addEventListener(Event.SCROLL,this.onTraceScroll);
         addChild(this._traceField);
         txtField = makeTF("menuField");
         txtField.wordWrap = true;
         txtField.multiline = true;
         txtField.autoSize = TextFieldAutoSize.RIGHT;
         txtField.height = _loc2_ + 6;
         txtField.y = -2;
         registerTFRoller(txtField,this.onMenuRollOver);
         addChild(txtField);
         this._cmdBG = new Shape();
         this._cmdBG.name = "commandBackground";
         this._cmdBG.graphics.beginFill(style.commandLineColor,0.1);
         this._cmdBG.graphics.drawRoundRect(0,0,100,18,_loc2_,_loc2_);
         this._cmdBG.scale9Grid = new Rectangle(9,9,80,1);
         addChild(this._cmdBG);
         var _loc3_= new TextFormat(style.menuFont,style.menuFontSize,ASCompat.toInt(style.highColor));
         this._cmdField = new TextField();
         this._cmdField.name = "commandField";
         this._cmdField.type = TextFieldType.INPUT;
         this._cmdField.x = 40;
         this._cmdField.height = _loc2_ + 6;
         this._cmdField.addEventListener(KeyboardEvent.KEY_DOWN,this.commandKeyDown);
         this._cmdField.addEventListener(KeyboardEvent.KEY_UP,this.commandKeyUp);
         this._cmdField.addEventListener(FocusEvent.FOCUS_IN,this.updateCmdHint);
         this._cmdField.addEventListener(FocusEvent.FOCUS_OUT,this.onCmdFocusOut);
         this._cmdField.defaultTextFormat = _loc3_;
         addChild(this._cmdField);
         this._hintField = makeTF("hintField",true);
         this._hintField.mouseEnabled = false;
         this._hintField.x = this._cmdField.x;
         this._hintField.autoSize = TextFieldAutoSize.LEFT;
         addChild(this._hintField);
         this.setHints();
         _loc3_.color = style.commandLineColor;
         this._cmdPrefx = new TextField();
         this._cmdPrefx.name = "commandPrefx";
         this._cmdPrefx.type = TextFieldType.DYNAMIC;
         this._cmdPrefx.x = 2;
         this._cmdPrefx.height = _loc2_ + 6;
         this._cmdPrefx.selectable = false;
         this._cmdPrefx.defaultTextFormat = _loc3_;
         this._cmdPrefx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCmdPrefMouseDown);
         this._cmdPrefx.addEventListener(MouseEvent.MOUSE_MOVE,this.onCmdPrefRollOverOut);
         this._cmdPrefx.addEventListener(MouseEvent.ROLL_OUT,this.onCmdPrefRollOverOut);
         addChild(this._cmdPrefx);
         this._bottomLine = new Shape();
         this._bottomLine.name = "blinkLine";
         this._bottomLine.alpha = 0.2;
         addChild(this._bottomLine);
         this._scroll = new Sprite();
         this._scroll.name = "scroller";
         this._scroll.tabEnabled = false;
         this._scroll.y = _loc2_ + 4;
         this._scroll.buttonMode = true;
         this._scroll.addEventListener(MouseEvent.MOUSE_DOWN,this.onScrollbarDown,false,0,true);
         this._scroller = new Sprite();
         this._scroller.name = "scrollbar";
         this._scroller.tabEnabled = false;
         this._scroller.y = style.controlSize;
         this._scroller.graphics.beginFill(style.controlColor,1);
         this._scroller.graphics.drawRect(-style.controlSize,0,style.controlSize,30);
         this._scroller.graphics.beginFill((0 : UInt),0);
         this._scroller.graphics.drawRect(-style.controlSize * 2,0,style.controlSize * 2,30);
         this._scroller.graphics.endFill();
         this._scroller.addEventListener(MouseEvent.MOUSE_DOWN,this.onScrollerDown,false,0,true);
         this._scroll.addChild(this._scroller);
         addChild(this._scroll);
         this._cmdField.visible = false;
         this._cmdPrefx.visible = false;
         this._cmdBG.visible = false;
         this.updateCLScope("");
         init(640,100,true);
         registerDragger(txtField);
         if(Std.isOfType(console.so[CL_HISTORY] , Array))
         {
            this._cmdsHistory = ASCompat.dynamicAs(console.so[CL_HISTORY], Array);
         }
         else
         {
            console.so[CL_HISTORY] = this._cmdsHistory = new Array<ASAny>();
         }
         if(config.rememberFilterSettings && Std.isOfType(console.so[VIEWING_CH_HISTORY] , Array))
         {
            this._viewingChannels = ASCompat.dynamicAs(console.so[VIEWING_CH_HISTORY], Array);
         }
         else
         {
            console.so[VIEWING_CH_HISTORY] = this._viewingChannels = new Array<ASAny>();
         }
         if(config.rememberFilterSettings && Std.isOfType(console.so[IGNORED_CH_HISTORY] , Array))
         {
            this._ignoredChannels = ASCompat.dynamicAs(console.so[IGNORED_CH_HISTORY], Array);
         }
         if(this._viewingChannels.length > 0 || this._ignoredChannels == null)
         {
            console.so[IGNORED_CH_HISTORY] = this._ignoredChannels = new Array<ASAny>();
         }
         if(config.rememberFilterSettings && Std.isOfType(console.so[PRIORITY_HISTORY] , Int))
         {
            this._priority = (ASCompat.toInt(console.so[PRIORITY_HISTORY]) : UInt);
         }
         addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel,false,0,true);
         addEventListener(TextEvent.LINK,this.linkHandler,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.stageRemovedHandle,false,0,true);
      }
      
      public function addMenu(param1:String, param2:ASFunction, param3:Array<ASAny>, param4:String) 
      {
         if(ASCompat.stringAsBool(param1))
         {
            param1 = new compat.RegExp("[^\\w]*", "g").replace(param1,"");
            if(param2 == null)
            {
               ASCompat.deleteProperty(this._extraMenus, param1);
            }
            else
            {
               this._extraMenus[param1] = ([param2,param3,param4] : Array<ASAny>);
            }
            this._needUpdateMenu = true;
         }
         else
         {
            console.report("ERROR: Invalid add menu params.",9);
         }
      }
      
      function stageAddedHandle(param1:Event = null) 
      {
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown,true,0,true);
         stage.addEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,false,0,true);
      }
      
      function stageRemovedHandle(param1:Event = null) 
      {
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStageMouseDown,true);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpHandler);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
      }
      
      function onStageMouseDown(param1:MouseEvent) 
      {
         this._shift = param1.shiftKey;
         this._ctrl = param1.ctrlKey;
         this._alt = param1.altKey;
      }
      
      function onMouseWheel(param1:MouseEvent) 
      {
         var _loc2_= 0;
         if(this._shift)
         {
            _loc2_ = console.config.style.traceFontSize + (param1.delta > 0 ? 1 : -1);
            if(_loc2_ > 10 && _loc2_ < 20)
            {
               console.config.style.traceFontSize = _loc2_;
               console.config.style.updateStyleSheet();
               this.updateToBottom();
               param1.stopPropagation();
            }
         }
      }
      
      function onCmdPrefRollOverOut(param1:MouseEvent) 
      {
         console.panels.tooltip(param1.type == MouseEvent.MOUSE_MOVE ? "Current scope::(CommandLine)" : "",this);
      }
      
      function onCmdPrefMouseDown(param1:MouseEvent) 
      {
         var e= param1;
         try
         {
            stage.focus = this._cmdField;
            this.setCLSelectionAtEnd();
         }
         catch(err:Dynamic)
         {
         }
      }
      
      function keyDownHandler(param1:KeyboardEvent) 
      {
         if(param1.keyCode == Keyboard.SHIFT)
         {
            this._shift = true;
         }
         if(param1.keyCode == Keyboard.CONTROL)
         {
            this._ctrl = true;
         }
         if(param1.keyCode == 18)
         {
            this._alt = true;
         }
      }
      
      function keyUpHandler(param1:KeyboardEvent) 
      {
         var e= param1;
         if(e.keyCode == Keyboard.SHIFT)
         {
            this._shift = false;
         }
         else if(e.keyCode == Keyboard.CONTROL)
         {
            this._ctrl = false;
         }
         else if(e.keyCode == 18)
         {
            this._alt = false;
         }
         if((e.keyCode == Keyboard.TAB || e.keyCode == Keyboard.ENTER) && parent.visible && visible && this._cmdField.visible)
         {
            try
            {
               stage.focus = this._cmdField;
               this.setCLSelectionAtEnd();
            }
            catch(err:Dynamic)
            {
            }
         }
      }
      
      public function requestLogin(param1:Bool = true) 
      {
         var _loc2_= new ColorTransform();
         if(param1)
         {
            console.commandLine = true;
            console.report("//",-2);
            console.report("// <b>Enter remoting password</b> in CommandLine below...",-2);
            this.updateCLScope("Password");
            _loc2_.color = style.controlColor;
            this._cmdBG.transform.colorTransform = _loc2_;
            this._traceField.transform.colorTransform = new ColorTransform(0.7,0.7,0.7);
         }
         else
         {
            this.updateCLScope("");
            this._cmdBG.transform.colorTransform = _loc2_;
            this._traceField.transform.colorTransform = _loc2_;
         }
         this._cmdField.displayAsPassword = param1;
         this._enteringLogin = param1;
      }
      
      public function update(param1:Bool) 
      {
         if(this._bottomLine.alpha > 0)
         {
            this._bottomLine.alpha -= 0.25;
         }
         if(style.showCommandLineScope)
         {
            if(this._clScope != console.cl.scopeString)
            {
               this._clScope = console.cl.scopeString;
               this.updateCLScope(this._clScope);
            }
         }
         else if(this._clScope != null)
         {
            this._clScope = "";
            this.updateCLScope("");
         }
         if(param1)
         {
            this._bottomLine.alpha = 1;
            this._needUpdateMenu = true;
            this._needUpdateTrace = true;
         }
         if(this._needUpdateTrace)
         {
            this._needUpdateTrace = false;
            this._updateTraces(true);
         }
         if(this._needUpdateMenu)
         {
            this._needUpdateMenu = false;
            this._updateMenu();
         }
      }
      
      public function updateToBottom() 
      {
         this._atBottom = true;
         this._needUpdateTrace = true;
      }
      
      function _updateTraces(param1:Bool = false) 
      {
         if(this._atBottom)
         {
            this.updateBottom();
         }
         else if(!param1)
         {
            this.updateFull();
         }
         if(this._selectionStart != this._selectionEnd)
         {
            if(this._atBottom)
            {
               this._traceField.setSelection(this._traceField.text.length - this._selectionStart,this._traceField.text.length - this._selectionEnd);
            }
            else
            {
               this._traceField.setSelection(this._traceField.text.length - this._selectionEnd,this._traceField.text.length - this._selectionStart);
            }
            this._selectionEnd = -1;
            this._selectionStart = -1;
         }
      }
      
      function updateFull() 
      {
         var _loc1_= "";
         var _loc2_= console.logs.first;
         var _loc3_= this._viewingChannels.length != 1;
         var _loc4_= this._priority == 0 && this._viewingChannels.length == 0;
         while(_loc2_ != null)
         {
            if(_loc4_ || this.lineShouldShow(_loc2_))
            {
               _loc1_ += this.makeLine(_loc2_,_loc3_);
            }
            _loc2_ = _loc2_.next;
         }
         this._lockScrollUpdate = true;
         this._traceField.htmlText = "<logs>" + _loc1_ + "</logs>";
         this._lockScrollUpdate = false;
         this.updateScroller();
      }
      
      public function setPaused(param1:Bool) 
      {
         if(param1 && this._atBottom)
         {
            this._atBottom = false;
            this._updateTraces();
            this._traceField.scrollV = this._traceField.maxScrollV;
         }
         else if(!param1)
         {
            this._atBottom = true;
            this.updateBottom();
         }
         this.updateMenu();
      }
      
      function updateBottom() 
      {
         var _loc6_= 0;
         var _loc1_= "";
         var _loc2_= Math.round(this._traceField.height / style.traceFontSize);
         var _loc3_= Math.round(this._traceField.width * 5 / style.traceFontSize);
         var _loc4_= console.logs.last;
         var _loc5_= this._viewingChannels.length != 1;
         while(_loc4_ != null)
         {
            if(this.lineShouldShow(_loc4_))
            {
               _loc6_ = Math.ceil(_loc4_.text.length / _loc3_);
               if(!(_loc4_.html || _loc2_ >= _loc6_))
               {
                  _loc4_ = _loc4_.clone();
                  _loc4_.text = _loc4_.text.substring(Std.int(Math.max(0,_loc4_.text.length - _loc3_ * _loc2_)));
                  _loc1_ = this.makeLine(_loc4_,_loc5_) + _loc1_;
                  break;
               }
               _loc1_ = this.makeLine(_loc4_,_loc5_) + _loc1_;
               _loc2_ -= _loc6_;
               if(_loc2_ <= 0)
               {
                  break;
               }
            }
            _loc4_ = _loc4_.prev;
         }
         this._lockScrollUpdate = true;
         this._traceField.htmlText = "<logs>" + _loc1_ + "</logs>";
         this._traceField.scrollV = this._traceField.maxScrollV;
         this._lockScrollUpdate = false;
         this.updateScroller();
      }
      
      function lineShouldShow(param1:Log) : Bool
      {
         return (this._priority == 0 || (param1.priority : UInt) >= this._priority) && (this.chShouldShow(param1.ch) || ASCompat.stringAsBool(this._filterText) && this._viewingChannels.indexOf(Console.FILTER_CHANNEL) >= 0 && param1.text.toLowerCase().indexOf(this._filterText) >= 0 || this._filterRegExp != null && this._viewingChannels.indexOf(Console.FILTER_CHANNEL) >= 0 && this._filterRegExp.search(param1.text) >= 0);
      }
      
      function chShouldShow(param1:String) : Bool
      {
         return (this._viewingChannels.length == 0 || this._viewingChannels.indexOf(param1) >= 0) && (this._ignoredChannels.length == 0 || this._ignoredChannels.indexOf(param1) < 0);
      }
      
      @:isVar public var reportChannel(get,never):String;
public function  get_reportChannel() : String
      {
         return this._viewingChannels.length == 1 ? this._viewingChannels[0] : Console.CONSOLE_CHANNEL;
      }
      
      public function setViewingChannels(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         var _loc3_:ASObject = null;
         var _loc4_:String = null;
         var _loc2_= new Array<ASAny>();
         if (checkNullIteratee(rest)) for (_tmp_ in rest)
         {
            _loc3_  = _tmp_;
            _loc2_.push(Console.MakeChannelName(_loc3_));
         }
         if(this._viewingChannels[0] == LogReferences.INSPECTING_CHANNEL && (_loc2_ == null || _loc2_[0] != this._viewingChannels[0]))
         {
            console.refs.exitFocus();
         }
         ASCompat.arraySpliceAll(this._ignoredChannels, 0);
         ASCompat.arraySpliceAll(this._viewingChannels, 0);
         if(_loc2_.indexOf(Console.GLOBAL_CHANNEL) < 0 && _loc2_.indexOf(null) < 0)
         {
            if (checkNullIteratee(_loc2_)) for (_tmp_ in _loc2_)
            {
               _loc4_  = _tmp_;
               if(ASCompat.stringAsBool(_loc4_))
               {
                  this._viewingChannels.push(_loc4_);
               }
            }
         }
         this.updateToBottom();
         console.panels.updateMenu();
      }
      
      @:isVar public var viewingChannels(get,never):Array<ASAny>;
public function  get_viewingChannels() : Array<ASAny>
      {
         return this._viewingChannels;
      }
      
      public function setIgnoredChannels(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         var _loc3_:ASObject = null;
         var _loc4_:String = null;
         var _loc2_= new Array<ASAny>();
         if (checkNullIteratee(rest)) for (_tmp_ in rest)
         {
            _loc3_  = _tmp_;
            _loc2_.push(Console.MakeChannelName(_loc3_));
         }
         if(this._viewingChannels[0] == LogReferences.INSPECTING_CHANNEL)
         {
            console.refs.exitFocus();
         }
         ASCompat.arraySpliceAll(this._ignoredChannels, 0);
         ASCompat.arraySpliceAll(this._viewingChannels, 0);
         if(_loc2_.indexOf(Console.GLOBAL_CHANNEL) < 0 && _loc2_.indexOf(null) < 0)
         {
            if (checkNullIteratee(_loc2_)) for (_tmp_ in _loc2_)
            {
               _loc4_  = _tmp_;
               if(ASCompat.stringAsBool(_loc4_))
               {
                  this._ignoredChannels.push(_loc4_);
               }
            }
         }
         this.updateToBottom();
         console.panels.updateMenu();
      }
      
      @:isVar public var ignoredChannels(get,never):Array<ASAny>;
public function  get_ignoredChannels() : Array<ASAny>
      {
         return this._ignoredChannels;
      }
      
      function setFilterText(param1:String = "") 
      {
         if(ASCompat.stringAsBool(param1))
         {
            this._filterRegExp = null;
            this._filterText = LogReferences.EscHTML(param1.toLowerCase());
            this.startFilter();
         }
         else
         {
            this.endFilter();
         }
      }
      
      function setFilterRegExp(param1:String = "") 
      {
         if(ASCompat.stringAsBool(param1))
         {
            this._filterText = null;
            this._filterRegExp = new compat.RegExp(LogReferences.EscHTML(param1),"gi");
            this.startFilter();
         }
         else
         {
            this.endFilter();
         }
      }
      
      function startFilter() 
      {
         console.clear(Console.FILTER_CHANNEL);
         console.logs.addChannel(Console.FILTER_CHANNEL);
         this.setViewingChannels(Console.FILTER_CHANNEL);
      }
      
      function endFilter() 
      {
         this._filterRegExp = null;
         this._filterText = null;
         if(this._viewingChannels.length == 1 && this._viewingChannels[0] == Console.FILTER_CHANNEL)
         {
            this.setViewingChannels(Console.GLOBAL_CHANNEL);
         }
      }
      
      function makeLine(param1:Log, param2:Bool) : String
      {
         var _loc3_= "<p>";
         if(param2)
         {
            _loc3_ += param1.chStr;
         }
         if(config.showLineNumber)
         {
            _loc3_ += param1.lineStr;
         }
         if(config.showTimestamp)
         {
            _loc3_ += param1.timeStr;
         }
         var _loc4_= "p" + param1.priority;
         return _loc3_ + "<" + _loc4_ + ">" + this.addFilterText(param1.text) + "</" + _loc4_ + "></p>";
      }
      
      function addFilterText(param1:String) : String
      {
         var _loc2_:ASObject = null;
         var _loc3_= 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_= 0;
         if(this._filterRegExp != null)
         {
            this._filterRegExp.lastIndex = 0;
            _loc2_ = this._filterRegExp.exec(param1);
            while(_loc2_ != null)
            {
               _loc3_ = ASCompat.toInt(_loc2_.index);
               _loc4_ = _loc2_[Std.string(0)];
               if(_loc4_.indexOf("<|>") >= 0)
               {
                  this._filterRegExp.lastIndex -= _loc4_.length - _loc4_.indexOf("<|>");
               }
               else if(param1.lastIndexOf("<",_loc3_) <= param1.lastIndexOf(">",_loc3_))
               {
                  param1 = param1.substring(0,_loc3_) + "<u>" + param1.substring(_loc3_,_loc3_ + _loc4_.length) + "</u>" + param1.substring(_loc3_ + _loc4_.length);
                  this._filterRegExp.lastIndex += 7;
               }
               _loc2_ = this._filterRegExp.exec(param1);
            }
         }
         else if(ASCompat.stringAsBool(this._filterText))
         {
            _loc5_ = param1.toLowerCase();
            _loc6_ = _loc5_.lastIndexOf(this._filterText);
            while(_loc6_ >= 0)
            {
               param1 = param1.substring(0,_loc6_) + "<u>" + param1.substring(_loc6_,_loc6_ + this._filterText.length) + "</u>" + param1.substring(_loc6_ + this._filterText.length);
               _loc6_ = _loc5_.lastIndexOf(this._filterText,_loc6_ - 2);
            }
         }
         return param1;
      }
      
      function onTraceScroll(param1:Event = null) 
      {
         var _loc3_= 0;
         if(this._lockScrollUpdate || this._shift)
         {
            return;
         }
         var _loc2_= this._traceField.scrollV >= this._traceField.maxScrollV;
         if(!console.paused && this._atBottom != _loc2_)
         {
            _loc3_ = this._traceField.maxScrollV - this._traceField.scrollV;
            this._selectionStart = this._traceField.text.length - this._traceField.selectionBeginIndex;
            this._selectionEnd = this._traceField.text.length - this._traceField.selectionEndIndex;
            this._atBottom = _loc2_;
            this._updateTraces();
            this._traceField.scrollV = this._traceField.maxScrollV - _loc3_;
         }
         this.updateScroller();
      }
      
      function updateScroller() 
      {
         if(this._traceField.maxScrollV <= 1)
         {
            this._scroll.visible = false;
         }
         else
         {
            this._scroll.visible = true;
            if(this._atBottom)
            {
               this.scrollPercent = 1;
            }
            else
            {
               this.scrollPercent = (this._traceField.scrollV - 1) / (this._traceField.maxScrollV - 1);
            }
         }
      }
      
      function onScrollbarDown(param1:MouseEvent) 
      {
         if(this._scroller.visible && this._scroller.mouseY > 0 || !this._scroller.visible && this._scroll.mouseY > this._scrollHeight / 2)
         {
            this._scrolldir = 3;
         }
         else
         {
            this._scrolldir = -3;
         }
         this._traceField.scrollV += this._scrolldir;
         this._scrolldelay = (0 : UInt);
         addEventListener(Event.ENTER_FRAME,this.onScrollBarFrame,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onScrollBarUp,false,0,true);
      }
      
      function onScrollBarFrame(param1:Event) 
      {
         ++this._scrolldelay;
         if(this._scrolldelay > 10)
         {
            this._scrolldelay = (9 : UInt);
            if(this._scrolldir < 0 && this._scroller.y > this._scroll.mouseY || this._scrolldir > 0 && this._scroller.y + this._scroller.height < this._scroll.mouseY)
            {
               this._traceField.scrollV += this._scrolldir;
            }
         }
      }
      
      function onScrollBarUp(param1:Event) 
      {
         removeEventListener(Event.ENTER_FRAME,this.onScrollBarFrame);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onScrollBarUp);
      }
      
            
      @:isVar var scrollPercent(get,set):Float;
function  get_scrollPercent() : Float
      {
         return (this._scroller.y - style.controlSize) / (this._scrollHeight - 30 - style.controlSize * 2);
      }
function  set_scrollPercent(param1:Float) :Float      {
         this._scroller.y = style.controlSize + (this._scrollHeight - 30 - style.controlSize * 2) * param1;
return param1;
      }
      
      function onScrollerDown(param1:MouseEvent) 
      {
         var _loc2_= Math.NaN;
         this._scrolling = true;
         if(!console.paused && this._atBottom)
         {
            this._atBottom = false;
            _loc2_ = this.scrollPercent;
            this._updateTraces();
            this.scrollPercent = _loc2_;
         }
         this._scroller.startDrag(false,new Rectangle(0,style.controlSize,0,this._scrollHeight - 30 - style.controlSize * 2));
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onScrollerMove,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,this.onScrollerUp,false,0,true);
         param1.stopPropagation();
      }
      
      function onScrollerMove(param1:MouseEvent) 
      {
         this._lockScrollUpdate = true;
         this._traceField.scrollV = Math.round(this.scrollPercent * (this._traceField.maxScrollV - 1) + 1);
         this._lockScrollUpdate = false;
      }
      
      function onScrollerUp(param1:MouseEvent) 
      {
         this._scroller.stopDrag();
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onScrollerMove);
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.onScrollerUp);
         this._scrolling = false;
         this.onTraceScroll();
      }
      
      override public function  set_width(param1:Float) :Float      {
         this._lockScrollUpdate = true;
         super.width = param1;
         this._traceField.width = param1 - 4;
         txtField.width = param1 - 6;
         this._cmdField.width = width - 15 - this._cmdField.x;
         this._cmdBG.width = param1;
         this._bottomLine.graphics.clear();
         this._bottomLine.graphics.lineStyle(1,style.controlColor);
         this._bottomLine.graphics.moveTo(10,-1);
         this._bottomLine.graphics.lineTo(param1 - 10,-1);
         this._scroll.x = param1;
         this._atBottom = true;
         this.updateCLSize();
         this._needUpdateMenu = true;
         this._needUpdateTrace = true;
         this._lockScrollUpdate = false;
return param1;
      }
      
      override public function  set_height(param1:Float) :Float      {
         this._lockScrollUpdate = true;
         var _loc2_= style.menuFontSize;
         var _loc3_:Float = _loc2_ + 6 + style.traceFontSize;
         if(height != param1)
         {
            this._mini = param1 < (this._cmdField.visible ? _loc3_ + _loc2_ + 4 : _loc3_);
         }
         super.height = param1;
         var _loc4_= this._mini || !style.topMenu;
         this.updateTraceFHeight();
         this._traceField.y = _loc4_ ? 0 : _loc2_;
         this._traceField.height = param1 - (this._cmdField.visible ? _loc2_ + 4 : 0) - (_loc4_ ? 0 : _loc2_);
         var _loc5_= param1 - (_loc2_ + 6);
         this._cmdField.y = _loc5_;
         this._cmdPrefx.y = _loc5_;
         this._hintField.y = this._cmdField.y - this._hintField.height;
         this._cmdBG.y = _loc5_;
         this._bottomLine.y = this._cmdField.visible ? _loc5_ : param1;
         this._scroll.y = _loc4_ ? 6 : _loc2_ + 4;
         var _loc6_= style.controlSize;
         this._scrollHeight = ASCompat.toNumber(ASCompat.toNumber(this._bottomLine.y - ASCompat.toNumber(this._cmdField.visible ? 0 : _loc6_ * 2)) - this._scroll.y);
         this._scroller.visible = this._scrollHeight > 40;
         this._scroll.graphics.clear();
         if(this._scrollHeight >= 10)
         {
            this._scroll.graphics.beginFill(style.controlColor,0.7);
            this._scroll.graphics.drawRect(-_loc6_,0,_loc6_,_loc6_);
            this._scroll.graphics.drawRect(-_loc6_,this._scrollHeight - _loc6_,_loc6_,_loc6_);
            this._scroll.graphics.beginFill(style.controlColor,0.25);
            this._scroll.graphics.drawRect(-_loc6_,_loc6_,_loc6_,this._scrollHeight - _loc6_ * 2);
            this._scroll.graphics.beginFill((0 : UInt),0);
            this._scroll.graphics.drawRect(-_loc6_ * 2,_loc6_ * 2,_loc6_ * 2,this._scrollHeight - _loc6_ * 2);
            this._scroll.graphics.endFill();
         }
         this._atBottom = true;
         this._needUpdateTrace = true;
         this._lockScrollUpdate = false;
return param1;
      }
      
      function updateTraceFHeight() 
      {
         var _loc1_= this._mini || !style.topMenu;
         this._traceField.y = _loc1_ ? 0 : txtField.y + txtField.height - 6;
         this._traceField.height = Math.max(0,height - (this._cmdField.visible ? style.menuFontSize + 4 : 0) - this._traceField.y);
      }
      
      public function updateMenu(param1:Bool = false) 
      {
         if(param1)
         {
            this._updateMenu();
         }
         else
         {
            this._needUpdateMenu = true;
         }
      }
      
      function _updateMenu() 
      {
         var __ax4_iter_95:ASObject;
         var _loc2_= false;
         var _loc3_:String = null;
         var _loc1_= "<r><high>";
         if(this._mini || !style.topMenu)
         {
            _loc1_ += "<menu><b> <a href=\"event:show\">‹</a>";
         }
         else
         {
            if(!console.panels.channelsPanel)
            {
               _loc1_ += this.getChannelsLink(true);
            }
            _loc1_ += "<menu> <b>";
            __ax4_iter_95 = this._extraMenus;
            if (checkNullIteratee(__ax4_iter_95)) for(_tmp_ in __ax4_iter_95.___keys())
            {
               _loc3_  = _tmp_;
               _loc1_ += "<a href=\"event:external_" + _loc3_ + "\">" + _loc3_ + "</a> ";
               _loc2_ = true;
            }
            if(_loc2_)
            {
               _loc1_ += "¦ ";
            }
            _loc1_ += this.doActive("<a href=\"event:fps\">F</a>",ASCompat.toNumberField(console, "fpsMonitor") > 0);
            _loc1_ += this.doActive(" <a href=\"event:mm\">M</a>",ASCompat.toNumberField(console, "memoryMonitor") > 0);
            _loc1_ += this.doActive(" <a href=\"event:command\">CL</a>",this.commandLine);
            if(console.remoter.remoting != Remoting.RECIEVER)
            {
               if(config.displayRollerEnabled)
               {
                  _loc1_ += this.doActive(" <a href=\"event:roller\">Ro</a>",console.displayRoller);
               }
               if(config.rulerToolEnabled)
               {
                  _loc1_ += this.doActive(" <a href=\"event:ruler\">RL</a>",console.panels.rulerActive);
               }
            }
            _loc1_ += " ¦</b>";
            _loc1_ += " <a href=\"event:copy\">Sv</a>";
            _loc1_ += " <a href=\"event:priority\">P" + this._priority + "</a>";
            _loc1_ += this.doActive(" <a href=\"event:pause\">P</a>",console.paused);
            _loc1_ += " <a href=\"event:clear\">C</a> <a href=\"event:close\">X</a> <a href=\"event:hide\">›</a>";
         }
         _loc1_ += " </b></menu></high></r>";
         txtField.htmlText = _loc1_;
         txtField.scrollH = txtField.maxScrollH;
         this.updateTraceFHeight();
      }
      
      public function getChannelsLink(param1:Bool = false) : String
      {
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc2_= "<chs>";
         var _loc3_= console.logs.getChannels();
         var _loc4_= _loc3_.length;
         if(param1 && _loc4_ > style.maxChannelsInMenu)
         {
            _loc4_ = style.maxChannelsInMenu;
         }
         var _loc5_= this._viewingChannels.length > 0 || this._ignoredChannels.length > 0;
         var _loc6_= 0;
         while(_loc6_ < _loc4_)
         {
            _loc7_ = _loc3_[_loc6_];
            _loc8_ = !_loc5_ && _loc6_ == 0 || _loc5_ && _loc6_ != 0 && this.chShouldShow(_loc7_) ? "<ch><b>" + _loc7_ + "</b></ch>" : _loc7_;
            _loc2_ += "<a href=\"event:channel_" + _loc7_ + "\">[" + _loc8_ + "]</a> ";
            _loc6_++;
         }
         if(param1)
         {
            _loc2_ += "<ch><a href=\"event:channels\"><b>" + (_loc3_.length > _loc4_ ? "..." : "") + "</b>^^ </a></ch>";
         }
         return _loc2_ + "</chs> ";
      }
      
      function doActive(param1:String, param2:Bool) : String
      {
         if(param2)
         {
            return "<menuHi>" + param1 + "</menuHi>";
         }
         return param1;
      }
      
      public function onMenuRollOver(param1:TextEvent, param2:ConsolePanel = null) 
      {
         var _loc4_:Array<ASAny> = null;
         var _loc5_:ASObject = null;
         if(param2 == null)
         {
            param2 = this;
         }
         var _loc3_= ASCompat.stringAsBool(param1.text) ? StringTools.replace(param1.text, "event:","") : "";
         if(_loc3_ == "channel_" + Console.GLOBAL_CHANNEL)
         {
            _loc3_ = "View all channels";
         }
         else if(_loc3_ == "channel_" + Console.DEFAULT_CHANNEL)
         {
            _loc3_ = "Default channel::Logs with no channel";
         }
         else if(_loc3_ == "channel_" + Console.CONSOLE_CHANNEL)
         {
            _loc3_ = "Console\'s channel::Logs generated from Console";
         }
         else if(_loc3_ == "channel_" + Console.FILTER_CHANNEL)
         {
            _loc3_ = this._filterRegExp != null ? ASCompat.toString(this._filterRegExp) : this._filterText;
            _loc3_ = "Filtering channel" + "::*" + _loc3_ + "*";
         }
         else if(_loc3_ == "channel_" + LogReferences.INSPECTING_CHANNEL)
         {
            _loc3_ = "Inspecting channel";
         }
         else if(_loc3_.indexOf("channel_") == 0)
         {
            _loc3_ = "Change channel::shift: select multiple\nctrl: ignore channel";
         }
         else if(_loc3_ == "pause")
         {
            if(console.paused)
            {
               _loc3_ = "Resume updates";
            }
            else
            {
               _loc3_ = "Pause updates";
            }
         }
         else if(_loc3_ == "close" && param2 == this)
         {
            _loc3_ = "Close::Type password to show again";
         }
         else if(_loc3_.indexOf("external_") == 0)
         {
            _loc4_ = ASCompat.dynamicAs(this._extraMenus[_loc3_.substring(9)], Array);
            if(_loc4_ != null)
            {
               _loc3_ = _loc4_[2];
            }
         }
         else
         {
            _loc5_ = {
               "fps":"Frames Per Second",
               "mm":"Memory Monitor",
               "roller":"Display Roller::Map the display list under your mouse",
               "ruler":"Screen Ruler::Measure the distance and angle between two points on screen.",
               "command":"Command Line",
               "copy":"Save to clipboard::shift: no channel name\nctrl: use viewing filters\nalt: save to file",
               "clear":"Clear log",
               "priority":"Priority filter::shift: previous priority\n(skips unused priorites)",
               "channels":"Expand channels",
               "close":"Close"
            };
            _loc3_ = _loc5_[_loc3_];
         }
         console.panels.tooltip(_loc3_,param2);
      }
      
      function linkHandler(param1:TextEvent) 
      {
         var t:String;
         var str:String = null;
         var file:FileReference = null;
         var ind= 0;
         var menu:Array<ASAny> = null;
         var e= param1;
         txtField.setSelection(0,0);
         stopDrag();
         t = e.text;
         if(t == "pause")
         {
            if(console.paused)
            {
               console.paused = false;
            }
            else
            {
               console.paused = true;
            }
            console.panels.tooltip(null);
         }
         else if(t == "hide")
         {
            console.panels.tooltip();
            this._mini = true;
            console.config.style.topMenu = false;
            this.height = height;
            this.updateMenu();
         }
         else if(t == "show")
         {
            console.panels.tooltip();
            this._mini = false;
            console.config.style.topMenu = true;
            this.height = height;
            this.updateMenu();
         }
         else if(t == "close")
         {
            console.panels.tooltip();
            visible = false;
            dispatchEvent(new Event(Event.CLOSE));
         }
         else if(t == "channels")
         {
            console.panels.channelsPanel = !console.panels.channelsPanel;
         }
         else if(t == "fps")
         {
            console.fpsMonitor = !console.fpsMonitor;
         }
         else if(t == "priority")
         {
            this.incPriority(this._shift);
         }
         else if(t == "mm")
         {
            console.memoryMonitor = !console.memoryMonitor;
         }
         else if(t == "roller")
         {
            console.displayRoller = !console.displayRoller;
         }
         else if(t == "ruler")
         {
            console.panels.tooltip();
            console.panels.startRuler();
         }
         else if(t == "command")
         {
            this.commandLine = !this.commandLine;
         }
         else if(t == "copy")
         {
            str = console.logs.getLogsAsString("\r\n",!this._shift,ASCompat.asFunction(this._ctrl ? this.lineShouldShow : null));
            if(this._alt)
            {
               file = new FileReference();
               try
               {
                  (file : ASAny)["save"](str,"log.txt");
               }
               catch(err:Dynamic)
               {
                  console.report("Save to file is not supported in your flash player.",8);
               }
            }
            else
            {
               System.setClipboard(str);
               console.report("Copied log to clipboard.",-1);
            }
         }
         else if(t == "clear")
         {
            console.clear();
         }
         else if(t == "settings")
         {
            console.report("A new window should open in browser. If not, try searching for \'Flash Player Global Security Settings panel\' online :)",-1);
         }
         else if(t == "remote")
         {
            console.remoter.remoting = Remoting.RECIEVER;
         }
         else if(t.indexOf("ref") == 0)
         {
            console.refs.handleRefEvent(t);
         }
         else if(t.indexOf("channel_") == 0)
         {
            this.onChannelPressed(t.substring(8));
         }
         else if(t.indexOf("cl_") == 0)
         {
            ind = t.indexOf("_",3);
            console.cl.handleScopeEvent((ASCompat.toInt(t.substring(3,ind < 0 ? t.length : ind)) : UInt));
            if(ind >= 0)
            {
               this._cmdField.text = t.substring(ind + 1);
            }
         }
         else if(t.indexOf("external_") == 0)
         {
            menu = ASCompat.dynamicAs(this._extraMenus[t.substring(9)], Array);
            if(menu != null)
            {
               ASCompatMacro.applyClosure(menu[0], menu[1]);
            }
         }
         txtField.setSelection(0,0);
         e.stopPropagation();
      }
      
      public function onChannelPressed(param1:String) 
      {
         var _loc2_:Array<ASAny> = null;
         if(this._ctrl && param1 != Console.GLOBAL_CHANNEL)
         {
            _loc2_ = this.toggleCHList(this._ignoredChannels,param1);
            Reflect.callMethod(this,this.setIgnoredChannels, _loc2_);
         }
         else if(this._shift && param1 != Console.GLOBAL_CHANNEL && this._viewingChannels[0] != LogReferences.INSPECTING_CHANNEL)
         {
            _loc2_ = this.toggleCHList(this._viewingChannels,param1);
            Reflect.callMethod(this,this.setViewingChannels, _loc2_);
         }
         else
         {
            console.setViewingChannels(param1);
         }
      }
      
      function toggleCHList(param1:Array<ASAny>, param2:String) : Array<ASAny>
      {
         param1 = param1.copy();
         var _loc3_= param1.indexOf(param2);
         if(_loc3_ >= 0)
         {
            param1.splice(_loc3_,(1 : UInt));
            if(param1.length == 0)
            {
               param1.push(Console.GLOBAL_CHANNEL);
            }
         }
         else
         {
            param1.push(param2);
         }
         return param1;
      }
      
            
      @:isVar public var priority(get,set):UInt;
public function  set_priority(param1:UInt) :UInt      {
         this._priority = param1;
         console.so[PRIORITY_HISTORY] = this._priority;
         this.updateToBottom();
         this.updateMenu();
return param1;
      }
function  get_priority() : UInt
      {
         return this._priority;
      }
      
      function incPriority(param1:Bool) 
      {
         var _loc3_= (0 : UInt);
         var _loc2_= (10 : UInt);
         var _loc4_= console.logs.last;
         var _loc5_:Int = this._priority;
         this._priority = (0 : UInt);
         var _loc6_= (32000 : UInt);
         while(ASCompat.toBool(_loc4_) && _loc6_ > 0)
         {
            _loc6_--;
            if(this.lineShouldShow(_loc4_))
            {
               if(_loc4_.priority > _loc5_ && _loc2_ > (_loc4_.priority : UInt))
               {
                  _loc2_ = (_loc4_.priority : UInt);
               }
               if(_loc4_.priority < _loc5_ && _loc3_ < (_loc4_.priority : UInt))
               {
                  _loc3_ = (_loc4_.priority : UInt);
               }
            }
            _loc4_ = _loc4_.prev;
         }
         if(param1)
         {
            if(_loc3_ == (_loc5_ : UInt))
            {
               _loc5_ = 10;
            }
            else
            {
               _loc5_ = _loc3_;
            }
         }
         else if(_loc2_ == (_loc5_ : UInt))
         {
            _loc5_ = 0;
         }
         else
         {
            _loc5_ = _loc2_;
         }
         this.priority = (_loc5_ : UInt);
      }
      
      function clearCommandLineHistory(..._rest:ASAny) 
      {
         var rest = ASCompat.restToArray(_rest);
         this._cmdsInd = -1;
         console.updateSO();
         this._cmdsHistory = new Array<ASAny>();
      }
      
      function commandKeyDown(param1:KeyboardEvent) 
      {
         if(param1.keyCode == Keyboard.TAB)
         {
            if(ASCompat.stringAsBool(this._hint))
            {
               this._cmdField.text = this._hint;
               this.setCLSelectionAtEnd();
               this.setHints();
            }
         }
      }
      
      function commandKeyUp(param1:KeyboardEvent) 
      {
         var _loc2_:String = null;
         var _loc3_= 0;
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.updateToBottom();
            this.setHints();
            if(this._enteringLogin)
            {
               console.remoter.login(this._cmdField.text);
               this._cmdField.text = "";
               this.requestLogin(false);
            }
            else
            {
               _loc2_ = this._cmdField.text;
               if(_loc2_.length > 2)
               {
                  _loc3_ = this._cmdsHistory.indexOf(_loc2_);
                  while(_loc3_ >= 0)
                  {
                     this._cmdsHistory.splice(_loc3_,(1 : UInt));
                     _loc3_ = this._cmdsHistory.indexOf(_loc2_);
                  }
                  this._cmdsHistory.unshift(_loc2_);
                  this._cmdsInd = -1;
                  if(this._cmdsHistory.length > 20)
                  {
                     ASCompat.arraySpliceAll(this._cmdsHistory, 20);
                  }
                  console.updateSO(CL_HISTORY);
               }
               this._cmdField.text = "";
               if(config.commandLineInputPassThrough != null)
               {
                  _loc2_ = config.commandLineInputPassThrough(_loc2_);
               }
               if(ASCompat.stringAsBool(_loc2_))
               {
                  console.cl.run(_loc2_);
               }
            }
         }
         else if(param1.keyCode == Keyboard.ESCAPE)
         {
            if(stage != null)
            {
               stage.focus = null;
            }
         }
         else if(param1.keyCode == Keyboard.UP)
         {
            this.setHints();
            if(ASCompat.toBool(this._cmdField.text) && this._cmdsInd < 0)
            {
               this._cmdsHistory.unshift(this._cmdField.text);
               ++this._cmdsInd;
            }
            if(this._cmdsInd < this._cmdsHistory.length - 1)
            {
               ++this._cmdsInd;
               this._cmdField.text = this._cmdsHistory[this._cmdsInd];
               this.setCLSelectionAtEnd();
            }
            else
            {
               this._cmdsInd = this._cmdsHistory.length;
               this._cmdField.text = "";
            }
         }
         else if(param1.keyCode == Keyboard.DOWN)
         {
            this.setHints();
            if(this._cmdsInd > 0)
            {
               --this._cmdsInd;
               this._cmdField.text = this._cmdsHistory[this._cmdsInd];
               this.setCLSelectionAtEnd();
            }
            else
            {
               this._cmdsInd = -1;
               this._cmdField.text = "";
            }
         }
         else if(param1.keyCode == Keyboard.TAB)
         {
            this.setCLSelectionAtEnd();
         }
         else if(!this._enteringLogin)
         {
            this.updateCmdHint();
         }
      }
      
      function setCLSelectionAtEnd() 
      {
         this._cmdField.setSelection(this._cmdField.text.length,this._cmdField.text.length);
      }
      
      function updateCmdHint(param1:Event = null) 
      {
         var e= param1;
         var str= this._cmdField.text;
         if(ASCompat.stringAsBool(str) && config.commandLineAutoCompleteEnabled && console.remoter.remoting != Remoting.RECIEVER)
         {
            try
            {
               this.setHints(console.cl.getHintsFor(str,(5 : UInt)));
               return;
            }
            catch(err:Dynamic)
            {
            }
         }
         this.setHints();
      }
      
      function onCmdFocusOut(param1:Event) 
      {
         this.setHints();
      }
      
      function setHints(param1:Array<ASAny> = null) 
      {
         var _loc2_:Array<ASAny> = null;
         var _loc3_:Array<ASAny> = null;
         var _loc4_:Rectangle = null;
         var _loc5_:String = null;
         var _loc6_= false;
         var _loc7_= 0;
         if(ASCompat.toBool(param1) && ASCompat.toBool(param1.length))
         {
            this._hint = ASCompat.dynGetIndex(param1[0], 0);
            if(param1.length > 1)
            {
               _loc5_ = ASCompat.dynGetIndex(param1[1], 0);
               _loc6_ = false;
               _loc7_ = 0;
               while(_loc7_ < _loc5_.length)
               {
                  if(_loc5_.charAt(_loc7_) != this._hint.charAt(_loc7_))
                  {
                     if(_loc6_ && this._cmdField.text.length < _loc7_)
                     {
                        this._hint = this._hint.substring(0,_loc7_);
                     }
                     break;
                  }
                  _loc6_ = true;
                  _loc7_++;
               }
            }
            _loc2_ = new Array<ASAny>();
            if (checkNullIteratee(param1)) for (_tmp_ in param1)
            {
               _loc3_  = ASCompat.dynamicAs(_tmp_, Array);
               _loc2_.push("<p3>" + Std.string(_loc3_[0]) + "</p3> <p0>" + Std.string((ASCompat.toBool(_loc3_[1]) ? _loc3_[1] : "")) + "</p0>");
            }
            this._hintField.htmlText = "<p>" + Std.string(ASCompat.dynJoin(ASCompat.ASArray.reverse(_loc2_), "\n"))+ "</p>";
            this._hintField.visible = true;
            _loc4_ = this._cmdField.getCharBoundaries(this._cmdField.text.length - 1);
            if(_loc4_ == null)
            {
               _loc4_ = new Rectangle();
            }
            this._hintField.x = this._cmdField.x + _loc4_.x + _loc4_.width + 30;
            this._hintField.y = height - this._hintField.height;
         }
         else
         {
            this._hintField.visible = false;
            this._hint = null;
         }
      }
      
      public function updateCLScope(param1:String) 
      {
         if(this._enteringLogin)
         {
            this._enteringLogin = false;
            this.requestLogin(false);
         }
         this._cmdPrefx.autoSize = TextFieldAutoSize.LEFT;
         this._cmdPrefx.text = param1;
         this.updateCLSize();
      }
      
      function updateCLSize() 
      {
         var _loc1_= width - 48;
         if(this._cmdPrefx.width > 120 || this._cmdPrefx.width > _loc1_)
         {
            this._cmdPrefx.autoSize = TextFieldAutoSize.NONE;
            this._cmdPrefx.width = _loc1_ > 120 ? 120 : _loc1_;
            this._cmdPrefx.scrollH = this._cmdPrefx.maxScrollH;
         }
         this._cmdField.x = this._cmdPrefx.width + 2;
         this._cmdField.width = width - 15 - this._cmdField.x;
         this._hintField.x = this._cmdField.x;
      }
      
            
      @:isVar public var commandLine(get,set):Bool;
public function  set_commandLine(param1:Bool) :Bool      {
         if(param1)
         {
            this._cmdField.visible = true;
            this._cmdPrefx.visible = true;
            this._cmdBG.visible = true;
         }
         else
         {
            this._cmdField.visible = false;
            this._cmdPrefx.visible = false;
            this._cmdBG.visible = false;
         }
         this._needUpdateMenu = true;
         this.height = height;
return param1;
      }
function  get_commandLine() : Bool
      {
         return this._cmdField.visible;
      }
   }


