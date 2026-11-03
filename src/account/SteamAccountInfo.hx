package account;

import brain.event.EventListeners;
import brain.logger.Logger;
import brain.utils.HttpStatusEventUtils;
import facade.DBFacade;
import com.amanitadesign.steam.SteamEvent;
import com.amanitadesign.steam.SteamResults;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;

class SteamAccountInfo {
	public static inline final steamRetryDelay:Float = 0.25;

	public static inline final steamWarnAfterRetries = 240;

	public static inline final waitingForSteamText = "WAITING FOR STEAM...";

	static inline final showWaitingAfterRetries = 4;

	public static var steamRetries:Int = 0;

	public function new() {}

	public static function startSteam(dbFacade:DBFacade) {
		var ticketRequest:UInt;
		try {
			if (!dbFacade.mSteamworks.init()) {
				Logger.warn("STEAMWORKS API is NOT available");
				dbFacade.mSteamLoginFailure = "the Steamworks API did not start";
			} else {
				Logger.info("STEAMWORKS API is available\n");
				EventListeners.add(dbFacade.mSteamworks, SteamEvent.STEAM_RESPONSE, function(param1:SteamEvent) {
					if (param1.req_type == 33) {
						onWebApiTicketResponse(dbFacade, param1.response);
					}
				});
				dbFacade.mSteamUserId = dbFacade.mSteamworks.getUserID();
				Logger.info("STEAMWORKS User ID: " + dbFacade.mSteamUserId);
				dbFacade.mSteamAppId = dbFacade.mSteamworks.getAppID();
				Logger.info("STEAMWORKS App ID: " + dbFacade.mSteamAppId);
				dbFacade.mSteamPersonaName = dbFacade.mSteamworks.getPersonaName();
				Logger.info("STEAMWORKS Persona name: " + dbFacade.mSteamPersonaName);
				ticketRequest = (dbFacade.mSteamworks.getAuthTicketForWebApi() : UInt);
				Logger.info("[Steam] Requested the login ticket, handle " + ticketRequest);
				if (ticketRequest == 0) {
					dbFacade.mSteamLoginFailure = "the login ticket request failed";
				}
			}
		} catch (e:Dynamic) {
			dbFacade.mSteamLoginFailure = "Steamworks error: " + Std.string(e.message);
			Logger.warn("*** STEAMWORKS ERROR ***");
			Logger.error(e.message, e);
		}
	}

	static function onWebApiTicketResponse(dbFacade:DBFacade, result:Int) {
		var _loc3_:String = null;
		Logger.info("[Steam] RESPONSE_OnGetAuthTicketForWebApiResponse: " + steamResultName(result));
		if (result != 1) {
			dbFacade.mSteamLoginFailure = "Steam returned " + steamResultName(result) + " for the login ticket";
			return;
		}
		try {
			_loc3_ = dbFacade.mSteamworks.getAuthTicketForWebApiResultHexString();
			if (!ASCompat.stringAsBool(_loc3_)) {
				dbFacade.mSteamLoginFailure = "Steam returned OK but no login ticket";
				return;
			}
			dbFacade.mSteamAuthTicketHandle = dbFacade.mSteamworks.getAuthTicketForWebApiResultHandle();
			dbFacade.mSteamWebApiAuthTicket = _loc3_;
		} catch (e:Dynamic) {
			dbFacade.mSteamLoginFailure = "Steamworks error reading the login ticket: " + Std.string(e.message);
		}
	}

	public static function getOrCreateAccount(dbFacade:DBFacade, successCallback:ASFunction) {
		if (!dbFacade.mUseSteamLogin) {
			Logger.info("Skipping logging into Steam.");
			successCallback();
			return;
		}
		spinWaitOnSteamTokenReceived(dbFacade, function() {
			SteamAccountInfo.getOrCreateAccountAfterSteamTokenReceived(dbFacade, successCallback);
		});
	}

