package com.amanitadesign.steam;

import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.events.IEventDispatcher;
import flash.utils.ByteArray;

interface ISteamWorks extends IEventDispatcher {
	@:meta(Event(name = "steamResponse", type = "com.amanitadesign.steam.SteamEvent"))
	function dispose():Void;

	function addOverlayWorkaround(container:DisplayObjectContainer, alwaysVisible:Bool = false, color:UInt = (0 : UInt)):Void;

	function runCallbacks():Bool;

	function getUserID():String;

	function getAppID():UInt;

	function getAvailableGameLanguages():String;

	function getCurrentGameLanguage():String;

	function getPersonaName():String;

	function restartAppIfNecessary(appID:UInt):Bool;

	function getIPCountry():String;

	function isSteamInBigPictureMode():Bool;

	function isSteamRunningOnSteamDeck():Bool;

	function getServerRealTime():UInt;

	function getSecondsSinceAppActive():UInt;

	function getEarliestPurchaseUnixTime(appID:String):UInt;

	function requestStats():Bool;

	function setAchievement(name:String):Bool;

	function clearAchievement(name:String):Bool;

	function isAchievement(name:String):Bool;

	function isAchievementEarned(name:String):Bool;

	function getAchievementAchievedPercent(name:String):Float;

	function getAchievementDisplayAttribute(name:String, attribute:String):String;

	function getAchievementIcon(name:String):BitmapData;

	function getAchievementName(index:UInt):String;

	function getNumAchievements():Int;

	function indicateAchievementProgress(name:String, currentProgress:Int, maxProgress:Int):Bool;

	function getStatInt(name:String):Int;

	function getStatFloat(name:String):Float;

	function setStatInt(name:String, value:Int):Bool;

	function setStatFloat(name:String, value:Float):Bool;

	function storeStats():Bool;

	function resetAllStats(achievementsToo:Bool):Bool;

	function requestGlobalStats(historyDays:Int):Bool;

	function getGlobalStatInt(name:String):Float;

	function getGlobalStatFloat(name:String):Float;

	function getGlobalStatHistoryInt(name:String, days:Int):Array<ASAny>;

	function getGlobalStatHistoryFloat(name:String, days:Int):Array<ASAny>;

	function findLeaderboard(name:String):Bool;

	function findOrCreateLeaderboard(name:String, sortMethod:UInt, displayType:UInt):Bool;

	function findLeaderboardResult():String;

	function getLeaderboardName(handle:String):String;

	function getLeaderboardEntryCount(handle:String):Int;

	function getLeaderboardSortMethod(handle:String):UInt;

	function getLeaderboardDisplayType(handle:String):UInt;

	function uploadLeaderboardScore(handle:String, method:UInt, score:Int, details:Array<ASAny> = null):Bool;

	function uploadLeaderboardScoreResult():UploadLeaderboardScoreResult;

	function downloadLeaderboardEntries(handle:String, request:UInt = (1 : UInt), rangeStart:Int = -4, rangeEnd:Int = 5):Bool;

	function downloadLeaderboardEntriesResult(numDetails:Int = 0):Array<ASAny>;

	function getFileCount():Int;

	function getFileSize(name:String):Int;

	function fileExists(name:String):Bool;

	function fileWrite(name:String, data:ByteArray):Bool;

	function fileRead(name:String, data:ByteArray):Bool;

	function fileDelete(name:String):Bool;

	function fileShare(name:String):Bool;

	function fileShareResult():String;

	function isCloudEnabledForApp():Bool;

	function setCloudEnabledForApp(enabled:Bool):Bool;

	function getQuota():Array<ASAny>;

	function UGCDownload(handle:String, priority:UInt):Bool;

	function UGCRead(handle:String, size:Int, offset:UInt, data:ByteArray):Bool;

	function getUGCDownloadProgress(handle:String):Array<ASAny>;

	function getUGCDownloadResult(handle:String):DownloadUGCResult;

	function publishWorkshopFile(name:String, preview:String, appId:UInt, title:String, description:String, visibility:UInt, tags:Array<ASAny>,
		fileType:UInt):Bool;

	function publishWorkshopFileResult():String;

	function deletePublishedFile(file:String):Bool;

	function getPublishedFileDetails(file:String, maxAge:UInt = (0 : UInt)):Bool;

	function getPublishedFileDetailsResult(file:String):FileDetailsResult;

	function enumerateUserPublishedFiles(startIndex:UInt):Bool;

	function enumerateUserPublishedFilesResult():UserFilesResult;

