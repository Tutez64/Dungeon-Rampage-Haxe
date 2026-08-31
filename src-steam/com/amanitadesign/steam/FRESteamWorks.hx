package com.amanitadesign.steam;

import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
import flash.utils.ByteArray;

class FRESteamWorks extends EventDispatcher {
	var _ExtensionContext:ExtensionContext = ExtensionContext.createExtensionContext("com.amanitadesign.steam.FRESteamWorks", null);

	var _tm:Int = 0;

	var _redrawPixel:Sprite = null;

	var _redrawContainer:DisplayObjectContainer = null;

	var _color:UInt = 0;

	var _alwaysVisible:Bool = false;

	public var isReady:Bool = false;

	public function new(target:IEventDispatcher = null) {
		_ExtensionContext.addEventListener("status", handleStatusEvent);
		super(target);
	}

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
		_ExtensionContext.removeEventListener("status", handleStatusEvent);
		_ExtensionContext.dispose();
	}

	public function init():Bool {
		isReady = ASCompat.asBool(_ExtensionContext.call("AIRSteam_Init"));
		if (isReady) {
			_tm = (ASCompat.setInterval(runCallbacks, 100) : Int);
		}
		return isReady;
	}

	public function runCallbacks():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RunCallbacks"));
	}

	public function getUserID():String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetUserID"));
	}

	public function getAppID():UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetAppID"));
	}

	public function getAvailableGameLanguages():String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetAvailableGameLanguages"));
	}

	public function getCurrentGameLanguage():String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetCurrentGameLanguage"));
	}

	public function getPersonaName():String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetPersonaName"));
	}

	public function restartAppIfNecessary(appID:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RestartAppIfNecessary", appID));
	}

	public function getIPCountry():String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetIPCountry"));
	}

	public function isSteamInBigPictureMode():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsSteamInBigPictureMode"));
	}

	public function isSteamRunningOnSteamDeck():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsSteamRunningOnSteamDeck"));
	}

	public function getServerRealTime():UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetServerRealTime"));
	}

	public function getSecondsSinceAppActive():UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetSecondsSinceAppActive"));
	}

	public function getEarliestPurchaseUnixTime(appID:String):UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetEarliestPurchaseUnixTime", appID));
	}

	public function requestStats():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RequestStats"));
	}

	public function setAchievement(name:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetAchievement", name));
	}

	public function clearAchievement(name:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ClearAchievement", name));
	}

	public function isAchievement(name:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsAchievement", name));
	}

	public function isAchievementEarned(name:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsAchievementEarned", name));
	}

	public function getAchievementAchievedPercent(name:String):Float {
		return ASCompat.asNumber(_ExtensionContext.call("AIRSteam_GetAchievementAchievedPercent", name));
	}

	public function getAchievementDisplayAttribute(name:String, attribute:String):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetAchievementDisplayAttribute", [name, attribute]));
	}

	public function getAchievementIcon(name:String):BitmapData {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetAchievementIcon", name), BitmapData);
	}

	public function getAchievementName(index:UInt):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetAchievementName", index));
	}

	public function getNumAchievements():Int {
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetNumAchievements"));
	}

	public function indicateAchievementProgress(name:String, currentProgress:Int, maxProgress:Int):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IndicateAchievementProgress", [name, currentProgress, maxProgress]));
	}

	public function getStatInt(name:String):Int {
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetStatInt", name));
	}

	public function getStatFloat(name:String):Float {
		return ASCompat.asNumber(_ExtensionContext.call("AIRSteam_GetStatFloat", name));
	}

	public function setStatInt(name:String, value:Int):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetStatInt", [name, value]));
	}

	public function setStatFloat(name:String, value:Float):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetStatFloat", [name, value]));
	}

	public function storeStats():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_StoreStats"));
	}

	public function resetAllStats(achievementsToo:Bool):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ResetAllStats", achievementsToo));
	}

	public function requestGlobalStats(historyDays:Int):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RequestGlobalStats", historyDays));
	}

	public function getGlobalStatInt(name:String):Float {
		return ASCompat.asNumber(_ExtensionContext.call("AIRSteam_GetGlobalStatInt", name));
	}

	public function getGlobalStatFloat(name:String):Float {
		return ASCompat.asNumber(_ExtensionContext.call("AIRSteam_GetGlobalStatFloat", name));
	}

	public function getGlobalStatHistoryInt(name:String, days:Int):Array<ASAny> {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetGlobalStatHistoryInt", [name, days]), Array);
	}

	public function getGlobalStatHistoryFloat(name:String, days:Int):Array<ASAny> {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetGlobalStatHistoryFloat", [name, days]), Array);
	}

	public function findLeaderboard(name:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FindLeaderboard", name));
	}

	public function findOrCreateLeaderboard(name:String, sortMethod:UInt, displayType:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FindOrCreateLeaderboard", [name, sortMethod, displayType]));
	}

	public function findLeaderboardResult():String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_FindLeaderboardResult"));
	}

	public function getLeaderboardName(handle:String):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetLeaderboardName", handle));
	}

	public function getLeaderboardEntryCount(handle:String):Int {
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetLeaderboardEntryCount", handle));
	}

	public function getLeaderboardSortMethod(handle:String):UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetLeaderboardSortMethod", handle));
	}

	public function getLeaderboardDisplayType(handle:String):UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetLeaderboardDisplayType", handle));
	}

	public function uploadLeaderboardScore(handle:String, method:UInt, score:Int, details:Array<ASAny> = null):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UploadLeaderboardScore", [handle, method, score, details]));
	}

	public function uploadLeaderboardScoreResult():UploadLeaderboardScoreResult {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_UploadLeaderboardScoreResult"), UploadLeaderboardScoreResult);
	}

	public function downloadLeaderboardEntries(handle:String, request:UInt = (1 : UInt), rangeStart:Int = -4, rangeEnd:Int = 5):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_DownloadLeaderboardEntries", [handle, request, rangeStart, rangeEnd]));
	}

	public function downloadLeaderboardEntriesResult(numDetails:Int = 0):Array<ASAny> {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_DownloadLeaderboardEntriesResult", numDetails), Array);
	}

	public function getFileCount():Int {
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetFileCount"));
	}

	public function getFileSize(name:String):Int {
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetFileSize", name));
	}

	public function fileExists(name:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FileExists", name));
	}

	public function fileWrite(name:String, data:ByteArray):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FileWrite", [name, data]));
	}

	public function fileRead(name:String, data:ByteArray):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FileRead", [name, data]));
	}

	public function fileDelete(name:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FileDelete", name));
	}

	public function fileShare(name:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_FileShare", name));
	}

	public function fileShareResult():String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_FileShareResult"));
	}

	public function isCloudEnabledForApp():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsCloudEnabledForApp"));
	}

	public function setCloudEnabledForApp(enabled:Bool):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetCloudEnabledForApp", enabled));
	}

	public function getQuota():Array<ASAny> {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetQuota"), Array);
	}

	public function UGCDownload(handle:String, priority:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UGCDownload", [handle, priority]));
	}

	public function UGCRead(handle:String, size:Int, offset:UInt, data:ByteArray):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UGCRead", [handle, size, offset, data]));
	}

	public function getUGCDownloadProgress(handle:String):Array<ASAny> {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetUGCDownloadProgress", handle), Array);
	}

	public function getUGCDownloadResult(handle:String):DownloadUGCResult {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetUGCDownloadResult", handle), DownloadUGCResult);
	}

	public function publishWorkshopFile(name:String, preview:String, appId:UInt, title:String, description:String, visibility:UInt, tags:Array<ASAny>,
			fileType:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_PublishWorkshopFile", [name, preview, appId, title, description, visibility, tags, fileType]));
	}

	public function publishWorkshopFileResult():String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_PublishWorkshopFileResult"));
	}

	public function deletePublishedFile(file:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_DeletePublishedFile", file));
	}

	public function getPublishedFileDetails(file:String, maxAge:UInt = (0 : UInt)):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_GetPublishedFileDetails", [file, maxAge]));
	}

	public function getPublishedFileDetailsResult(file:String):FileDetailsResult {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetPublishedFileDetailsResult", file), FileDetailsResult);
	}

	public function enumerateUserPublishedFiles(startIndex:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EnumerateUserPublishedFiles", startIndex));
	}

	public function enumerateUserPublishedFilesResult():UserFilesResult {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_EnumerateUserPublishedFilesResult"), UserFilesResult);
	}

	public function enumeratePublishedWorkshopFiles(type:UInt, start:UInt, count:UInt, days:UInt, tags:Array<ASAny>, userTags:Array<ASAny>):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EnumeratePublishedWorkshopFiles", [type, start, count, days, tags, userTags]));
	}

	public function enumeratePublishedWorkshopFilesResult():WorkshopFilesResult {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_EnumeratePublishedWorkshopFilesResult"), WorkshopFilesResult);
	}

	public function enumerateUserSubscribedFiles(startIndex:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EnumerateUserSubscribedFiles", startIndex));
	}

	public function enumerateUserSubscribedFilesResult():SubscribedFilesResult {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_EnumerateUserSubscribedFilesResult"), SubscribedFilesResult);
	}

	public function enumerateUserSharedWorkshopFiles(steamID:String, start:UInt, required:Array<ASAny>, excluded:Array<ASAny>):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EnumerateUserSharedWorkshopFiles", [steamID, start, required, excluded]));
	}

	public function enumerateUserSharedWorkshopFilesResult():UserFilesResult {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_EnumerateUserSharedWorkshopFilesResult"), UserFilesResult);
	}

	public function enumeratePublishedFilesByUserAction(action:UInt, startIndex:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EnumeratePublishedFilesByUserAction", [action, startIndex]));
	}

	public function enumeratePublishedFilesByUserActionResult():FilesByUserActionResult {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_EnumeratePublishedFilesByUserActionResult"), FilesByUserActionResult);
	}

	public function subscribePublishedFile(file:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SubscribePublishedFile", file));
	}

	public function unsubscribePublishedFile(file:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UnsubscribePublishedFile", file));
	}

	public function createPublishedFileUpdateRequest(file:String):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_CreatePublishedFileUpdateRequest", file));
	}

	public function updatePublishedFileFile(handle:String, file:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileFile", [handle, file]));
	}

	public function updatePublishedFilePreviewFile(handle:String, preview:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFilePreviewFile", [handle, preview]));
	}

	public function updatePublishedFileTitle(handle:String, title:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileTitle", [handle, title]));
	}

	public function updatePublishedFileDescription(handle:String, description:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileDescription", [handle, description]));
	}

	public function updatePublishedFileSetChangeDescription(handle:String, changeDesc:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileSetChangeDescription", [handle, changeDesc]));
	}

	public function updatePublishedFileVisibility(handle:String, visibility:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileVisibility", [handle, visibility]));
	}

	public function updatePublishedFileTags(handle:String, tags:Array<ASAny>):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdatePublishedFileTags", [handle, tags]));
	}

	public function commitPublishedFileUpdate(handle:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_CommitPublishedFileUpdate", handle));
	}

	public function getPublishedItemVoteDetails(file:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_GetPublishedItemVoteDetails", file));
	}

	public function getPublishedItemVoteDetailsResult():ItemVoteDetailsResult {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetPublishedItemVoteDetailsResult"), ItemVoteDetailsResult);
	}

	public function getUserPublishedItemVoteDetails(file:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_GetUserPublishedItemVoteDetails", file));
	}

	public function getUserPublishedItemVoteDetailsResult():UserVoteDetails {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetUserPublishedItemVoteDetailsResult"), UserVoteDetails);
	}

	public function updateUserPublishedItemVote(file:String, upvote:Bool):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UpdateUserPublishedItemVote", [file, upvote]));
	}

	public function setUserPublishedFileAction(file:String, action:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetUserPublishedFileAction", [file, action]));
	}

	public function getFriendCount(flags:UInt):Int {
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetFriendCount", flags));
	}

	public function getFriendByIndex(index:Int, flags:UInt):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetFriendByIndex", [index, flags]));
	}

	public function getFriendPersonaName(id:String):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetFriendPersonaName", id));
	}

	public function getSmallFriendAvatar(id:String):BitmapData {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetSmallFriendAvatar", id), BitmapData);
	}

	public function getMediumFriendAvatar(id:String):BitmapData {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetMediumFriendAvatar", id), BitmapData);
	}

	public function getLargeFriendAvatar(id:String):BitmapData {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetLargeFriendAvatar", id), BitmapData);
	}

	public function setRichPresence(key:String, value:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetRichPresence", [key, value]));
	}

	public function clearRichPresence():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ClearRichPresence"));
	}

	public function setPlayedWith(steamID:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetPlayedWith", steamID));
	}

	public function getCoplayFriendCount():Int {
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetCoplayFriendCount"));
	}

	public function getCoplayFriend(index:Int):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetCoplayFriend", index));
	}

	public function getAuthSessionTicket(ticket:ByteArray, steamID:String):UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetAuthSessionTicket", [ticket, steamID]));
	}

	public function getAuthSessionTicketResult():UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetAuthSessionTicketResult"));
	}

	public function beginAuthSession(ticket:ByteArray, steamID:String):Int {
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_BeginAuthSession", [ticket, steamID]));
	}

	public function endAuthSession(steamID:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_EndAuthSession", steamID));
	}

	public function cancelAuthTicket(ticketHandle:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_CancelAuthTicket", ticketHandle));
	}

	public function userHasLicenseForApp(steamID:String, appID:UInt):Int {
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_UserHasLicenseForApp", [steamID, appID]));
	}

	public function requestEncryptedAppTicket(secretData:ByteArray):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RequestEncryptedAppTicket", secretData));
	}

	public function getEncryptedAppTicket(ticket:ByteArray):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_GetEncryptedAppTicket", ticket));
	}

	public function getAuthTicketForWebApi(identity:String = ""):UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetAuthTicketForWebApi", identity));
	}

	public function getAuthTicketForWebApiResultHandle():UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_GetAuthTicketForWebApiResultHandle"));
	}

	public function getAuthTicketForWebApiResultHexString():String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetAuthTicketForWebApiResultHexString"));
	}

	public function activateGameOverlay(dialog:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateGameOverlay", dialog));
	}

	public function activateGameOverlayToUser(dialog:String, steamId:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateGameOverlayToUser", [dialog, steamId]));
	}

	public function activateGameOverlayToWebPage(url:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateGameOverlayToWebPage", url));
	}

	public function activateGameOverlayToStore(appId:UInt, flag:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateGameOverlayToStore", [appId, flag]));
	}

	public function activateGameOverlayInviteDialog(steamIdLobby:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateGameOverlayInviteDialog", steamIdLobby));
	}

	public function isOverlayEnabled():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsOverlayEnabled"));
	}

	public function setOverlayNotificationPosition(position:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetOverlayNotificationPosition", position));
	}

	public function setOverlayNotificationInset(hInset:Int, vInset:Int):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetOverlayNotificationInset", [hInset, vInset]));
	}

	public function overlayNeedsPresent():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_OverlayNeedsPresent"));
	}

	public function isSubscribedApp(appId:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsSubscribedApp", appId));
	}

	public function isDLCInstalled(appId:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_IsDLCInstalled", appId));
	}

	public function getDLCCount():Int {
		return ASCompat.asInt(_ExtensionContext.call("AIRSteam_GetDLCCount"));
	}

	public function installDLC(appId:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_InstallDLC", appId));
	}

	public function uninstallDLC(appId:UInt):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_UninstallDLC", appId));
	}

	public function DLCInstalledResult():UInt {
		return ASCompat.asUint(_ExtensionContext.call("AIRSteam_DLCInstalledResult"));
	}

	public function microTxnResult():MicroTxnAuthorizationResponse {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_MicroTxnResult"), MicroTxnAuthorizationResponse);
	}

	public function inputInit():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_InputInit"));
	}

	public function getControllerForGamepadIndex(index:Int):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetControllerForGamepadIndex", index));
	}

	public function showBindingPanel(inputHandle:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ShowBindingPanel", inputHandle));
	}

	public function getActionSetHandle(actionSetName:String):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetActionSetHandle", actionSetName));
	}

	public function getDigitalActionHandle(actionName:String):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetDigitalActionHandle", actionName));
	}

	public function getAnalogActionHandle(actionName:String):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetAnalogActionHandle", actionName));
	}

	public function getDigitalActionData(inputHandle:String, actionHandle:String):InputDigitalActionData {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetDigitalActionData", [inputHandle, actionHandle]), InputDigitalActionData);
	}

	public function getAnalogActionData(inputHandle:String, actionHandle:String):InputAnalogActionData {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetAnalogActionData", [inputHandle, actionHandle]), InputAnalogActionData);
	}

	public function runFrame():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_RunFrame"));
	}

	public function getConnectedControllers():Array<ASAny> {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetConnectedControllers"), Array);
	}

	public function activateActionSet(inputHandle:String, actionSetHandle:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ActivateActionSet", [inputHandle, actionSetHandle]));
	}

	public function getHandleAllControllers():String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetHandleAllControllers"));
	}

	public function getDigitalActionOrigins(inputHandle:String, actionSetHandle:String, digitalActionHandle:String):Array<ASAny> {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetDigitalActionOrigins", [inputHandle, actionSetHandle, digitalActionHandle]), Array);
	}

	public function getAnalogActionOrigins(inputHandle:String, actionSetHandle:String, analogActionHandle:String):Array<ASAny> {
		return ASCompat.dynamicAs(_ExtensionContext.call("AIRSteam_GetAnalogActionOrigins", [inputHandle, actionSetHandle, analogActionHandle]), Array);
	}

	public function getGlyphSVGForActionOrigin(eOrigin:String, flags:Int):String {
		return correctFilePath(ASCompat.asString(_ExtensionContext.call("AIRSteam_GetGlyphSVGForActionOrigin", [eOrigin, flags])));
	}

	public function getGlyphPNGForActionOrigin(eOrigin:String, eSize:Int, flags:Int):String {
		return correctFilePath(ASCompat.asString(_ExtensionContext.call("AIRSteam_GetGlyphPNGForActionOrigin", [eOrigin, eSize, flags])));
	}

	function correctFilePath(path:String):String {
		if (ASCompat.stringAsBool(path) && path.indexOf("/") != -1) {
			path = path.split("\\").join("/");
		}
		return path;
	}

	public function getStringForActionOrigin(eOrigin:String):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetStringForActionOrigin", eOrigin));
	}

	public function showGamepadTextInput(eInputMode:Int, eLineInputMode:Int, pchDescription:String, unCharMax:Int, pchExistingText:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ShowGamepadTextInput",
			[eInputMode, eLineInputMode, pchDescription, unCharMax, pchExistingText]));
	}

	public function showFloatingGamepadTextInput(eKeyboardMode:Int, nTextFieldXPosition:Int, nTextFieldYPosition:Int, nTextFieldWidth:Int,
			nTextFieldHeight:Int):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_ShowFloatingGamepadTextInput", [
			eKeyboardMode,
			nTextFieldXPosition,
			nTextFieldYPosition,
			nTextFieldWidth,
			nTextFieldHeight
		]));
	}

	public function steamInputShutdown():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SteamInputShutDown"));
	}

	public function dismissFloatingGamepadTextInput():Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_DismissFloatingGamepadTextInput"));
	}

	public function getEnv(name:String):String {
		return ASCompat.asString(_ExtensionContext.call("AIRSteam_GetEnv", name));
	}

	public function setEnv(name:String, value:String):Bool {
		return ASCompat.asBool(_ExtensionContext.call("AIRSteam_SetEnv", [name, value]));
	}
}