	public static function spinWaitOnSteamTokenReceived(dbFacade:DBFacade, successCallback:ASFunction) {
		if (ASCompat.stringAsBool(dbFacade.mSteamWebApiAuthTicket)) {
			successCallback();
		} else {
			if (dbFacade.loadingStateLeft) {
				Logger.info("Stopped waiting for the Steam login ticket: the game left the loading state");
				return;
			}
			if (ASCompat.stringAsBool(dbFacade.mSteamLoginFailure)) {
				Logger.fatal("Could not log in through Steam: "
					+ new compat.RegExp("\\.+$").replace(dbFacade.mSteamLoginFailure, "")
					+ ". Make sure Steam is running, logged in and online, then restart the game");
				return;
			}
			steamRetries = steamRetries + 1;
			dbFacade.mTween.delayedCall(0.25, function() {
				spinWaitOnSteamTokenReceived(dbFacade, successCallback);
			});
			if (steamRetries >= 4) {
				dbFacade.setLoadingBarText("WAITING FOR STEAM...");
			}
			if (steamRetries == 240) {
				Logger.warn("Steam login ticket not received after 60 seconds. Steam may be offline or reconnecting to its servers; still waiting");
			}
			if (steamRetries <= 240 || steamRetries % 240 == 0) {
				Logger.info("Steam login ticket not received yet from Steam SDK, waiting another 0.25 seconds. [" + steamRetries + "]");
			}
		}
	}

