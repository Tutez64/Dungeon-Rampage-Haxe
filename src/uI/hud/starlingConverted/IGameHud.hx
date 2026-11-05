package uI.hud.starlingConverted;

import actor.buffs.BuffGameObject;
import distributedObjects.HeroGameObjectOwner;
import distributedObjects.NPCGameObject;
import uI.UIChatLog;
import flash.display.MovieClip;
import flash.geom.Point;
import flash.geom.Vector3D;

interface IGameHud {
	function show():Void;

	function hide():Void;

	function destroy():Void;

	function detachHero():Void;

	function initializeHud(heroOwner:HeroGameObjectOwner):Void;

	function refreshHUD():Void;

	@:isVar var ownedHero(get, never):HeroGameObjectOwner;

	@:isVar var chatLog(get, never):UIChatLog;

	function useFlashChatBar(value:Bool):Void;

	@:isVar var floaterTextClass(get, never):Dynamic;

	@:isVar var teamLootDestination(get, never):Vector3D;

	@:isVar var profileDestination(get, never):Vector3D;

	@:isVar var coinsDestination(get, never):Vector3D;

	@:isVar var expDestination(get, never):Vector3D;

	@:isVar var crowdDestination(get, never):Vector3D;

	function offScreenPicChange(playerId:Int, picType:String):Void;

	function initControllerIcon(inActionName:String, inOwner:MovieClip, iconPosition:Vector3D, iconScale:Point):Void;

	function removeControllerIcons(inOwner:MovieClip):Void;

	function showHealthFullMessage():Void;

	function showManaFullMessage():Void;

	function registerPet(petNPC:NPCGameObject):Void;

	function unregisterPet(petNPC:NPCGameObject):Void;

	function openTeamLoot(chestId:UInt):Void;

	function hideStacks():Void;

	function setBasicCurrency(basicCurrency:Int):Void;

	function bulgeXpBar():Void;

	function bulgeProfileBox():Void;

	function hideBustSign():Void;

	function setWeaponHighlight(currentWeaponIndex:Int):Void;

	function hideNotEnoughMana():Void;

	function showNotEnoughMana():Void;

	function isInCooldown():Void;

	function startCooldown(currentWeaponIndex:Int, cooldownTime:Float):Void;

	function stopCooldown(currentWeaponIndex:Int):Void;

	function startConsumableCooldown(currentWeaponIndex:Int, cooldownTime:Float):Void;

	function stopConsumableCooldown(currentWeaponIndex:Int):Void;

	function decrementConsumableCount(slot:UInt):Void;

	function totalConsumableCountReached(slot:UInt):Void;

	function showText(localeTextName:String):Void;

	function showBuffDisplay(buffGO:BuffGameObject):Void;

	function updateBuffInstance(updatedBuffGO:BuffGameObject):Void;

	function handleMenuButtonPressed(index:UInt):Void;

	function clearExitMenu():Void;

	function suppressNextExitMenuToggle():Void;
}
