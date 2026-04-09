package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.SortedMap;
   import org.as3commons.collections.framework.IMapIterator;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class SortedMapIterator extends AbstractSortedCollectionIterator implements IMapIterator
   {
      
      public function new(param1:SortedMap, param2:SortedMapNode)
      {
         super(param1,param2);
      }
      
      @:isVar public var previousKey(get,never):ASAny;
public function  get_previousKey() : ASAny
      {
         var _loc1_:SortedMapNode = null;
         if(_next != null)
         {
            _loc1_ = ASCompat.reinterpretAs(_collection/*as3commons_collections::*/.previousNode_internal(_next) , SortedMapNode);
            return _loc1_ != null ? _loc1_.key : /*undefined*/null;
         }
         return _collection.size != 0 ? cast(_collection/*as3commons_collections::*/.mostRightNode_internal(), SortedMapNode).key : /*undefined*/null;
      }
      
      @:isVar public var nextKey(get,never):ASAny;
public function  get_nextKey() : ASAny
      {
         return _next != null ? cast(_next, SortedMapNode).key : /*undefined*/null;
      }
      
      @:isVar public var key(get,never):ASAny;
public function  get_key() : ASAny
      {
         return _current != null ? cast(_current, SortedMapNode).key : /*undefined*/null;
      }
   }


