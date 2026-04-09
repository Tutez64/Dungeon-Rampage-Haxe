package org.as3commons.collections.framework
;
    interface ILinkedListIterator extends ICollectionIterator
   {
      
      function addBefore(param1:ASAny) : Void;
      
      function replace(param1:ASAny) : Bool;
      
      @:isVar var nextItem(get,never):ASAny;
      
      @:isVar var previousItem(get,never):ASAny;
      
      function addAfter(param1:ASAny) : Void;
   }


