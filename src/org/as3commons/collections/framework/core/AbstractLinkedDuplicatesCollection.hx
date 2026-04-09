package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.framework.IDuplicates;
   
    class AbstractLinkedDuplicatesCollection extends AbstractLinkedCollection implements IDuplicates
   {
      
      public function new()
      {
         super();
      }
      
      public function removeAll(param1:ASAny) : UInt
      {
         var _loc4_:LinkedNode = null;
         var _loc2_= _size;
         var _loc3_= _first;
         while(_loc3_ != null)
         {
            _loc4_ = _loc3_.right;
            if(_loc3_.item == param1)
            {
               removeNode(_loc3_);
            }
            _loc3_ = _loc4_;
         }
         return _loc2_ - _size;
      }
      
      public function count(param1:ASAny) : UInt
      {
         var _loc2_= (0 : UInt);
         var _loc3_= _first;
         while(_loc3_ != null)
         {
            if(_loc3_.item == param1)
            {
               _loc2_++;
            }
            _loc3_ = _loc3_.right;
         }
         return _loc2_;
      }
   }


