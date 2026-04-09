package com.junkbyte.console.core
;
   import com.junkbyte.console.Console;
   import flash.system.System;
   
    class MemoryMonitor extends ConsoleCore
   {
      
      var _namesList:ASObject;
      
      var _objectsList:ASDictionary<ASAny,ASAny>;
      
      var _count:UInt = 0;
      
      public function new(param1:Console)
      {
         super(param1);
         this._namesList = new ASObject();
         this._objectsList = new ASDictionary<ASAny,ASAny>(true);
         console.remoter.registerCallback("gc",this.gc);
      }
      
      public function watch(param1:ASObject, param2:String) : String
      {
         var _loc3_= ASCompat.getQualifiedClassName(param1);
         if(!ASCompat.stringAsBool(param2))
         {
            param2 = _loc3_ + "@" + flash.Lib.getTimer();
         }
         if(ASCompat.toBool(this._objectsList[param1]))
         {
            if(ASCompat.toBool(this._namesList[this._objectsList[param1]]))
            {
               this.unwatch(this._objectsList[param1]);
            }
         }
         if(ASCompat.toBool(this._namesList[param2]))
         {
            if(this._objectsList[param1] == param2)
            {
               --this._count;
            }
            else
            {
               param2 = param2 + "@" + flash.Lib.getTimer() + "_" + Math.ffloor(Math.random() * 100);
            }
         }
         this._namesList[param2] = true;
         ++this._count;
         this._objectsList[param1] = param2;
         return param2;
      }
      
      public function unwatch(param1:String) 
      {
         var _loc2_:ASObject = null;
         final __ax4_iter_79 = this._objectsList;
         if (checkNullIteratee(__ax4_iter_79)) for(_tmp_ in __ax4_iter_79.keys())
         {
            _loc2_  = _tmp_;
            if(this._objectsList[_loc2_] == param1)
            {
               this._objectsList.remove(_loc2_);
            }
         }
         if(ASCompat.toBool(this._namesList[param1]))
         {
            ASCompat.deleteProperty(this._namesList, param1);
            --this._count;
         }
      }
      
      public function update() 
      {
         var _loc3_:ASObject = null;
         var _loc4_:String = null;
         if(this._count == 0)
         {
            return;
         }
         var _loc1_= new Array<ASAny>();
         var _loc2_:ASObject = new ASObject();
         final __ax4_iter_80 = this._objectsList;
         if (checkNullIteratee(__ax4_iter_80)) for(_tmp_ in __ax4_iter_80.keys())
         {
            _loc3_  = _tmp_;
            _loc2_[this._objectsList[_loc3_]] = true;
         }
         final __ax4_iter_81:ASObject = this._namesList;
         if (checkNullIteratee(__ax4_iter_81)) for(_tmp_ in __ax4_iter_81.___keys())
         {
            _loc4_  = _tmp_;
            if(!ASCompat.toBool(_loc2_[_loc4_]))
            {
               _loc1_.push(_loc4_);
               ASCompat.deleteProperty(this._namesList, _loc4_);
               --this._count;
            }
         }
         if(_loc1_.length != 0)
         {
            report("<b>GARBAGE COLLECTED " + _loc1_.length + " item(s): </b>" + _loc1_.join(", "),-2);
         }
      }
      
      @:isVar public var count(get,never):UInt;
public function  get_count() : UInt
      {
         return this._count;
      }
      
      public function gc() 
      {
         var ok= false;
         var str:String = null;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            try
            {
               remoter.send("gc");
            }
            catch(e:Dynamic)
            {
               report(e,10);
            }
         }
         else
         {
            try
            {
               if((System : ASAny)["gc"] != null)
               {
                  (System : ASAny)["gc"]();
                  ok = true;
               }
            }
            catch(e:Dynamic)
            {
            }
            str = "Manual garbage collection " + (ok ? "successful." : "FAILED. You need debugger version of flash player.");
            report(str,ok ? -1 : 10);
         }
      }
   }


