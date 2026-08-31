package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import facade.DBFacade;
import gameMasterDictionary.GMAttack;
import flash.geom.Vector3D;

class KnockBackTimelineAction extends AutoMoveTimelineAction {
	public static inline final TYPE = "knockback";

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		super(actorGameObject, actorView, dbFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade):KnockBackTimelineAction {
		if (actorGameObject.isOwner) {
			return new KnockBackTimelineAction(actorGameObject, actorView, dbFacade);
		}
		return null;
	}

	override public function execute(timeline:ScriptTimeline) {
		var _loc2_:Vector3D = null;
		var _loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(mAttackType), gameMasterDictionary.GMAttack);
		if (_loc3_ != null && mAttacker != null) {
			mDistance = _loc3_.Knockback;
			mDuration = _loc3_.KnockbackDur;
			_loc2_ = new Vector3D(mActorGameObject.worldCenter.x - mAttacker.worldCenter.x, mActorGameObject.worldCenter.y - mAttacker.worldCenter.y);
			mAngle = Math.atan2(_loc2_.y, _loc2_.x) * 180 / 3.141592653589793;
		}
		if (mDuration > 0) {
			super.execute(timeline);
		}
	}
}
