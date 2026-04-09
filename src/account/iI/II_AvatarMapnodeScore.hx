package account.iI
;
   import org.as3commons.collections.Map;
   
    class II_AvatarMapnodeScore
   {
      
      public var nodeIdToScore:Map;
      
      public function new(param1:ASObject)
      {
         
         nodeIdToScore = new Map();
         updateMapnodeScore(param1);
      }
      
      public function updateMapnodeScore(param1:ASObject) 
      {
         var _loc2_:ASAny = null;
         nodeIdToScore.add(ASCompat.toInt(param1.mapnode_id),ASCompat.toInt(param1.score));
      }
   }


