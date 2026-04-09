package account.iI
;
   import org.as3commons.collections.Map;
   
    class II_AccountTopScoreInfo
   {
      
      public var accountIdToTopScoreMapnodeInfo:Map;
      
      public function new(param1:ASObject)
      {
         var _loc3_:ASAny = null;
         var _loc2_= 0;
         
         accountIdToTopScoreMapnodeInfo = new Map();
         if (checkNullIteratee(param1)) for (_tmp_ in iterateDynamicValues(param1))
         {
            _loc3_  = _tmp_;
            _loc2_ = ASCompat.toInt(_loc3_.account_id);
            if(accountIdToTopScoreMapnodeInfo.hasKey(_loc2_))
            {
               accountIdToTopScoreMapnodeInfo.itemFor(_loc2_).updateMapnodeScore(_loc3_);
            }
            else
            {
               accountIdToTopScoreMapnodeInfo.add(_loc2_,new II_FriendChampionsboardInfo(_loc3_));
            }
         }
      }
   }


