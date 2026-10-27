package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.logger.Logger;
import distributedObjects.DistributedDungeonFloor;
import facade.DBFacade;
import generatedCode.CombatResult;

class CombatResultAttackTimelineAction extends AttackTimelineAction {
	var mDungeonFloor:DistributedDungeonFloor;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, combatResult:CombatResult,
			dungeonFloor:DistributedDungeonFloor) {
		super(actorGameObject, actorView, dbFacade);
		mCombatResult = combatResult;
		mDungeonFloor = dungeonFloor;
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		var _loc2_ = mDungeonFloor.getActor(mCombatResult.attackee);
		if (_loc2_ == null) {
			Logger.warn("Tried to execute a combat result on an actor that is not on the dungeon floor.  Actor id: " + Std.string(mCombatResult.attackee));
			return;
		}
		_loc2_.ReceiveCombatResult(mCombatResult);
	}
}
