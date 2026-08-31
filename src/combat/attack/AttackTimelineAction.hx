package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.workLoop.LogicalWorkComponent;
import facade.DBFacade;
import gameMasterDictionary.GMAttack;
import generatedCode.CombatResult;

class AttackTimelineAction {
	var mActorGameObject:ActorGameObject;

	var mActorView:ActorView;

	var mDBFacade:DBFacade;

	var mAttackType:UInt = 0;

	var mCombatResult:CombatResult;

	var mAttacker:ActorGameObject;

	var mGMAttack:GMAttack;

	var mWorkComponent:LogicalWorkComponent;

	var mTimeline:ScriptTimeline;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		mActorGameObject = actorGameObject;
		mActorView = actorView;
		mDBFacade = dbFacade;
		mWorkComponent = new LogicalWorkComponent(mDBFacade, "AttackTimelineAction");
	}

	@:isVar public var attackType(never, set):UInt;

	public function set_attackType(attack:UInt):UInt {
		if (mAttackType != attack) {
			mAttackType = attack;
			mGMAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(attack), gameMasterDictionary.GMAttack);
		}
		return attack;
	}

	@:isVar public var combatResult(never, set):CombatResult;

	public function set_combatResult(combatResult:CombatResult):CombatResult {
		return mCombatResult = combatResult;
	}

	@:isVar public var attacker(never, set):ActorGameObject;

	public function set_attacker(attackingActor:ActorGameObject):ActorGameObject {
		return mAttacker = attackingActor;
	}

	public function execute(timeline:ScriptTimeline) {
		mTimeline = timeline;
	}

	public function destroy() {
		mActorGameObject = null;
		mActorView = null;
		mDBFacade = null;
		mCombatResult = null;
		mAttacker = null;
		mGMAttack = null;
		if (mWorkComponent != null) {
			mWorkComponent.destroy();
			mWorkComponent = null;
		}
	}

	public function stop() {}
}
