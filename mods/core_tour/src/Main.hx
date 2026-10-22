package mods.core_tour;

import actor.ActorGameObject;
import brain.gameObject.GameObject;
import brain.stateMachine.State;
import brain.stateMachine.StateMachine;
import modding.ModContext;
import mods.api.Context;
import mods.api.Mod;

/**
 * Checks what the core's generic events promise (docs/modding.md, lifecycle): nothing before `ready`,
 * each object ready once, an actor never before its floor, an object still whole while it goes, fields
 * only for ready objects, and a state machine's enter and exit in step. Events are many, so it counts
 * them and logs `ok` or `FAIL` per rule at `dispose`, with the first breach.
 */
class Main extends Mod {
	var core:ModContext;

	var readySeen:Bool = false;

	/** Ready and not gone, by id. */
	var live:Map<String, Bool> = new Map();

	/** Every id ever ready, to catch one announced twice. */
	var seen:Map<String, Bool> = new Map();

	var counts:Map<String, Int> = new Map();

	var breaches:Map<String, String> = new Map();

	var rules:Array<String> = [];

	override public function init(ctx:Context):Void {
		core = ctx.core;
		for (rule in [
			"nothing before ready",
			"ready once",
			"actor after its floor",
			"gone only once ready",
			"gone while whole",
			"fields only for ready objects",
			"state entered is current",
			"state exited is current"
		])
			rules.push(rule);
		core.onObjectReady(objectReady);
		core.onObjectGone(objectGone);
		core.onFieldReceived(fieldReceived);
		core.onStateEnter(stateEnter);
		core.onStateExit(stateExit);
	}

	override public function ready(ctx:Context):Void {
		readySeen = true;
	}

	override public function dispose():Void {
		for (rule in rules) {
			var breach = breaches.get(rule);
			core.log(breach == null ? "ok   " + rule : "FAIL " + rule + ": " + breach);
		}
		var parts = [];
		for (event in ["ready", "gone", "fields", "states"])
			parts.push(event + " " + count(event));
		core.log(parts.join(", "));
	}

	function objectReady(object:GameObject):Void {
		bump("ready");
		check("nothing before ready", readySeen, "an object before ready");
		var key = keyOf(object);
		check("ready once", !seen.exists(key), key + " twice");
		seen.set(key, true);
		live.set(key, true);
		if (Std.isOfType(object, ActorGameObject)) {
			var floor = (cast object : ActorGameObject).distributedDungeonFloor;
			check("actor after its floor", floor == null || live.exists(keyOf(floor)), key + " before its floor");
		}
	}

	function objectGone(object:GameObject):Void {
		bump("gone");
		var key = keyOf(object);
		check("gone only once ready", live.exists(key), key);
		check("gone while whole", !object.isDestroyed, key + " already destroyed");
		live.remove(key);
	}

	function fieldReceived(object:GameObject, field:UInt):Void {
		bump("fields");
		check("fields only for ready objects", live.exists(keyOf(object)), keyOf(object) + " field " + field);
	}

	function stateEnter(machine:StateMachine, state:State):Void {
		bump("states");
		check("nothing before ready", readySeen, "a state before ready");
		check("state entered is current", machine.currentState == state, state.name);
	}

	function stateExit(machine:StateMachine, state:State):Void {
		check("nothing before ready", readySeen, "a state before ready");
		check("state exited is current", machine.currentState == state, state.name);
	}

	function keyOf(object:GameObject):String {
		return Type.getClassName(Type.getClass(object)) + "#" + object.id;
	}

	function bump(event:String):Void {
		counts.set(event, count(event) + 1);
	}

	function count(event:String):Int {
		var value = counts.get(event);
		return value == null ? 0 : value;
	}

	/** Keeps the first breach of each rule. */
	function check(rule:String, ok:Bool, breach:String):Void {
		if (!ok && !breaches.exists(rule))
			breaches.set(rule, breach);
	}
}
