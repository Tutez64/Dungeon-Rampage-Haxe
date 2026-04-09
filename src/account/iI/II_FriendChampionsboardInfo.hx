package account.iI
;
   import com.maccherone.json.JSON;
   import org.as3commons.collections.Map;
   
    class II_FriendChampionsboardInfo
   {
      
      public var nodeIdToScore:Map;
      
      public var nodeIdToActiveSkin:Map;
      
      var mNodeIdToFriendInfoJson:Map;
      
      public function new(param1:ASObject)
      {
         
         nodeIdToScore = new Map();
         nodeIdToActiveSkin = new Map();
         mNodeIdToFriendInfoJson = new Map();
         updateMapnodeScore(param1);
      }
      
      public function updateMapnodeScore(param1:ASObject) 
      {
         var _loc2_:ASAny = null;
         nodeIdToScore.add(param1.mapnode_id,param1.score);
         nodeIdToActiveSkin.add(param1.mapnode_id,param1.active_skin);
         mNodeIdToFriendInfoJson.add(param1.mapnode_id,param1);
      }
      
      public function getWeaponsForNodeId(param1:UInt) : Array<Dynamic>
      {
         var _loc3_:ASObject = null;
         var _loc2_= new Array<Dynamic>();
         if(mNodeIdToFriendInfoJson.hasKey(param1))
         {
            _loc3_ = mNodeIdToFriendInfoJson.itemFor(param1);
            _loc2_.push(com.maccherone.json.JSON.decode(_loc3_.weapon1));
            _loc2_.push(com.maccherone.json.JSON.decode(_loc3_.weapon2));
            _loc2_.push(com.maccherone.json.JSON.decode(_loc3_.weapon3));
         }
         return _loc2_;
      }
   }


