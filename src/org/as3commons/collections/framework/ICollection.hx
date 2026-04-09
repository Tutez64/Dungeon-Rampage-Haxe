package org.as3commons.collections.framework
;
    interface ICollection extends IIterable
   {
      
      @:isVar var size(get,never):UInt;
      
      function remove(param1:ASAny) : Bool;
      
      function has(param1:ASAny) : Bool;
      
      function clear() : Bool;
      
      function toArray() : Array<ASAny>;
   }


