package org.as3commons.collections.framework
;
    interface IListIterator extends ICollectionIterator
   {
      
      @:isVar var index(get,never):Int;
      
      @:isVar var previousIndex(get,never):Int;
      
      @:isVar var nextIndex(get,never):Int;
   }


