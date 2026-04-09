package com.junkbyte.console.core
;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.Log;
   import flash.events.Event;
   import flash.utils.ByteArray;
   
    class Logs extends ConsoleCore
   {
      
      var _channels:ASObject;
      
      var _repeating:UInt = 0;
      
      var _lastRepeat:Log;
      
      var _newRepeat:Log;
      
      var _hasNewLog:Bool = false;
      
      var _timer:UInt = 0;
      
      public var first:Log;
      
      public var last:Log;
      
      var _length:UInt = 0;
      
      var _lines:UInt = 0;
      
      public function new(param1:Console)
      {
         var console= param1;
         super(console);
         this._channels = new ASObject();
         remoter.addEventListener(Event.CONNECT,this.onRemoteConnection);
         remoter.registerCallback("log",function(param1:ByteArray)
         {
            registerLog(Log.FromBytes(param1));
         });
      }
      
      function onRemoteConnection(param1:Event) 
      {
         var _loc2_= this.first;
         while(_loc2_ != null)
         {
            this.send2Remote(_loc2_);
            _loc2_ = _loc2_.next;
         }
      }
      
      function send2Remote(param1:Log) 
      {
         var _loc2_:ByteArray = null;
         if(remoter.canSend)
         {
            _loc2_ = new ByteArray();
            param1.toBytes(_loc2_);
            remoter.send("log",_loc2_);
         }
      }
      
      public function update(param1:UInt) : Bool
      {
         this._timer = param1;
         if(this._repeating > 0)
         {
            --this._repeating;
         }
         if(this._newRepeat != null)
         {
            if(this._lastRepeat != null)
            {
               this.remove(this._lastRepeat);
            }
            this._lastRepeat = this._newRepeat;
            this._newRepeat = null;
            this.push(this._lastRepeat);
         }
         var _loc2_= this._hasNewLog;
         this._hasNewLog = false;
         return _loc2_;
      }
      
      public function add(param1:Log) 
      {
         ++this._lines;
         param1.line = this._lines;
         param1.time = this._timer;
         this.registerLog(param1);
      }
      
      function registerLog(param1:Log) 
      {
         this._hasNewLog = true;
         this.addChannel(param1.ch);
         param1.lineStr = param1.line + " ";
         param1.chStr = "[<a href=\"event:channel_" + param1.ch + "\">" + param1.ch + "</a>] ";
         param1.timeStr = config.timeStampFormatter(param1.time) + " ";
         this.send2Remote(param1);
         if(param1.repeat)
         {
            if(this._repeating > 0 && ASCompat.toBool(this._lastRepeat))
            {
               param1.line = this._lastRepeat.line;
               this._newRepeat = param1;
               return;
            }
            this._repeating = (config.maxRepeats : UInt);
            this._lastRepeat = param1;
         }
         this.push(param1);
         while(this._length > config.maxLines && config.maxLines > 0)
         {
            this.remove(this.first);
         }
         if(config.tracing && config.traceCall != null)
         {
            config.traceCall(param1.ch,param1.plainText(),param1.priority);
         }
      }
      
      public function clear(param1:String = null) 
      {
         var _loc2_:Log = null;
         if(ASCompat.stringAsBool(param1))
         {
            _loc2_ = this.first;
            while(_loc2_ != null)
            {
               if(_loc2_.ch == param1)
               {
                  this.remove(_loc2_);
               }
               _loc2_ = _loc2_.next;
            }
            ASCompat.deleteProperty(this._channels, param1);
         }
         else
         {
            this.first = null;
            this.last = null;
            this._length = (0 : UInt);
            this._channels = new ASObject();
         }
      }
      
      public function getLogsAsString(param1:String, param2:Bool = true, param3:ASFunction = null) : String
      {
         var _loc4_= "";
         var _loc5_= this.first;
         while(_loc5_ != null)
         {
            if(param3 == null || ASCompat.toBool(param3(_loc5_)))
            {
               if(this.first != _loc5_)
               {
                  _loc4_ += param1;
               }
               _loc4_ += param2 ? _loc5_.toString() : _loc5_.plainText();
            }
            _loc5_ = _loc5_.next;
         }
         return _loc4_;
      }
      
      public function getChannels() : Array<ASAny>
      {
         var _loc3_:String = null;
         var _loc1_:Array<ASAny> = [Console.GLOBAL_CHANNEL];
         this.addIfexist(Console.DEFAULT_CHANNEL,_loc1_);
         this.addIfexist(Console.FILTER_CHANNEL,_loc1_);
         this.addIfexist(LogReferences.INSPECTING_CHANNEL,_loc1_);
         this.addIfexist(Console.CONSOLE_CHANNEL,_loc1_);
         var _loc2_= new Array<ASAny>();
         final __ax4_iter_88:ASObject = this._channels;
         if (checkNullIteratee(__ax4_iter_88)) for(_tmp_ in __ax4_iter_88.___keys())
         {
            _loc3_  = _tmp_;
            if(_loc1_.indexOf(_loc3_) < 0)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc1_.concat(ASCompat.ASArray.sortWithOptions(_loc2_, ASCompat.ASArray.CASEINSENSITIVE));
      }
      
      function addIfexist(param1:String, param2:Array<ASAny>) 
      {
         if(this._channels.hasOwnProperty(param1))
         {
            param2.push(param1);
         }
      }
      
      public function cleanChannels() 
      {
         this._channels = new ASObject();
         var _loc1_= this.first;
         while(_loc1_ != null)
         {
            this.addChannel(_loc1_.ch);
            _loc1_ = _loc1_.next;
         }
      }
      
      public function addChannel(param1:String) 
      {
         this._channels[param1] = null;
      }
      
      function push(param1:Log) 
      {
         if(this.last == null)
         {
            this.first = param1;
         }
         else
         {
            this.last.next = param1;
            param1.prev = this.last;
         }
         this.last = param1;
         ++this._length;
      }
      
      function remove(param1:Log) 
      {
         if(this.first == param1)
         {
            this.first = param1.next;
         }
         if(this.last == param1)
         {
            this.last = param1.prev;
         }
         if(param1 == this._lastRepeat)
         {
            this._lastRepeat = null;
         }
         if(param1 == this._newRepeat)
         {
            this._newRepeat = null;
         }
         if(param1.next != null)
         {
            param1.next.prev = param1.prev;
         }
         if(param1.prev != null)
         {
            param1.prev.next = param1.next;
         }
         --this._length;
      }
   }


