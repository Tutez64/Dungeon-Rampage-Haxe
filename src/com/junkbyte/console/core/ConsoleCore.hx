package com.junkbyte.console.core
;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import flash.events.EventDispatcher;
   
    class ConsoleCore extends EventDispatcher
   {
      
      var console:Console;
      
      var config:ConsoleConfig;
      
      public function new(param1:Console)
      {
         super();
         this.console = param1;
         this.config = this.console.config;
      }
      
      @:isVar var remoter(get,never):Remoting;
function  get_remoter() : Remoting
      {
         return this.console.remoter;
      }
      
      function report(param1:ASAny = "", param2:Int = 0, param3:Bool = true, param4:String = null) 
      {
         this.console.report(param1,param2,param3,param4);
      }
   }


