package org.as3commons.collections.framework
;
    interface IOrderedList extends IList extends  IInsertionOrder
   {
      
      function addAt(param1:UInt, param2:ASAny) : Bool;
      
      function replaceAt(param1:UInt, param2:ASAny) : Bool;
      
      function addAllAt(param1:UInt, param2:Array<ASAny>) : Bool;
      
      function addLast(param1:ASAny) : Void;
      
      function addFirst(param1:ASAny) : Void;
   }


