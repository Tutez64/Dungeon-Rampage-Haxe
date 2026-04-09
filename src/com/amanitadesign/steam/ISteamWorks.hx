package com.amanitadesign.steam
;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.events.IEventDispatcher;
   import flash.utils.ByteArray;
   
    interface ISteamWorks extends IEventDispatcher
   {
      
      @:meta(Event(name="steamResponse",type="com.amanitadesign.steam.SteamEvent"))
      function dispose() : Void;
      
      function addOverlayWorkaround(param1:DisplayObjectContainer, param2:Bool = false, param3:UInt = (0 : UInt)) : Void;
      
      function runCallbacks() : Bool;
      
      function getUserID() : String;
      
      function getAppID() : UInt;
      
      function getAvailableGameLanguages() : String;
      
      function getCurrentGameLanguage() : String;
      
      function getPersonaName() : String;
      
      function restartAppIfNecessary(param1:UInt) : Bool;
      
      function getIPCountry() : String;
      
      function isSteamInBigPictureMode() : Bool;
      
      function isSteamRunningOnSteamDeck() : Bool;
      
      function getServerRealTime() : UInt;
      
      function getSecondsSinceAppActive() : UInt;
      
      function getEarliestPurchaseUnixTime(param1:String) : UInt;
      
      function requestStats() : Bool;
      
      function setAchievement(param1:String) : Bool;
      
      function clearAchievement(param1:String) : Bool;
      
      function isAchievement(param1:String) : Bool;
      
      function isAchievementEarned(param1:String) : Bool;
      
      function getAchievementAchievedPercent(param1:String) : Float;
      
      function getAchievementDisplayAttribute(param1:String, param2:String) : String;
      
      function getAchievementIcon(param1:String) : BitmapData;
      
      function getAchievementName(param1:UInt) : String;
      
      function getNumAchievements() : Int;
      
      function indicateAchievementProgress(param1:String, param2:Int, param3:Int) : Bool;
      
      function getStatInt(param1:String) : Int;
      
      function getStatFloat(param1:String) : Float;
      
      function setStatInt(param1:String, param2:Int) : Bool;
      
      function setStatFloat(param1:String, param2:Float) : Bool;
      
      function storeStats() : Bool;
      
      function resetAllStats(param1:Bool) : Bool;
      
      function requestGlobalStats(param1:Int) : Bool;
      
      function getGlobalStatInt(param1:String) : Float;
      
      function getGlobalStatFloat(param1:String) : Float;
      
      function getGlobalStatHistoryInt(param1:String, param2:Int) : Array<ASAny>;
      
      function getGlobalStatHistoryFloat(param1:String, param2:Int) : Array<ASAny>;
      
      function findLeaderboard(param1:String) : Bool;
      
      function findOrCreateLeaderboard(param1:String, param2:UInt, param3:UInt) : Bool;
      
      function findLeaderboardResult() : String;
      
      function getLeaderboardName(param1:String) : String;
      
      function getLeaderboardEntryCount(param1:String) : Int;
      
      function getLeaderboardSortMethod(param1:String) : UInt;
      
      function getLeaderboardDisplayType(param1:String) : UInt;
      
      function uploadLeaderboardScore(param1:String, param2:UInt, param3:Int, param4:Array<ASAny> = null) : Bool;
      
      function uploadLeaderboardScoreResult() : UploadLeaderboardScoreResult;
      
      function downloadLeaderboardEntries(param1:String, param2:UInt = (1 : UInt), param3:Int = -4, param4:Int = 5) : Bool;
      
      function downloadLeaderboardEntriesResult(param1:Int = 0) : Array<ASAny>;
      
      function getFileCount() : Int;
      
      function getFileSize(param1:String) : Int;
      
      function fileExists(param1:String) : Bool;
      
      function fileWrite(param1:String, param2:ByteArray) : Bool;
      
      function fileRead(param1:String, param2:ByteArray) : Bool;
      
      function fileDelete(param1:String) : Bool;
      
      function fileShare(param1:String) : Bool;
      
      function fileShareResult() : String;
      
      function isCloudEnabledForApp() : Bool;
      
      function setCloudEnabledForApp(param1:Bool) : Bool;
      
      function getQuota() : Array<ASAny>;
      
      function UGCDownload(param1:String, param2:UInt) : Bool;
      
      function UGCRead(param1:String, param2:Int, param3:UInt, param4:ByteArray) : Bool;
      
      function getUGCDownloadProgress(param1:String) : Array<ASAny>;
      
      function getUGCDownloadResult(param1:String) : DownloadUGCResult;
      
      function publishWorkshopFile(param1:String, param2:String, param3:UInt, param4:String, param5:String, param6:UInt, param7:Array<ASAny>, param8:UInt) : Bool;
      
      function publishWorkshopFileResult() : String;
      
      function deletePublishedFile(param1:String) : Bool;
      
      function getPublishedFileDetails(param1:String, param2:UInt = (0 : UInt)) : Bool;
      
      function getPublishedFileDetailsResult(param1:String) : FileDetailsResult;
      
      function enumerateUserPublishedFiles(param1:UInt) : Bool;
      
      function enumerateUserPublishedFilesResult() : UserFilesResult;
      
      function enumeratePublishedWorkshopFiles(param1:UInt, param2:UInt, param3:UInt, param4:UInt, param5:Array<ASAny>, param6:Array<ASAny>) : Bool;
      
      function enumeratePublishedWorkshopFilesResult() : WorkshopFilesResult;
      
      function enumerateUserSubscribedFiles(param1:UInt) : Bool;
      
      function enumerateUserSubscribedFilesResult() : SubscribedFilesResult;
      
      function enumerateUserSharedWorkshopFiles(param1:String, param2:UInt, param3:Array<ASAny>, param4:Array<ASAny>) : Bool;
      
      function enumerateUserSharedWorkshopFilesResult() : UserFilesResult;
      
      function enumeratePublishedFilesByUserAction(param1:UInt, param2:UInt) : Bool;
      
      function enumeratePublishedFilesByUserActionResult() : FilesByUserActionResult;
      
      function subscribePublishedFile(param1:String) : Bool;
      
      function unsubscribePublishedFile(param1:String) : Bool;
      
      function createPublishedFileUpdateRequest(param1:String) : String;
      
      function updatePublishedFileFile(param1:String, param2:String) : Bool;
      
      function updatePublishedFilePreviewFile(param1:String, param2:String) : Bool;
      
      function updatePublishedFileTitle(param1:String, param2:String) : Bool;
      
      function updatePublishedFileDescription(param1:String, param2:String) : Bool;
      
      function updatePublishedFileSetChangeDescription(param1:String, param2:String) : Bool;
      
      function updatePublishedFileVisibility(param1:String, param2:UInt) : Bool;
      
      function updatePublishedFileTags(param1:String, param2:Array<ASAny>) : Bool;
      
      function commitPublishedFileUpdate(param1:String) : Bool;
      
      function getPublishedItemVoteDetails(param1:String) : Bool;
      
      function getPublishedItemVoteDetailsResult() : ItemVoteDetailsResult;
      
      function getUserPublishedItemVoteDetails(param1:String) : Bool;
      
      function getUserPublishedItemVoteDetailsResult() : UserVoteDetails;
      
      function updateUserPublishedItemVote(param1:String, param2:Bool) : Bool;
      
      function setUserPublishedFileAction(param1:String, param2:UInt) : Bool;
      
      function getFriendCount(param1:UInt) : Int;
      
      function getFriendByIndex(param1:Int, param2:UInt) : String;
      
      function getFriendPersonaName(param1:String) : String;
      
      function getSmallFriendAvatar(param1:String) : BitmapData;
      
      function getMediumFriendAvatar(param1:String) : BitmapData;
      
      function getLargeFriendAvatar(param1:String) : BitmapData;
      
      function setRichPresence(param1:String, param2:String) : Bool;
      
      function clearRichPresence() : Bool;
      
      function setPlayedWith(param1:String) : Bool;
      
      function getCoplayFriendCount() : Int;
      
      function getCoplayFriend(param1:Int) : String;
      
      function getAuthSessionTicket(param1:ByteArray, param2:String) : UInt;
      
      function getAuthSessionTicketResult() : UInt;
      
      function beginAuthSession(param1:ByteArray, param2:String) : Int;
      
      function endAuthSession(param1:String) : Bool;
      
      function cancelAuthTicket(param1:UInt) : Bool;
      
      function userHasLicenseForApp(param1:String, param2:UInt) : Int;
      
      function requestEncryptedAppTicket(param1:ByteArray) : Bool;
      
      function getEncryptedAppTicket(param1:ByteArray) : Bool;
      
      function getAuthTicketForWebApi(param1:String = "") : UInt;
      
      function getAuthTicketForWebApiResultHandle() : UInt;
      
      function getAuthTicketForWebApiResultHexString() : String;
      
      function activateGameOverlay(param1:String) : Bool;
      
      function activateGameOverlayToUser(param1:String, param2:String) : Bool;
      
      function activateGameOverlayToWebPage(param1:String) : Bool;
      
      function activateGameOverlayToStore(param1:UInt, param2:UInt) : Bool;
      
      function activateGameOverlayInviteDialog(param1:String) : Bool;
      
      function isOverlayEnabled() : Bool;
      
      function setOverlayNotificationPosition(param1:UInt) : Bool;
      
      function setOverlayNotificationInset(param1:Int, param2:Int) : Bool;
      
      function overlayNeedsPresent() : Bool;
      
      function isSubscribedApp(param1:UInt) : Bool;
      
      function isDLCInstalled(param1:UInt) : Bool;
      
      function getDLCCount() : Int;
      
      function installDLC(param1:UInt) : Bool;
      
      function uninstallDLC(param1:UInt) : Bool;
      
      function DLCInstalledResult() : UInt;
      
      function microTxnResult() : MicroTxnAuthorizationResponse;
      
      function getEnv(param1:String) : String;
      
      function setEnv(param1:String, param2:String) : Bool;
   }


