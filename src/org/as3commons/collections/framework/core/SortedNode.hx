package org.as3commons.collections.framework.core
;
    class SortedNode
   {
      
      static var _order:UInt = (0 : UInt);
      
      public var right:SortedNode;
      
      public var priority:UInt = 0;
      
      public var left:SortedNode;
      
      public var parent:SortedNode;
      
      public var order:UInt = 0;
      
      public var item:ASAny;
      
      public function new(param1:ASAny)
      {
         
         this.item = param1;
         this.priority = (Std.int(Math.random() * ASCompat.MAX_INT) : UInt);
         this.order = ++_order;
      }
   }


