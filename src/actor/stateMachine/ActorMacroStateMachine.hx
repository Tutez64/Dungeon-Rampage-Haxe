package actor.stateMachine;

import actor.ActorGameObject;
import actor.ActorView;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import combat.attack.AttackTimeline;
import combat.attack.ScriptTimeline;
import facade.DBFacade;
import generatedCode.AttackChoreography;
import generatedCode.CombatResult;

class ActorMacroStateMachine extends ActorStateMachine {
	var mDefaultState:ActorDefaultState;

	var mDeadState:ActorDeadState;

	public function new(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView) {
		super(dbFacade, actorGameObject, actorView);
		mDefaultState = new ActorDefaultState(mDBFacade, mActorGameObject, mActorView);
		MemoryTracker.track(mDefaultState, "ActorDefaultState - created in ActorMacroStateMachine.ActorMacroStateMachine()");
		mDeadState = new ActorDeadState(mDBFacade, mActorGameObject, mActorView);
		MemoryTracker.track(mDeadState, "ActorDeadState - created in ActorMacroStateMachine.ActorMacroStateMachine()");
	}

	public function enterAttackChoreographyState(playSpeed:Float, targetActor:ActorGameObject, attackTimeline:AttackTimeline,
			attackChoreography:AttackChoreography, finishedCallback:ASFunction = null, stopCallback:ASFunction = null, loop:Bool = false) {
		attackTimeline.appendChoreography(attackChoreography);
		var _loc8_ = attackChoreography.loop == 1 ? true : false;
		attackTimeline.currentAttackType = attackChoreography.attack.attackType;
		attackTimeline.projectileMultiplier = (Std.int(attackChoreography.scalingMaxProjectiles) : UInt);
		enterChoreographyState(playSpeed, targetActor, attackTimeline, finishedCallback, stopCallback, loop);
	}

	public function enterCombatResultChoreographyState(playSpeed:Float, targetActor:ActorGameObject, scriptTimeline:ScriptTimeline, combatResult:CombatResult,
			attacker:ActorGameObject, finishedCallback:ASFunction = null, stopCallback:ASFunction = null, loop:Bool = false) {
		scriptTimeline.currentAttackType = combatResult.attack.attackType;
		scriptTimeline.currentCombatResult = combatResult;
		scriptTimeline.currentAttacker = attacker;
		enterChoreographyState(playSpeed, targetActor, scriptTimeline, finishedCallback, stopCallback, loop);
	}

	public function enterChoreographyState(playSpeed:Float, targetActor:ActorGameObject, scriptTimeline:ScriptTimeline, finishedCallback:ASFunction = null,
			stopCallback:ASFunction = null, loop:Bool = false, autoAim:Bool = false) {
		var _loc8_:ActorDefaultState = null;
		if (this.currentState == mDefaultState) {
			_loc8_ = ASCompat.dynamicAs(this.currentState, ActorDefaultState);
			scriptTimeline.autoAim = autoAim;
			_loc8_.enterChoreographyState(playSpeed, targetActor, scriptTimeline, finishedCallback, stopCallback, loop);
		} else {
			Logger.warn("Trying to enter a choreographyState when the macro state is not in the default state.");
		}
	}

	public function enterNavigationState() {
		var _loc1_:ActorDefaultState = null;
		if (this.currentState == mDefaultState) {
			_loc1_ = ASCompat.dynamicAs(this.currentState, ActorDefaultState);
			_loc1_.enterNavigationState();
		} else {
			Logger.warn("Trying to enter a choreographyState when the macro state is not in the default state.");
		}
	}

	@:isVar public var currentSubState(get, never):ActorState;

	public function get_currentSubState():ActorState {
		if (ASCompat.dynamicAs(this.currentState, ActorState) == mDefaultState) {
			return mDefaultState.currentSubState;
		}
		return null;
	}

	public function enterDeadState(finishedDeathCallback:ASFunction) {
		mDeadState.finishedCallback = finishedDeathCallback;
		this.transitionToState(mDeadState);
	}

	public function enterDefaultState() {
		this.transitionToState(mDefaultState);
	}

	override public function destroy() {
		mDefaultState.destroy();
		mDefaultState = null;
		mDeadState.destroy();
		mDeadState = null;
		super.destroy();
	}
}
