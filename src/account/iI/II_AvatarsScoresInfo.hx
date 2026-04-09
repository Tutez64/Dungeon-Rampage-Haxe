package account.iI
;
   import org.as3commons.collections.Map;
   
    class II_AvatarsScoresInfo
   {
      
      public var avatarIdToAvatarScore:Map;
      
      public var nodeIdToScore:Map;
      
      public function new(param1:ASObject)
      {
         var _loc3_:ASAny = null;
         var _loc2_= 0;
         
         avatarIdToAvatarScore = new Map();
         if (checkNullIteratee(param1)) for (_tmp_ in iterateDynamicValues(param1))
         {
            _loc3_  = _tmp_;
            _loc2_ = ASCompat.toInt(_loc3_.avatar_id);
            if(avatarIdToAvatarScore.hasKey(_loc2_))
            {
               avatarIdToAvatarScore.itemFor(_loc2_).updateMapnodeScore(_loc3_);
            }
            else
            {
               avatarIdToAvatarScore.add(_loc2_,new II_AvatarMapnodeScore(_loc3_));
            }
         }
      }
   }


