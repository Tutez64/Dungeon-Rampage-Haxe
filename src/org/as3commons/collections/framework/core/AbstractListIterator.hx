package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.framework.IListIterator;
   import org.as3commons.collections.iterators.ArrayIterator;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class AbstractListIterator extends ArrayIterator implements IListIterator
   {
      
      var _list:AbstractList;
      
      public function new(param1:AbstractList, param2:UInt = (0 : UInt))
      {
         this._list = param1;
         super(this._list/*as3commons_collections::*/.array_internal,param2);
      }
      
      override function removeCurrent() 
      {
         this._list.removeAt((_current : UInt));
      }
   }


