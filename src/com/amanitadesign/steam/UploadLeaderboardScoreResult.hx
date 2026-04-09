package com.amanitadesign.steam
;
    class UploadLeaderboardScoreResult
   {
      
      public var success:Bool = false;
      
      public var leaderboardHandle:String;
      
      public var score:Int = 0;
      
      public var scoreChanged:Bool = false;
      
      public var newGlobalRank:Int = 0;
      
      public var previousGlobalRank:Int = 0;
      
      public function new()
      {
         
      }
   }


