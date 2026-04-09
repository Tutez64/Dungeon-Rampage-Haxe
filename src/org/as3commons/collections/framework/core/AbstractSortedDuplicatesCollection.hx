package org.as3commons.collections.framework.core
;
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IDuplicates;
   
   /*use*/ /*namespace*/ /*as3commons_collections*/
   
    class AbstractSortedDuplicatesCollection extends AbstractSortedCollection implements IDuplicates
   {
      
      public function new(param1:IComparator)
      {
         super(param1);
      }
      
      public function removeAll(param1:ASAny) : UInt
      {
         var _loc4_:SortedNode = null;
         var _loc2_= firstEqualNode(param1);
         if(_loc2_ == null)
         {
            return (0 : UInt);
         }
         var _loc3_= (0 : UInt);
         while(_loc2_ != null)
         {
            if(_comparator.compare(param1,_loc2_.item) != 0)
            {
               break;
            }
            if(_loc2_.item == param1)
            {
               _loc4_ = /*as3commons_collections::*/nextNode_internal(_loc2_);
               removeNode(_loc2_);
               _loc2_ = _loc4_;
               _loc3_++;
            }
            else
            {
               _loc2_ = /*as3commons_collections::*/nextNode_internal(_loc2_);
            }
         }
         return _loc3_;
      }
      
      public function count(param1:ASAny) : UInt
      {
         var _loc2_= firstEqualNode(param1);
         if(_loc2_ == null)
         {
            return (0 : UInt);
         }
         var _loc3_= (0 : UInt);
         if(_loc2_.item == param1)
         {
            _loc3_++;
         }
         _loc2_ = /*as3commons_collections::*/nextNode_internal(_loc2_);
         while(_loc2_ != null)
         {
            if(_comparator.compare(param1,_loc2_.item) != 0)
            {
               break;
            }
            if(_loc2_.item == param1)
            {
               _loc3_++;
            }
            _loc2_ = /*as3commons_collections::*/nextNode_internal(_loc2_);
         }
         return _loc3_;
      }
   }


