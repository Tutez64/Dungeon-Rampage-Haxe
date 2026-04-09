package uI.infiniteIsland
;
    class II_ChampionsboardListPerNode
   {
      
      var mListOfTopScores:Vector<II_ChampionsboardTopScore>;
      
      public function new(param1:ASObject)
      {
         
         mListOfTopScores = new Vector<II_ChampionsboardTopScore>();
         var _loc2_:ASAny;
         if (checkNullIteratee(param1)) for (_tmp_ in iterateDynamicValues(param1))
         {
            _loc2_ = _tmp_;
            if(ASCompat.toBool(_loc2_.name))
            {
               mListOfTopScores.push(new II_ChampionsboardTopScore(_loc2_.name,ASCompat.toInt(_loc2_.score),ASCompat.toInt(_loc2_.active_skin != null ? ASCompat.toInt(_loc2_.active_skin) : 151),_loc2_.weapon1,_loc2_.weapon2,_loc2_.weapon3));
            }
            else
            {
               mListOfTopScores.push(new II_ChampionsboardTopScore(_loc2_.account_id,ASCompat.toInt(_loc2_.score),ASCompat.toInt(_loc2_.active_skin != null ? ASCompat.toInt(_loc2_.active_skin) : 151),_loc2_.weapon1,_loc2_.weapon2,_loc2_.weapon3));
            }
         }
      }
      
      public function getTotalScores() : Int
      {
         return mListOfTopScores.length;
      }
      
      public function getTopScoreForNum(param1:Int) : II_ChampionsboardTopScore
      {
         return mListOfTopScores[param1];
      }
      
      public function sort() 
      {
         ASCompat.ASVector.sort(mListOfTopScores, sortTopScores);
      }
      
      function sortTopScores(param1:II_ChampionsboardTopScore, param2:II_ChampionsboardTopScore) : Int
      {
         return param2.score - param1.score;
      }
   }


