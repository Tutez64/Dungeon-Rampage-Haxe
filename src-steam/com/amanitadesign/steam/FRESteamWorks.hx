package com.amanitadesign.steam;

import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
#if air
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
#end
import flash.utils.ByteArray;
#if (cpp && !air)
import steamwrap.api.Steam;
import steamwrap.api.Controller.ControllerAnalogActionData;
import steamwrap.api.Controller.ControllerDigitalActionData;
import steamwrap.api.Controller.EInputActionOrigin;
#if sys
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
#end
#end

class FRESteamWorks extends EventDispatcher {
	#if air
	var _ExtensionContext:ExtensionContext = ExtensionContext.createExtensionContext("com.amanitadesign.steam.FRESteamWorks", null);
	#end

	var _tm:Int = 0;

	var _redrawPixel:Sprite = null;

	var _redrawContainer:DisplayObjectContainer = null;

	var _color:UInt = 0;

	var _alwaysVisible:Bool = false;

	public var isReady:Bool = false;

	public function new(target:IEventDispatcher = null) {
		#if air
		_ExtensionContext.addEventListener("status", handleStatusEvent);
		#elseif (cpp && !air)
		Steam.whenGetAuthTicketForWebApiResponse = function(success:Bool, _handle:Int, responseCode:Int):Void {
			var ev = new SteamEvent(SteamEvent.STEAM_RESPONSE, SteamConstants.RESPONSE_OnGetAuthTicketForWebApiResponse, responseCode);
			dispatchEvent(ev);
		};
		#end
		super(target);
	}

	#if air
	function handleStatusEvent(event:StatusEvent) {
		var _loc4_ = ASCompat.toInt(event.code);
		var _loc2_ = ASCompat.toInt(event.level);
		var _loc3_ = new SteamEvent(SteamEvent.STEAM_RESPONSE, _loc4_, _loc2_);
		if (_redrawContainer != null && !_alwaysVisible && _loc4_ == 7) {
			if (_loc2_ == 1 && _redrawPixel == null) {
				addRedrawPixel();
			} else if (_loc2_ == 2 && _redrawPixel != null) {
				ASCompat.setTimeout(removeRedrawPixel, 3000);
			}
		}
		dispatchEvent(_loc3_);
	}
	#end

	function addRedrawPixel() {
		if (_redrawContainer == null || _redrawPixel != null) {
			return;
		}
		_redrawPixel = new Sprite();
		_redrawPixel.width = 1;
		_redrawPixel.height = 1;
		_redrawPixel.graphics.beginFill(_color);
		_redrawPixel.graphics.drawRect(0, 0, 1, 1);
		_redrawPixel.graphics.endFill();
		_redrawPixel.addEventListener("enterFrame", redrawPixel);
		_redrawContainer.addChild(_redrawPixel);
	}

	function removeRedrawPixel() {
		if (_redrawContainer == null || _redrawPixel == null) {
			return;
		}
		_redrawPixel.removeEventListener("enterFrame", redrawPixel);
		_redrawContainer.removeChild(_redrawPixel);
		_redrawPixel = null;
	}

	function redrawPixel(e:Event = null) {
		_redrawPixel.rotation += 1;
	}

	public function addOverlayWorkaround(container:DisplayObjectContainer, alwaysVisible:Bool = false, color:UInt = (0 : UInt)) {
		_redrawContainer = container;
		_alwaysVisible = alwaysVisible;
		_color = color;
		if (alwaysVisible) {
			addRedrawPixel();
		}
	}

	public function dispose() {
		ASCompat.clearInterval((_tm : UInt));
		#if air
		_ExtensionContext.removeEventListener("status", handleStatusEvent);
		_ExtensionContext.dispose();
		#elseif (cpp && !air)
		Steam.whenGetAuthTicketForWebApiResponse = null;
		if (Steam.active) {
			Steam.shutdown();
		}
		#end
	}

	public function init():Bool {
		#if air
		isReady = ASCompat.asBool(_ExtensionContext.call("AIRSteam_Init"));
		#elseif (cpp && !air)
		var appId = resolveSteamAppId();
		if (appId <= 0) {
			isReady = false;
		} else {
			Steam.init(appId);
			isReady = Steam.active;
		}
		#else
		isReady = false;
		#end
		if (isReady) {
			_tm = (ASCompat.setInterval(runCallbacks, 100) : Int);
		}
		return isReady;
	}

