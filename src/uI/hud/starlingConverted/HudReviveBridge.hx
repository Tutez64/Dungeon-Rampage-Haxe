package uI.hud.starlingConverted;

import actor.stateMachine.ActorReviveState;
import collections.IMapIterator;
import distributedObjects.HeroGameObject;
import distributedObjects.HeroGameObjectOwner;
import facade.DBFacade;

class HudReviveBridge {
	public function new() {}

	public static function refresh(facade:DBFacade, hud:IGameHud, hero:HeroGameObjectOwner) {
		if (facade.hud != hud || hero == null || hud.ownedHero != hero) {
			return;
		}
		refreshActor(hud, hero);
		if (hero.distributedDungeonFloor == null) {
			return;
		}
		var _loc4_ = ASCompat.reinterpretAs(hero.distributedDungeonFloor.remoteHeroes.iterator(), IMapIterator);
		while (_loc4_.hasNext()) {
			refreshActor(hud, ASCompat.dynamicAs(_loc4_.next(), HeroGameObject));
		}
	}

	static function refreshActor(hud:IGameHud, hero:HeroGameObject) {
		if (hero == null || hero.stateMachine == null) {
			return;
		}
		var _loc3_ = ASCompat.dynamicAs(hero.stateMachine.currentState, ActorReviveState);
		if (_loc3_ != null) {
			_loc3_.refreshHudControllerIcons();
		}
	}
}
