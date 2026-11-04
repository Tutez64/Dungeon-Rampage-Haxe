package gamemasterdictionary._gMHero;

class ExpToLevel {
	public var mTotalStatPoints:UInt = 0;

	public var mLevel:UInt = 0;

	public var mExperience:UInt = 0;

	public function new(level:UInt = (0 : UInt), experience:UInt = (0 : UInt), totalStatPoints:UInt = (0 : UInt)) {
		mLevel = level;
		mExperience = experience;
		mTotalStatPoints = totalStatPoints;
	}
}
