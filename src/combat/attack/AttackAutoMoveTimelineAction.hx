package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import distributedObjects.HeroGameObject;
import facade.DBFacade;

class AttackAutoMoveTimelineAction extends AutoMoveTimelineAction {
	public static inline final TYPE = "attackautomove";

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		super(actorGameObject, actorView, dbFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade):AttackAutoMoveTimelineAction {
		if (actorGameObject.isOwner) {
			return new AttackAutoMoveTimelineAction(actorGameObject, actorView, dbFacade);
		}
		return null;
	}

	override public function execute(timeline:ScriptTimeline) {
		var _loc2_:AttackTimeline = null;
		mAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(mAttackType), gameMasterDictionary.GMAttack);
		mDuration = mAttack.MoveDuration;
		mDistance = mAttack.MoveAmount;
		mAngle = mAttack.MoveAngle + mActorGameObject.heading;
		if (Std.isOfType(timeline, AttackTimeline)) {
			_loc2_ = ASCompat.reinterpretAs(timeline, AttackTimeline);
			if (Std.isOfType(mActorGameObject, HeroGameObject)) {
				mDuration = _loc2_.distanceScalingTime > 0 ? _loc2_.distanceScalingTime : mDuration;
				mDistance = _loc2_.distanceScalingHero > 0 ? _loc2_.distanceScalingHero : mDistance;
			}
		}
		if (mDuration > 0 && mDistance > 0) {
			super.execute(timeline);
		}
	}
}
