package com.amanitadesign.steam;

import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
#if air
import flash.events.StatusEvent;
import flash.external.ExtensionContext;
#end
#if (cpp && !air)
import steamwrap.api.Steam;
#if sys
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
#end
#end

class FRESteamWorks extends EventDispatcher {
	#if air
	var extensionContext:ExtensionContext;
	#end

	var callbackTick:Int = 0;
	public var isReady:Bool = false;

	public function new(param1:IEventDispatcher = null) {
		super(param1);
		#if air
		extensionContext = ExtensionContext.createExtensionContext("com.amanitadesign.steam.FRESteamWorks", null);
		extensionContext.addEventListener("status", handleStatusEvent);
		#elseif (cpp && !air)
		Steam.whenGetAuthTicketForWebApiResponse = function(success:Bool, _handle:Int, responseCode:Int):Void {
			var ev = new SteamEvent(SteamEvent.STEAM_RESPONSE, 27, responseCode);
			dispatchEvent(ev);
		};
		#end
	}

	#if air
	function handleStatusEvent(param1:StatusEvent):Void {
		var reqType = ASCompat.toInt(param1.code);
		var response = ASCompat.toInt(param1.level);
		dispatchEvent(new SteamEvent(SteamEvent.STEAM_RESPONSE, reqType, response));
	}
	#end

	public function addOverlayWorkaround(_container:DisplayObjectContainer, _alwaysVisible:Bool = false, _color:UInt = (0 : UInt)):Void {}

	public function dispose():Void {
		ASCompat.clearInterval((callbackTick : UInt));
		#if air
		if (extensionContext != null) {
			extensionContext.removeEventListener("status", handleStatusEvent);
			extensionContext.dispose();
			extensionContext = null;
		}
		#elseif (cpp && !air)
		Steam.whenGetAuthTicketForWebApiResponse = null;
		if (Steam.active) {
			Steam.shutdown();
		}
		#end
	}

	public function init():Bool {
		#if air
		isReady = ASCompat.asBool(extensionContext.call("AIRSteam_Init"));
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
			callbackTick = (ASCompat.setInterval(runCallbacks, 100) : Int);
		}
		return isReady;
	}

	public function runCallbacks():Bool {
		#if air
		return ASCompat.asBool(extensionContext.call("AIRSteam_RunCallbacks"));
		#elseif (cpp && !air)
		Steam.onEnterFrame();
		return true;
		#else
		return false;
		#end
	}

	public function getUserID():String {
		#if air
		return ASCompat.asString(extensionContext.call("AIRSteam_GetUserID"));
		#elseif (cpp && !air)
		return Steam.getSteamID();
		#else
		return "";
		#end
	}

	public function getAppID():UInt {
		#if air
		return ASCompat.asUint(extensionContext.call("AIRSteam_GetAppID"));
		#elseif (cpp && !air)
		return (Steam.getAppID() : UInt);
		#else
		return (0 : UInt);
		#end
	}

	public function getPersonaName():String {
		#if air
		return ASCompat.asString(extensionContext.call("AIRSteam_GetPersonaName"));
		#elseif (cpp && !air)
		return Steam.getPersonaName();
		#else
		return "";
		#end
	}

	public function getAuthTicketForWebApi(param1:String = ""):UInt {
		#if air
		return ASCompat.asUint(extensionContext.call("AIRSteam_GetAuthTicketForWebApi", param1));
		#elseif (cpp && !air)
		return (Steam.getAuthTicketForWebApi(param1) : UInt);
		#else
		return (0 : UInt);
		#end
	}

	public function getAuthTicketForWebApiResultHandle():UInt {
		#if air
		return ASCompat.asUint(extensionContext.call("AIRSteam_GetAuthTicketForWebApiResultHandle"));
		#elseif (cpp && !air)
		return (Steam.getAuthTicketForWebApiResultHandle() : UInt);
		#else
		return (0 : UInt);
		#end
	}

	public function getAuthTicketForWebApiResultHexString():String {
		#if air
		return ASCompat.asString(extensionContext.call("AIRSteam_GetAuthTicketForWebApiResultHexString"));
		#elseif (cpp && !air)
		return Steam.getAuthTicketForWebApiResultHexString();
		#else
		return "";
		#end
	}

	public function cancelAuthTicket(param1:UInt):Bool {
		#if air
		return ASCompat.asBool(extensionContext.call("AIRSteam_CancelAuthTicket", param1));
		#elseif (cpp && !air)
		return Steam.cancelAuthTicket((param1 : Int));
		#else
		return false;
		#end
	}

	public function isOverlayEnabled():Bool {
		#if air
		return ASCompat.asBool(extensionContext.call("AIRSteam_IsOverlayEnabled"));
		#elseif (cpp && !air)
		return Steam.isOverlayEnabled();
		#else
		return false;
		#end
	}

	public function activateGameOverlayToStore(param1:UInt, param2:UInt):Bool {
		#if air
		return ASCompat.asBool(extensionContext.call("AIRSteam_ActivateGameOverlayToStore", [param1, param2]));
		#elseif (cpp && !air)
		return Steam.activateGameOverlayToStore((param1 : Int), (param2 : Int));
		#else
		return false;
		#end
	}

	public function activateGameOverlayToWebPage(param1:String):Bool {
		#if air
		return ASCompat.asBool(extensionContext.call("AIRSteam_ActivateGameOverlayToWebPage", param1));
		#elseif (cpp && !air)
		Steam.openOverlayToURL(param1);
		return true;
		#else
		return false;
		#end
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
