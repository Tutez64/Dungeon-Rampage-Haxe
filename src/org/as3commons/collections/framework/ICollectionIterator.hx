package org.as3commons.collections.framework
;
    interface ICollectionIterator extends IIterator
   {
      
      function hasPrevious() : Bool;
      
      function start() : Void;
      
      function remove() : Bool;
      
      function previous() : ASAny;
      
      @:isVar var current(get,never):ASAny;
      
      function end() : Void;
   }