	public static function getOrCreateAccountAfterSteamTokenReceived(dbFacade:DBFacade, successCallback:ASFunction) {
		var destroyCallbacks:() -> Void = null;
		var apiPath:String;
		var request:URLRequest;
		var jsonHeader:URLRequestHeader;
		var requestObject:ASObject;
		var requestJsonString:String;
		var urlLoader:URLLoader = null;
		var responseStatusCode:Int;
		var onResponseStatus = function(param1:flash.events.HTTPStatusEvent) {
			responseStatusCode = param1.status;
			dbFacade.initialLoginTraceId = HttpStatusEventUtils.getTraceId(param1);
		};
		var onLoadError = function(param1:flash.events.Event) {
			destroyCallbacks();
			Logger.info("[Steam] Cancelling Auth token due to failure");
			dbFacade.mSteamworks.cancelAuthTicket(dbFacade.mSteamAuthTicketHandle);
			var _loc2_ = "["
				+ responseStatusCode
				+ "] Error Logging into Dungeon Rampage Server with Steam Login. HTTP Error: "
				+ responseStatusCode
				+ "; TraceId: "
				+ dbFacade.initialLoginTraceId
				+ "; IOError: "
				+ param1.toString();
			if (ASCompat.toBool(param1.target) && ASCompat.toBool(param1.target.data)) {
				_loc2_ += "; Response: " + Std.string(param1.target.data);
			}
			if (dbFacade.mainStateMachine != null) {
				if (responseStatusCode == 0) {
					dbFacade.mainStateMachine.enterSocketErrorState((1503 : UInt));
				} else {
					dbFacade.mainStateMachine.enterSocketErrorState((1500 : UInt), Std.string(responseStatusCode));
				}
				Logger.error(_loc2_);
			} else {
				Logger.fatal(_loc2_);
			}
		};
		var onCompleted = function(param1:flash.events.Event) {
			var _loc2_:ASObject = null;
			if (responseStatusCode < 100 || responseStatusCode >= 400) {
				onLoadError(param1);
			} else {
				destroyCallbacks();
				_loc2_ = haxe.Json.parse(param1.target.data);
				dbFacade.accountId = (ASCompat.toInt(_loc2_.playerId) : UInt);
				dbFacade.mSteamIsFlagged = ASCompat.toBool(_loc2_.isFlagged);
				dbFacade.mSteamIsFlaggedDueToFamilySharingOwnerIsFlagged = ASCompat.toBool(_loc2_.isFlaggedDueToFamilySharingOwnerIsFlagged);
				dbFacade.mSteamFlaggedUntilAfterDateString = _loc2_.flaggedUntilAfterDateString;
				dbFacade.mSteamIsFlaggedDueToFamilySharingOwnerName = _loc2_.isFlaggedDueToFamilySharingOwnerName;
				dbFacade.mSteamAvatarUrl = _loc2_.steamAvatarUrl;
				Logger.info("[Steam] Initial login successful! [" + responseStatusCode + "] " + dbFacade.initialLoginTraceId);
				Logger.info("[Steam] Steam account number is "
					+ SteamIdConverter.convertSteamID64ToAccountId(dbFacade.mSteamUserId)
					+ " and shorter id is https://s.team/p/"
					+ SteamIdConverter.convertSteamID64ToSteamHex(dbFacade.mSteamUserId)
					+ " which reverses to "
					+ SteamIdConverter.convertSteamHexToSteamID64(SteamIdConverter.convertSteamID64ToSteamHex(dbFacade.mSteamUserId)));
				dbFacade.validationToken = _loc2_.playerToken;
				Logger.info("[Steam] Cancelling Auth token now that it is used");
				dbFacade.mSteamworks.cancelAuthTicket(dbFacade.mSteamAuthTicketHandle);
				successCallback();
			}
		};
		destroyCallbacks = function() {
			EventListeners.remove(urlLoader, "httpResponseStatus", onResponseStatus);
			EventListeners.remove(urlLoader, "ioError", onLoadError);
			EventListeners.remove(urlLoader, "securityError", onLoadError);
			EventListeners.remove(urlLoader, "certificateError", onLoadError);
			EventListeners.remove(urlLoader, "complete", onCompleted);
		};
		Logger.info("Logging into server with id " + dbFacade.mSteamUserId + " and persona name " + dbFacade.mSteamPersonaName + " for app id "
			+ dbFacade.mSteamAppId);
		if (!ASCompat.stringAsBool(dbFacade.mSteamUserId)
			|| !ASCompat.stringAsBool(dbFacade.mSteamPersonaName)
			|| dbFacade.mSteamAppId == 0) {
			Logger.fatal("Failed to get user\'s data from Steam. Maybe Steam is not running?");
		}
		apiPath = dbFacade.steamAPIRoot + "login/" + dbFacade.mSteamUserId;
		request = new URLRequest(apiPath);
		request.idleTimeout = 90000;
		request.method = "PUT";
		jsonHeader = new URLRequestHeader("Content-Type", "application/json");
		request.requestHeaders.push(jsonHeader);
		requestObject = {
			"steamUserId": dbFacade.mSteamUserId,
			"steamUserPersonaName": dbFacade.mSteamPersonaName,
			"steamWebApiAuthTicket": dbFacade.mSteamWebApiAuthTicket,
			"requestingSteamAppId": dbFacade.mSteamAppId
		};
		requestJsonString = haxe.Json.stringify(requestObject);
		request.data = requestJsonString;
		urlLoader = new URLLoader();
		EventListeners.add(urlLoader, "httpResponseStatus", onResponseStatus);
		EventListeners.add(urlLoader, "ioError", onLoadError);
		EventListeners.add(urlLoader, "securityError", onLoadError);
		EventListeners.add(urlLoader, "certificateError", onLoadError);
		EventListeners.add(urlLoader, "complete", onCompleted);
		responseStatusCode = 0;
		urlLoader.load(request);
	}

	public static function steamResultName(result:Int):String {
		var _loc3_:String = null;
		var _loc2_:compat.XML;
		final __ax4_iter_346 = ASCompat.describeType(SteamResults).child("constant");
		if (checkNullIteratee(__ax4_iter_346))
			for (_tmp_ in __ax4_iter_346) {
				_loc2_ = _tmp_;
				_loc3_ = _loc2_.attribute("name");
				if (ASCompat.toNumber((SteamResults : ASAny)[_loc3_]) == result) {
					return _loc3_ + " (" + result + ")";
				}
			}
		return Std.string(result);
	}
}