	function correctFilePath(path:String):String {
		if (ASCompat.stringAsBool(path) && path.indexOf("/") != -1) {
			path = path.split("\\").join("/");
		}
		return path;
	}

	public function getGlyphSVGForActionOrigin(eOrigin:String, flags:Int):String {
		#if air
		return correctFilePath(ASCompat.asString(_ExtensionContext.call("AIRSteam_GetGlyphSVGForActionOrigin", [eOrigin, flags])));
		#else
		return "";
		#end
	}

	public function getGlyphPNGForActionOrigin(eOrigin:String, eSize:Int, flags:Int):String {
		#if air
		return correctFilePath(ASCompat.asString(_ExtensionContext.call("AIRSteam_GetGlyphPNGForActionOrigin", [eOrigin, eSize, flags])));
		#elseif (cpp && !air)
		return Steam.controllers != null ? Steam.controllers.getGlyphForActionOrigin(cast parseHandle(eOrigin)) : "";
		#else
		return "";
		#end
	}

	public function runCallbacks():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RunCallbacks"));
		#elseif (cpp && !air)
		Steam.onEnterFrame();
		return true;
		#else
		return false;
		#end
	}

	public function getUserID():String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetUserID"));
		#elseif (cpp && !air)
		return Steam.getSteamID();
		#else
		return "";
		#end
	}

	public function getAppID():UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetAppID"));
		#elseif (cpp && !air)
		return (Steam.getAppID() : UInt);
		#else
		return (0 : UInt);
		#end
	}

	public function getAvailableGameLanguages():String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetAvailableGameLanguages"));
		#else
		return "";
		#end
	}

	public function getCurrentGameLanguage():String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetCurrentGameLanguage"));
		#else
		return "";
		#end
	}

	public function getPersonaName():String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetPersonaName"));
		#elseif (cpp && !air)
		return Steam.getPersonaName();
		#else
		return "";
		#end
	}

	public function restartAppIfNecessary(appID:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RestartAppIfNecessary", appID));
		#else
		return false;
		#end
	}

	public function getIPCountry():String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetIPCountry"));
		#else
		return "";
		#end
	}

	public function isSteamInBigPictureMode():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsSteamInBigPictureMode"));
		#else
		return false;
		#end
	}

	public function isSteamRunningOnSteamDeck():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsSteamRunningOnSteamDeck"));
		#else
		return false;
		#end
	}

	public function getServerRealTime():UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetServerRealTime"));
		#else
		return (0 : UInt);
		#end
	}

	public function getSecondsSinceAppActive():UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetSecondsSinceAppActive"));
		#else
		return (0 : UInt);
		#end
	}

	public function getEarliestPurchaseUnixTime(appID:String):UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetEarliestPurchaseUnixTime", appID));
		#else
		return (0 : UInt);
		#end
	}

	public function setAchievement(name:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetAchievement", name));
		#elseif (cpp && !air)
		return Steam.setAchievement(name);
		#else
		return false;
		#end
	}

	public function clearAchievement(name:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ClearAchievement", name));
		#else
		return false;
		#end
	}

	public function isAchievement(name:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsAchievement", name));
		#elseif (cpp && !air)
		return Steam.getAchievement(name);
		#else
		return false;
		#end
	}

	public function isAchievementEarned(name:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsAchievementEarned", name));
		#else
		return false;
		#end
	}

	public function getAchievementAchievedPercent(name:String):Float {
		#if air
		return ASCompat.asNumber(_ExtensionContext.call("AIRSteam_GetAchievementAchievedPercent", name));
		#else
		return 0;
		#end
	}

	public function getAchievementDisplayAttribute(name:String, attribute:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetAchievementDisplayAttribute", [name, attribute]));
		#else
		return "";
		#end
	}

	public function getAchievementIcon(name:String):BitmapData {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetAchievementIcon", name), BitmapData);
		#else
		return null;
		#end
	}

	public function getAchievementName(index:UInt):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetAchievementName", index));
		#else
		return "";
		#end
	}

	public function getNumAchievements():Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetNumAchievements"));
		#else
		return 0;
		#end
	}

	public function indicateAchievementProgress(name:String, currentProgress:Int, maxProgress:Int):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IndicateAchievementProgress", [name, currentProgress, maxProgress]));
		#else
		return false;
		#end
	}

	public function getStatInt(name:String):Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetStatInt", name));
		#elseif (cpp && !air)
		return Steam.getStatInt(name);
		#else
		return 0;
		#end
	}

	public function getStatFloat(name:String):Float {
		#if air
		return ASCompat.asNumber(_ExtensionContext.call("AIRSteam_GetStatFloat", name));
		#else
		return 0;
		#end
	}

	public function setStatInt(name:String, value:Int):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetStatInt", [name, value]));
		#elseif (cpp && !air)
		return Steam.setStatInt(name, value);
		#else
		return false;
		#end
	}

	public function setStatFloat(name:String, value:Float):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetStatFloat", [name, value]));
		#else
		return false;
		#end
	}

	public function storeStats():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_StoreStats"));
		#elseif (cpp && !air)
		var result = Steam.storeStats();
		if (result) {
			dispatchEvent(new SteamEvent(SteamEvent.STEAM_RESPONSE, 1, 1));
		}
		return result;
		#else
		return false;
		#end
	}

	public function resetAllStats(achievementsToo:Bool):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ResetAllStats", achievementsToo));
		#else
		return false;
		#end
	}

	public function requestGlobalStats(historyDays:Int):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RequestGlobalStats", historyDays));
		#else
		return false;
		#end
	}

	public function getGlobalStatInt(name:String):Float {
		#if air
		return ASCompat.asNumber(_ExtensionContext.call("AIRSteam_GetGlobalStatInt", name));
		#else
		return 0;
		#end
	}

	public function getGlobalStatFloat(name:String):Float {
		#if air
		return ASCompat.asNumber(_ExtensionContext.call("AIRSteam_GetGlobalStatFloat", name));
		#else
		return 0;
		#end
	}

	public function getGlobalStatHistoryInt(name:String, days:Int):Array<ASAny> {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetGlobalStatHistoryInt", [name, days]), Array);
		#else
		return [];
		#end
	}

	public function getGlobalStatHistoryFloat(name:String, days:Int):Array<ASAny> {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetGlobalStatHistoryFloat", [name, days]), Array);
		#else
		return [];
		#end
	}

	public function findLeaderboard(name:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FindLeaderboard", name));
		#else
		return false;
		#end
	}

	public function findOrCreateLeaderboard(name:String, sortMethod:UInt, displayType:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FindOrCreateLeaderboard", [name, sortMethod, displayType]));
		#else
		return false;
		#end
	}

	public function findLeaderboardResult():String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_FindLeaderboardResult"));
		#else
		return "";
		#end
	}

	public function getLeaderboardName(handle:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetLeaderboardName", handle));
		#else
		return "";
		#end
	}

	public function getLeaderboardEntryCount(handle:String):Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetLeaderboardEntryCount", handle));
		#else
		return 0;
		#end
	}

	public function getLeaderboardSortMethod(handle:String):UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetLeaderboardSortMethod", handle));
		#else
		return (0 : UInt);
		#end
	}

	public function getLeaderboardDisplayType(handle:String):UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetLeaderboardDisplayType", handle));
		#else
		return (0 : UInt);
		#end
	}

	public function uploadLeaderboardScore(handle:String, method:UInt, score:Int, details:Array<ASAny> = null):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UploadLeaderboardScore", [handle, method, score, details]));
		#else
		return false;
		#end
	}

	public function uploadLeaderboardScoreResult():UploadLeaderboardScoreResult {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_UploadLeaderboardScoreResult"), UploadLeaderboardScoreResult);
		#else
		return null;
		#end
	}

	public function downloadLeaderboardEntries(handle:String, request:UInt = (1 : UInt), rangeStart:Int = -4, rangeEnd:Int = 5):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_DownloadLeaderboardEntries", [handle, request, rangeStart, rangeEnd]));
		#else
		return false;
		#end
	}

	public function downloadLeaderboardEntriesResult(numDetails:Int = 0):Array<ASAny> {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_DownloadLeaderboardEntriesResult", numDetails), Array);
		#else
		return [];
		#end
	}

	public function getFileCount():Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetFileCount"));
		#else
		return 0;
		#end
	}

	public function getFileSize(name:String):Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetFileSize", name));
		#else
		return 0;
		#end
	}

	public function fileExists(name:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FileExists", name));
		#else
		return false;
		#end
	}

	public function fileWrite(name:String, data:ByteArray):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FileWrite", [name, data]));
		#else
		return false;
		#end
	}

	public function fileRead(name:String, data:ByteArray):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FileRead", [name, data]));
		#else
		return false;
		#end
	}

	public function fileDelete(name:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FileDelete", name));
		#else
		return false;
		#end
	}

	public function fileShare(name:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FileShare", name));
		#else
		return false;
		#end
	}

	public function fileShareResult():String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_FileShareResult"));
		#else
		return "";
		#end
	}

	public function isCloudEnabledForApp():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsCloudEnabledForApp"));
		#else
		return false;
		#end
	}

	public function setCloudEnabledForApp(enabled:Bool):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetCloudEnabledForApp", enabled));
		#else
		return false;
		#end
	}

	public function getQuota():Array<ASAny> {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetQuota"), Array);
		#else
		return [];
		#end
	}

	public function UGCDownload(handle:String, priority:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UGCDownload", [handle, priority]));
		#else
		return false;
		#end
	}

	public function UGCRead(handle:String, size:Int, offset:UInt, data:ByteArray):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UGCRead", [handle, size, offset, data]));
		#else
		return false;
		#end
	}

	public function getUGCDownloadProgress(handle:String):Array<ASAny> {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetUGCDownloadProgress", handle), Array);
		#else
		return [];
		#end
	}

	public function getUGCDownloadResult(handle:String):DownloadUGCResult {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetUGCDownloadResult", handle), DownloadUGCResult);
		#else
		return null;
		#end
	}

	public function publishWorkshopFile(name:String, preview:String, appId:UInt, title:String, description:String, visibility:UInt, tags:Array<ASAny>,
			fileType:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_PublishWorkshopFile", [name, preview, appId, title, description, visibility, tags, fileType]));
		#else
		return false;
		#end
	}

	public function publishWorkshopFileResult():String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_PublishWorkshopFileResult"));
		#else
		return "";
		#end
	}

	public function deletePublishedFile(file:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_DeletePublishedFile", file));
		#else
		return false;
		#end
	}

	public function getPublishedFileDetails(file:String, maxAge:UInt = (0 : UInt)):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_GetPublishedFileDetails", [file, maxAge]));
		#else
		return false;
		#end
	}

	public function getPublishedFileDetailsResult(file:String):FileDetailsResult {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetPublishedFileDetailsResult", file), FileDetailsResult);
		#else
		return null;
		#end
	}

	public function enumerateUserPublishedFiles(startIndex:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EnumerateUserPublishedFiles", startIndex));
		#else
		return false;
		#end
	}

	public function enumerateUserPublishedFilesResult():UserFilesResult {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_EnumerateUserPublishedFilesResult"), UserFilesResult);
		#else
		return null;
		#end
	}

	public function enumeratePublishedWorkshopFiles(type:UInt, start:UInt, count:UInt, days:UInt, tags:Array<ASAny>, userTags:Array<ASAny>):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EnumeratePublishedWorkshopFiles", [type, start, count, days, tags, userTags]));
		#else
		return false;
		#end
	}

	public function enumeratePublishedWorkshopFilesResult():WorkshopFilesResult {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_EnumeratePublishedWorkshopFilesResult"), WorkshopFilesResult);
		#else
		return null;
		#end
	}

	public function enumerateUserSubscribedFiles(startIndex:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EnumerateUserSubscribedFiles", startIndex));
		#else
		return false;
		#end
	}

	public function enumerateUserSubscribedFilesResult():SubscribedFilesResult {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_EnumerateUserSubscribedFilesResult"), SubscribedFilesResult);
		#else
		return null;
		#end
	}

	public function enumerateUserSharedWorkshopFiles(steamID:String, start:UInt, required:Array<ASAny>, excluded:Array<ASAny>):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EnumerateUserSharedWorkshopFiles", [steamID, start, required, excluded]));
		#else
		return false;
		#end
	}

	public function enumerateUserSharedWorkshopFilesResult():UserFilesResult {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_EnumerateUserSharedWorkshopFilesResult"), UserFilesResult);
		#else
		return null;
		#end
	}

	public function enumeratePublishedFilesByUserAction(action:UInt, startIndex:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EnumeratePublishedFilesByUserAction", [action, startIndex]));
		#else
		return false;
		#end
	}

	public function enumeratePublishedFilesByUserActionResult():FilesByUserActionResult {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_EnumeratePublishedFilesByUserActionResult"), FilesByUserActionResult);
		#else
		return null;
		#end
	}

	public function subscribePublishedFile(file:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SubscribePublishedFile", file));
		#else
		return false;
		#end
	}

	public function unsubscribePublishedFile(file:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UnsubscribePublishedFile", file));
		#else
		return false;
		#end
	}

	public function createPublishedFileUpdateRequest(file:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_CreatePublishedFileUpdateRequest", file));
		#else
		return "";
		#end
	}

	public function updatePublishedFileFile(handle:String, file:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileFile", [handle, file]));
		#else
		return false;
		#end
	}

	public function updatePublishedFilePreviewFile(handle:String, preview:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFilePreviewFile", [handle, preview]));
		#else
		return false;
		#end
	}

	public function updatePublishedFileTitle(handle:String, title:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileTitle", [handle, title]));
		#else
		return false;
		#end
	}

	public function updatePublishedFileDescription(handle:String, description:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileDescription", [handle, description]));
		#else
		return false;
		#end
	}

	public function updatePublishedFileSetChangeDescription(handle:String, changeDesc:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileSetChangeDescription", [handle, changeDesc]));
		#else
		return false;
		#end
	}

	public function updatePublishedFileVisibility(handle:String, visibility:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileVisibility", [handle, visibility]));
		#else
		return false;
		#end
	}

	public function updatePublishedFileTags(handle:String, tags:Array<ASAny>):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileTags", [handle, tags]));
		#else
		return false;
		#end
	}

	public function commitPublishedFileUpdate(handle:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_CommitPublishedFileUpdate", handle));
		#else
		return false;
		#end
	}

	public function getPublishedItemVoteDetails(file:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_GetPublishedItemVoteDetails", file));
		#else
		return false;
		#end
	}

	public function getPublishedItemVoteDetailsResult():ItemVoteDetailsResult {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetPublishedItemVoteDetailsResult"), ItemVoteDetailsResult);
		#else
		return null;
		#end
	}

	public function getUserPublishedItemVoteDetails(file:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_GetUserPublishedItemVoteDetails", file));
		#else
		return false;
		#end
	}

	public function getUserPublishedItemVoteDetailsResult():UserVoteDetails {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetUserPublishedItemVoteDetailsResult"), UserVoteDetails);
		#else
		return null;
		#end
	}

	public function updateUserPublishedItemVote(file:String, upvote:Bool):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdateUserPublishedItemVote", [file, upvote]));
		#else
		return false;
		#end
	}

	public function setUserPublishedFileAction(file:String, action:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetUserPublishedFileAction", [file, action]));
		#else
		return false;
		#end
	}

	public function getFriendCount(flags:UInt):Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetFriendCount", flags));
		#else
		return 0;
		#end
	}

	public function getFriendByIndex(index:Int, flags:UInt):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetFriendByIndex", [index, flags]));
		#else
		return "";
		#end
	}

	public function getFriendPersonaName(id:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetFriendPersonaName", id));
		#else
		return "";
		#end
	}

	public function getSmallFriendAvatar(id:String):BitmapData {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetSmallFriendAvatar", id), BitmapData);
		#else
		return null;
		#end
	}

	public function getMediumFriendAvatar(id:String):BitmapData {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetMediumFriendAvatar", id), BitmapData);
		#else
		return null;
		#end
	}

	public function getLargeFriendAvatar(id:String):BitmapData {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetLargeFriendAvatar", id), BitmapData);
		#else
		return null;
		#end
	}

	public function setRichPresence(key:String, value:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetRichPresence", [key, value]));
		#else
		return false;
		#end
	}

	public function clearRichPresence():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ClearRichPresence"));
		#else
		return false;
		#end
	}

	public function setPlayedWith(steamID:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetPlayedWith", steamID));
		#else
		return false;
		#end
	}

	public function getCoplayFriendCount():Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetCoplayFriendCount"));
		#else
		return 0;
		#end
	}

	public function getCoplayFriend(index:Int):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetCoplayFriend", index));
		#else
		return "";
		#end
	}

	public function getAuthSessionTicket(ticket:ByteArray, steamID:String):UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetAuthSessionTicket", [ticket, steamID]));
		#else
		return (0 : UInt);
		#end
	}

	public function getAuthSessionTicketResult():UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetAuthSessionTicketResult"));
		#else
		return (0 : UInt);
		#end
	}

	public function beginAuthSession(ticket:ByteArray, steamID:String):Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_BeginAuthSession", [ticket, steamID]));
		#else
		return 0;
		#end
	}

	public function endAuthSession(steamID:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EndAuthSession", steamID));
		#else
		return false;
		#end
	}

	public function cancelAuthTicket(ticketHandle:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_CancelAuthTicket", ticketHandle));
		#elseif (cpp && !air)
		return Steam.cancelAuthTicket((ticketHandle : Int));
		#else
		return false;
		#end
	}

	public function userHasLicenseForApp(steamID:String, appID:UInt):Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_UserHasLicenseForApp", [steamID, appID]));
		#else
		return 0;
		#end
	}

	public function requestEncryptedAppTicket(secretData:ByteArray):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RequestEncryptedAppTicket", secretData));
		#else
		return false;
		#end
	}

	public function getEncryptedAppTicket(ticket:ByteArray):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_GetEncryptedAppTicket", ticket));
		#else
		return false;
		#end
	}

	public function getAuthTicketForWebApi(identity:String = ""):UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetAuthTicketForWebApi", identity));
		#elseif (cpp && !air)
		return (Steam.getAuthTicketForWebApi(identity) : UInt);
		#else
		return (0 : UInt);
		#end
	}

	public function getAuthTicketForWebApiResultHandle():UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetAuthTicketForWebApiResultHandle"));
		#elseif (cpp && !air)
		return (Steam.getAuthTicketForWebApiResultHandle() : UInt);
		#else
		return (0 : UInt);
		#end
	}

	public function getAuthTicketForWebApiResultHexString():String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetAuthTicketForWebApiResultHexString"));
		#elseif (cpp && !air)
		return Steam.getAuthTicketForWebApiResultHexString();
		#else
		return "";
		#end
	}

	public function activateGameOverlay(dialog:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateGameOverlay", dialog));
		#else
		return false;
		#end
	}

	public function activateGameOverlayToUser(dialog:String, steamId:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateGameOverlayToUser", [dialog, steamId]));
		#else
		return false;
		#end
	}

	public function activateGameOverlayToWebPage(url:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateGameOverlayToWebPage", url));
		#elseif (cpp && !air)
		Steam.openOverlayToURL(url);
		return true;
		#else
		return false;
		#end
	}

	public function activateGameOverlayToStore(appId:UInt, flag:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateGameOverlayToStore", [appId, flag]));
		#elseif (cpp && !air)
		return Steam.activateGameOverlayToStore((appId : Int), (flag : Int));
		#else
		return false;
		#end
	}

	public function activateGameOverlayInviteDialog(steamIdLobby:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateGameOverlayInviteDialog", steamIdLobby));
		#else
		return false;
		#end
	}

	public function isOverlayEnabled():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsOverlayEnabled"));
		#elseif (cpp && !air)
		return Steam.isOverlayEnabled();
		#else
		return false;
		#end
	}

	public function setOverlayNotificationPosition(position:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetOverlayNotificationPosition", position));
		#else
		return false;
		#end
	}

	public function setOverlayNotificationInset(hInset:Int, vInset:Int):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetOverlayNotificationInset", [hInset, vInset]));
		#else
		return false;
		#end
	}

	public function overlayNeedsPresent():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_OverlayNeedsPresent"));
		#else
		return false;
		#end
	}

	public function isSubscribedApp(appId:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsSubscribedApp", appId));
		#else
		return false;
		#end
	}

	public function isDLCInstalled(appId:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsDLCInstalled", appId));
		#else
		return false;
		#end
	}

	public function getDLCCount():Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetDLCCount"));
		#else
		return 0;
		#end
	}

	public function installDLC(appId:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_InstallDLC", appId));
		#else
		return false;
		#end
	}

	public function uninstallDLC(appId:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UninstallDLC", appId));
		#else
		return false;
		#end
	}

	public function DLCInstalledResult():UInt {
		#if air
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_DLCInstalledResult"));
		#else
		return (0 : UInt);
		#end
	}

	public function microTxnResult():MicroTxnAuthorizationResponse {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_MicroTxnResult"), MicroTxnAuthorizationResponse);
		#else
		return null;
		#end
	}

	public function inputInit():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_InputInit"));
		#elseif (cpp && !air)
		return Steam.active && Steam.controllers != null && Steam.controllers.active;
		#else
		return false;
		#end
	}

	public function setInputActionManifestFilePath(inputActionManifestAbsolutePath:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetInputActionManifestFilePath", inputActionManifestAbsolutePath));
		#else
		return false;
		#end
	}

	public function getControllerForGamepadIndex(index:Int):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetControllerForGamepadIndex", index));
		#else
		return "";
		#end
	}

	public function showBindingPanel(inputHandle:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ShowBindingPanel", inputHandle));
		#else
		return false;
		#end
	}

	public function getActionSetHandle(actionSetName:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetActionSetHandle", actionSetName));
		#elseif (cpp && !air)
		return actionHandleToString(Steam.controllers != null ? Steam.controllers.getActionSetHandle(actionSetName) : -1);
		#else
		return "";
		#end
	}

	public function getDigitalActionHandle(actionName:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetDigitalActionHandle", actionName));
		#elseif (cpp && !air)
		return actionHandleToString(Steam.controllers != null ? Steam.controllers.getDigitalActionHandle(actionName) : -1);
		#else
		return "";
		#end
	}

	public function getAnalogActionHandle(actionName:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetAnalogActionHandle", actionName));
		#elseif (cpp && !air)
		return actionHandleToString(Steam.controllers != null ? Steam.controllers.getAnalogActionHandle(actionName) : -1);
		#else
		return "";
		#end
	}

	public function getDigitalActionButtonState(inputHandle:String, actionHandle:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_GetDigitalActionButtonState", [inputHandle, actionHandle]));
		#elseif (cpp && !air)
		if (Steam.controllers == null) {
			return false;
		}
		var data:ControllerDigitalActionData = Steam.controllers.getDigitalActionData(parseHandle(inputHandle), parseHandle(actionHandle));
		return data.bState;
		#else
		return false;
		#end
	}

	public function getDigitalActionButtonActive(inputHandle:String, actionHandle:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_GetDigitalActionButtonActive", [inputHandle, actionHandle]));
		#elseif (cpp && !air)
		if (Steam.controllers == null) {
			return false;
		}
		var data:ControllerDigitalActionData = Steam.controllers.getDigitalActionData(parseHandle(inputHandle), parseHandle(actionHandle));
		return data.bActive;
		#else
		return false;
		#end
	}

	public function getAnalogActionData(inputHandle:String, actionHandle:String):InputAnalogActionData {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetAnalogActionData", [inputHandle, actionHandle]), InputAnalogActionData);
		#elseif (cpp && !air)
		var result = new InputAnalogActionData();
		if (Steam.controllers != null) {
			var data:ControllerAnalogActionData = Steam.controllers.getAnalogActionData(parseHandle(inputHandle), parseHandle(actionHandle));
			result.eMode = cast data.eMode;
			result.x = data.x;
			result.y = data.y;
			result.bActive = data.bActive != 0;
		}
		return result;
		#else
		return new InputAnalogActionData();
		#end
	}

	public function runFrame():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RunFrame"));
		#elseif (cpp && !air)
		// Steam Input's frame only, as the ANE: SteamWrap runs it in getConnectedControllers, which
		// the game calls next. Steam.onEnterFrame() would run every callback and read the network.
		return true;
		#else
		return false;
		#end
	}

	public function getConnectedControllers():Array<ASAny> {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetConnectedControllers"), Array);
		#elseif (cpp && !air)
		var result:Array<ASAny> = [];
		if (Steam.controllers != null) {
			for (controller in Steam.controllers.getConnectedControllers()) {
				result.push(Std.string(controller));
			}
		}
		return result;
		#else
		return [];
		#end
	}

	public function activateActionSet(inputHandle:String, actionSetHandle:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateActionSet", [inputHandle, actionSetHandle]));
		#elseif (cpp && !air)
		return Steam.controllers != null && Steam.controllers.activateActionSet(parseHandle(inputHandle), parseHandle(actionSetHandle)) != 0;
		#else
		return false;
		#end
	}

	public function getHandleAllControllers():String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetHandleAllControllers"));
		#else
		return "";
		#end
	}

	public function getDigitalActionOrigins(inputHandle:String, actionSetHandle:String, digitalActionHandle:String):Array<ASAny> {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetDigitalActionOrigins", [inputHandle, actionSetHandle, digitalActionHandle]), Array);
		#elseif (cpp && !air)
		var result:Array<ASAny> = [];
		if (Steam.controllers != null) {
			var origins:Array<EInputActionOrigin> = [];
			Steam.controllers.getDigitalActionOrigins(parseHandle(inputHandle), parseHandle(actionSetHandle), parseHandle(digitalActionHandle), origins);
			for (origin in origins) {
				// SteamWrap gives every slot of Steam's array: the empty ones hold k_EInputActionOrigin_None.
				if ((origin : Null<EInputActionOrigin>) != null) {
					var originId = Std.string(cast(origin, Int));
					if (originId != "0") {
						result.push(originId);
					}
				}
			}
		}
		return result;
		#else
		return [];
		#end
	}

	public function getAnalogActionOrigins(inputHandle:String, actionSetHandle:String, analogActionHandle:String):Array<ASAny> {
		#if air
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetAnalogActionOrigins", [inputHandle, actionSetHandle, analogActionHandle]), Array);
		#else
		return [];
		#end
	}

	public function getStringForActionOrigin(eOrigin:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetStringForActionOrigin", eOrigin));
		#else
		return "";
		#end
	}

	public function showGamepadTextInput(eInputMode:Int, eLineInputMode:Int, pchDescription:String, unCharMax:Int, pchExistingText:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ShowGamepadTextInput",
			[eInputMode, eLineInputMode, pchDescription, unCharMax, pchExistingText]));
		#else
		return false;
		#end
	}

	public function showFloatingGamepadTextInput(eKeyboardMode:Int, nTextFieldXPosition:Int, nTextFieldYPosition:Int, nTextFieldWidth:Int,
			nTextFieldHeight:Int):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ShowFloatingGamepadTextInput", [
			eKeyboardMode,
			nTextFieldXPosition,
			nTextFieldYPosition,
			nTextFieldWidth,
			nTextFieldHeight
		]));
		#else
		return false;
		#end
	}

	public function setLEDColor(inputHandle:String, colorR:Int, colorG:Int, colorB:Int, flags:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetLEDColor", [inputHandle, colorR, colorG, colorB, flags]));
		#elseif (cpp && !air)
		if (Steam.controllers == null) {
			return false;
		}
		Steam.controllers.setLEDColor(parseHandle(inputHandle), ((colorR & 0xFF) << 16) | ((colorG & 0xFF) << 8) | (colorB & 0xFF), flags);
		return true;
		#else
		return false;
		#end
	}

	public function triggerVibration(inputHandle:String, leftSpeed:UInt, rightSpeed:UInt):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_TriggerVibration", [inputHandle, leftSpeed, rightSpeed]));
		#elseif (cpp && !air)
		if (Steam.controllers == null) {
			return false;
		}
		Steam.controllers.triggerVibration(parseHandle(inputHandle), leftSpeed, rightSpeed);
		return true;
		#else
		return false;
		#end
	}

	public function getInputTypeForHandle(inputHandle:String):Int {
		#if air
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetInputTypeForHandle", inputHandle));
		#elseif (cpp && !air)
		return Steam.controllers != null ? Std.int(Steam.controllers.getInputTypeForHandle(parseHandle(inputHandle))) : 0;
		#else
		return 0;
		#end
	}

	public function translateActionOrigin(destinationInputType:Int, sourceOrigin:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_TranslateActionOrigin", [destinationInputType, sourceOrigin]));
		#else
		return sourceOrigin;
		#end
	}

	public function steamInputShutdown():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SteamInputShutdown"));
		#elseif (cpp && !air)
		if (Steam.controllers != null && Steam.controllers.active) {
			Steam.controllers.shutdown();
		}
		return true;
		#else
		return false;
		#end
	}

	public function dismissFloatingGamepadTextInput():Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_DismissFloatingGamepadTextInput"));
		#else
		return false;
		#end
	}

	public function getEnv(name:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetEnv", name));
		#else
		return "";
		#end
	}

	public function setEnv(name:String, value:String):Bool {
		#if air
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetEnv", [name, value]));
		#else
		return false;
		#end
	}

	public function getLaunchQueryParam(key:String):String {
		#if air
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetLaunchQueryParam", key));
		#else
		return "";
		#end
	}

	static function parseHandle(value:String):Int {
		var parsed = Std.parseInt(value);
		return parsed == null ? 0 : parsed;
	}

	static function actionHandleToString(value:Int):String {
		return value < 0 ? "0" : Std.string(value);
	}

	#if (cpp && !air && sys)
	function resolveSteamAppId():Int {
		var env = Sys.getEnv("STEAM_APP_ID");
		if (env != null) {
			var parsedEnv = Std.parseInt(StringTools.trim(env));
			if (parsedEnv != null && parsedEnv > 0) {
				return parsedEnv;
			}
		}

		var candidates = ["steam_appid.txt"];
		var programDir = Path.directory(Sys.programPath());
		if (programDir != null && programDir.length > 0) {
			candidates.push(Path.normalize(Path.join([programDir, "steam_appid.txt"])));
		}

		for (candidate in candidates) {
			if (FileSystem.exists(candidate)) {
				var content = File.getContent(candidate);
				var parsedFile = Std.parseInt(StringTools.trim(content));
				if (parsedFile != null && parsedFile > 0) {
					return parsedFile;
				}
			}
		}

		return 0;
	}
	#else
	function resolveSteamAppId():Int {
		return 0;
	}
	#end

}