	function enumeratePublishedWorkshopFiles(type:UInt, start:UInt, count:UInt, days:UInt, tags:Array<ASAny>, userTags:Array<ASAny>):Bool;

	function enumeratePublishedWorkshopFilesResult():WorkshopFilesResult;

	function enumerateUserSubscribedFiles(startIndex:UInt):Bool;

	function enumerateUserSubscribedFilesResult():SubscribedFilesResult;

	function enumerateUserSharedWorkshopFiles(steamID:String, start:UInt, required:Array<ASAny>, excluded:Array<ASAny>):Bool;

	function enumerateUserSharedWorkshopFilesResult():UserFilesResult;

	function enumeratePublishedFilesByUserAction(action:UInt, startIndex:UInt):Bool;

	function enumeratePublishedFilesByUserActionResult():FilesByUserActionResult;

	function subscribePublishedFile(file:String):Bool;

	function unsubscribePublishedFile(file:String):Bool;

	function createPublishedFileUpdateRequest(file:String):String;

	function updatePublishedFileFile(handle:String, file:String):Bool;

	function updatePublishedFilePreviewFile(handle:String, preview:String):Bool;

	function updatePublishedFileTitle(handle:String, title:String):Bool;

	function updatePublishedFileDescription(handle:String, description:String):Bool;

	function updatePublishedFileSetChangeDescription(handle:String, changeDesc:String):Bool;

	function updatePublishedFileVisibility(handle:String, visibility:UInt):Bool;

	function updatePublishedFileTags(handle:String, tags:Array<ASAny>):Bool;

	function commitPublishedFileUpdate(handle:String):Bool;

	function getPublishedItemVoteDetails(file:String):Bool;

	function getPublishedItemVoteDetailsResult():ItemVoteDetailsResult;

	function getUserPublishedItemVoteDetails(file:String):Bool;

	function getUserPublishedItemVoteDetailsResult():UserVoteDetails;

	function updateUserPublishedItemVote(file:String, upvote:Bool):Bool;

	function setUserPublishedFileAction(file:String, action:UInt):Bool;

	function getFriendCount(flags:UInt):Int;

	function getFriendByIndex(index:Int, flags:UInt):String;

	function getFriendPersonaName(id:String):String;

	function getSmallFriendAvatar(id:String):BitmapData;

	function getMediumFriendAvatar(id:String):BitmapData;

	function getLargeFriendAvatar(id:String):BitmapData;

	function setRichPresence(key:String, value:String):Bool;

	function clearRichPresence():Bool;

	function setPlayedWith(steamID:String):Bool;

	function getCoplayFriendCount():Int;

	function getCoplayFriend(index:Int):String;

	function getAuthSessionTicket(ticket:ByteArray, steamID:String):UInt;

	function getAuthSessionTicketResult():UInt;

	function beginAuthSession(ticket:ByteArray, steamID:String):Int;

	function endAuthSession(steamID:String):Bool;

	function cancelAuthTicket(ticketHandle:UInt):Bool;

	function userHasLicenseForApp(steamID:String, appID:UInt):Int;

	function requestEncryptedAppTicket(secretData:ByteArray):Bool;

	function getEncryptedAppTicket(ticket:ByteArray):Bool;

	function getAuthTicketForWebApi(identity:String = ""):UInt;

	function getAuthTicketForWebApiResultHandle():UInt;

	function getAuthTicketForWebApiResultHexString():String;

	function activateGameOverlay(dialog:String):Bool;

	function activateGameOverlayToUser(dialog:String, steamId:String):Bool;

	function activateGameOverlayToWebPage(url:String):Bool;

	function activateGameOverlayToStore(appId:UInt, flag:UInt):Bool;

	function activateGameOverlayInviteDialog(steamIdLobby:String):Bool;

	function isOverlayEnabled():Bool;

	function setOverlayNotificationPosition(position:UInt):Bool;

	function setOverlayNotificationInset(hInset:Int, vInset:Int):Bool;

	function overlayNeedsPresent():Bool;

	function isSubscribedApp(appId:UInt):Bool;

	function isDLCInstalled(appId:UInt):Bool;

	function getDLCCount():Int;

	function installDLC(appId:UInt):Bool;

	function uninstallDLC(appId:UInt):Bool;

	function DLCInstalledResult():UInt;

	function microTxnResult():MicroTxnAuthorizationResponse;

	function getEnv(name:String):String;

	function setEnv(name:String, value:String):Bool;
}
