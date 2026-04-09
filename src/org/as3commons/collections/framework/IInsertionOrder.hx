package org.as3commons.collections.framework
;
    interface IInsertionOrder extends IOrder
   {
      
      function reverse() : Bool;
      
      function sort(param1:IComparator) : Bool;
   }


