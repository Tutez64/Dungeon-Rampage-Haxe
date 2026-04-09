package org.as3commons.collections.framework
;
    interface IList extends IOrder extends  IDuplicates
   {
      
      function removeAllAt(param1:UInt, param2:UInt) : Array<ASAny>;
      
      function add(param1:ASAny) : UInt;
      
      @:isVar var array(never,set):Array<ASAny>;
      
      function lastIndexOf(param1:ASAny) : Int;
      
      function itemAt(param1:UInt) : ASAny;
      
      function removeAt(param1:UInt) : ASAny;
      
      function firstIndexOf(param1:ASAny) : Int;
   }


