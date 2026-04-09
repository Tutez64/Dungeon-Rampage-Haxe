package pathfinding
;
    /*dynamic*/ class PriorityQueue extends ASArrayBase
   {
      
      public function new()
      {
         super();
      }
      
      override public function push(..._rest:ASAny) : UInt
      {
         var rest = ASCompat.restToArray(_rest);
         var _loc2_= super.push(rest[0]);
         this.sort(compare);
         return _loc2_;
      }
      
      public function front() : AstarGridNode
      {
         return ASCompat.dynamicAs((this : ASAny)[0], pathfinding.AstarGridNode);
      }
      
      override public function pop() : ASAny
      {
         return splice(0,1);
      }
      
      public function contains(param1:AstarGridNode) : Bool
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ != length)
         {
            if((this : ASAny)[_loc2_] == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      function compare(param1:AstarGridNode, param2:AstarGridNode) : Int
      {
         if(param1.f < param2.f)
         {
            return -1;
         }
         if(param1.f > param2.f)
         {
            return 1;
         }
         return 0;
      }
   }


