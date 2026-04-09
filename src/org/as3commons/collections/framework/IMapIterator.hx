package org.as3commons.collections.framework
;
    interface IMapIterator extends ICollectionIterator
   {
      
      @:isVar var previousKey(get,never):ASAny;
      
      @:isVar var nextKey(get,never):ASAny;
      
      @:isVar var key(get,never):ASAny;
   }


