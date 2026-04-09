package org.as3commons.collections.framework
;
    interface ISetIterator extends ICollectionIterator
   {
      
      @:isVar var previousItem(get,never):ASAny;
      
      @:isVar var nextItem(get,never):ASAny;
   }


