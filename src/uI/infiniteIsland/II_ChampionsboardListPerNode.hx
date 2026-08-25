package uI.infiniteIsland;

class II_ChampionsboardListPerNode {
	var mListOfTopScores:Vector<II_ChampionsboardTopScore>;

	public function new(json:ASObject) {
		mListOfTopScores = new Vector<II_ChampionsboardTopScore>();
		var _loc2_:ASObject;
		if (checkNullIteratee(json))
			for (_tmp_ in iterateDynamicValues(json)) {
				_loc2_ = _tmp_;
				if (ASCompat.toBool(_loc2_.name)) {
					mListOfTopScores.push(new II_ChampionsboardTopScore(_loc2_.name, ASCompat.toInt(_loc2_.score),
						ASCompat.toInt(_loc2_.active_skin != null ? ASCompat.toInt(_loc2_.active_skin) : 151), _loc2_.weapon1, _loc2_.weapon2, _loc2_.weapon3));
				} else {
					mListOfTopScores.push(new II_ChampionsboardTopScore(_loc2_.account_id, ASCompat.toInt(_loc2_.score),
						ASCompat.toInt(_loc2_.active_skin != null ? ASCompat.toInt(_loc2_.active_skin) : 151), _loc2_.weapon1, _loc2_.weapon2, _loc2_.weapon3));
				}
			}
	}

	public function getTotalScores():Int {
		return mListOfTopScores.length;
	}

	public function getTopScoreForNum(i:Int):II_ChampionsboardTopScore {
		return mListOfTopScores[i];
	}

	public function sort() {
		ASCompat.ASVector.sort(mListOfTopScores, sortTopScores);
	}

	function sortTopScores(tS1:II_ChampionsboardTopScore, tS2:II_ChampionsboardTopScore):Int {
		return tS2.score - tS1.score;
	}
}
