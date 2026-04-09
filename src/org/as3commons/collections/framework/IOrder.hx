package org.as3commons.collections.framework
;
    interface IOrder extends ICollection
   {
      
      @:isVar var first(get,never):ASAny;
      
      function removeLast() : ASAny;
      
      function removeFirst() : ASAny;
      
      @:isVar var last(get,never):ASAny;
   }


