package com.greensock.core
;
    final class PropTween
   {
      
      public var priority:Int = 0;
      
      public var start:Float = Math.NaN;
      
      public var prevNode:PropTween;
      
      public var change:Float = Math.NaN;
      
      public var target:ASObject;
      
      public var name:String;
      
      public var property:String;
      
      public var nextNode:PropTween;
      
      public var isPlugin:Bool = false;
      
      public function new(param1:ASObject, param2:String, param3:Float, param4:Float, param5:String, param6:Bool, param7:PropTween = null, param8:Int = 0)
      {
         
         this.target = param1;
         this.property = param2;
         this.start = param3;
         this.change = param4;
         this.name = param5;
         this.isPlugin = param6;
         if(param7 != null)
         {
            param7.prevNode = this;
            this.nextNode = param7;
         }
         this.priority = param8;
      }
   }


