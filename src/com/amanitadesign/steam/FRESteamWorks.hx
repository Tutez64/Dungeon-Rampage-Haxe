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

   public function requestStats():Bool {
      #if air
      return ASCompat.asBool(extensionContext.call("AIRSteam_RequestStats"));
      #elseif (cpp && !air)
		var result = Steam.active;
		if (result) {
			dispatchEvent(new SteamEvent(SteamEvent.STEAM_RESPONSE, 0, 1));
		}
		return result;
		#else
		return false;
		#end
   }

   public function setAchievement(param1:String):Bool {
      #if air
      return ASCompat.asBool(extensionContext.call("AIRSteam_SetAchievement", param1));
      #elseif (cpp && !air)
		return Steam.setAchievement(param1);
		#else
		return false;
		#end
   }

   public function isAchievement(param1:String):Bool {
      #if air
      return ASCompat.asBool(extensionContext.call("AIRSteam_IsAchievement", param1));
      #elseif (cpp && !air)
		return Steam.getAchievement(param1);
		#else
		return false;
		#end
   }

   public function getStatInt(param1:String):Int {
      #if air
      return ASCompat.asInt(extensionContext.call("AIRSteam_GetStatInt", param1));
      #elseif (cpp && !air)
		return Steam.getStatInt(param1);
		#else
		return 0;
		#end
   }

   public function setStatInt(param1:String, param2:Int):Bool {
      #if air
      return ASCompat.asBool(extensionContext.call("AIRSteam_SetStatInt", [param1, param2]));
      #elseif (cpp && !air)
		return Steam.setStatInt(param1, param2);
		#else
		return false;
		#end
   }

   public function storeStats():Bool {
      #if air
      return ASCompat.asBool(extensionContext.call("AIRSteam_StoreStats"));
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

   public function resetAllStats(param1:Bool):Bool {
      #if air
      return ASCompat.asBool(extensionContext.call("AIRSteam_ResetAllStats", param1));
      #else
		return false;
		#end
   }

   public function inputInit():Bool {
      #if air
      return ASCompat.asBool(extensionContext.call("AIRSteam_InputInit"));
      #elseif (cpp && !air)
		return Steam.active && Steam.controllers != null && Steam.controllers.active;
		#else
		return false;
		#end
   }

   public function runFrame():Bool {
      #if air
      return ASCompat.asBool(extensionContext.call("AIRSteam_RunFrame"));
      #elseif (cpp && !air)
		Steam.onEnterFrame();
		return true;
		#else
		return false;
		#end
   }

   public function getConnectedControllers():Array<ASAny> {
      #if air
      return ASCompat.dynamicAs(extensionContext.call("AIRSteam_GetConnectedControllers"), Array);
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

   public function getActionSetHandle(param1:String):String {
      #if air
      return ASCompat.asString(extensionContext.call("AIRSteam_GetActionSetHandle", param1));
      #elseif (cpp && !air)
		return actionHandleToString(Steam.controllers != null ? Steam.controllers.getActionSetHandle(param1) : -1);
		#else
		return "0";
		#end
   }

   public function getDigitalActionHandle(param1:String):String {
      #if air
      return ASCompat.asString(extensionContext.call("AIRSteam_GetDigitalActionHandle", param1));
      #elseif (cpp && !air)
		return actionHandleToString(Steam.controllers != null ? Steam.controllers.getDigitalActionHandle(param1) : -1);
		#else
		return "0";
		#end
   }

   public function getAnalogActionHandle(param1:String):String {
      #if air
      return ASCompat.asString(extensionContext.call("AIRSteam_GetAnalogActionHandle", param1));
      #elseif (cpp && !air)
		return actionHandleToString(Steam.controllers != null ? Steam.controllers.getAnalogActionHandle(param1) : -1);
		#else
		return "0";
		#end
   }

   public function getDigitalActionData(param1:String, param2:String):InputDigitalActionData {
      #if air
      return ASCompat.dynamicAs(extensionContext.call("AIRSteam_GetDigitalActionData", [param1, param2]), InputDigitalActionData);
      #elseif (cpp && !air)
		var result = new InputDigitalActionData();
		if (Steam.controllers != null) {
			var data:ControllerDigitalActionData = Steam.controllers.getDigitalActionData(parseHandle(param1), parseHandle(param2));
			result.bState = data.bState;
			result.bActive = data.bActive;
		}
		return result;
		#else
		return new InputDigitalActionData();
		#end
   }

   public function getAnalogActionData(param1:String, param2:String):InputAnalogActionData {
      #if air
      return ASCompat.dynamicAs(extensionContext.call("AIRSteam_GetAnalogActionData", [param1, param2]), InputAnalogActionData);
      #elseif (cpp && !air)
		var result = new InputAnalogActionData();
		if (Steam.controllers != null) {
			var data:ControllerAnalogActionData = Steam.controllers.getAnalogActionData(parseHandle(param1), parseHandle(param2));
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

   public function activateActionSet(param1:String, param2:String):Bool {
      #if air
      return ASCompat.asBool(extensionContext.call("AIRSteam_ActivateActionSet", [param1, param2]));
      #elseif (cpp && !air)
		return Steam.controllers != null && Steam.controllers.activateActionSet(parseHandle(param1), parseHandle(param2)) != 0;
		#else
		return false;
		#end
   }

   public function getDigitalActionOrigins(param1:String, param2:String, param3:String):Array<ASAny> {
      #if air
      return ASCompat.dynamicAs(extensionContext.call("AIRSteam_GetDigitalActionOrigins", [param1, param2, param3]), Array);
      #elseif (cpp && !air)
		var result:Array<ASAny> = [];
		if (Steam.controllers != null) {
			var origins:Array<EInputActionOrigin> = [];
			Steam.controllers.getDigitalActionOrigins(parseHandle(param1), parseHandle(param2), parseHandle(param3), origins);
			for (origin in origins) {
				if ((origin : Null<EInputActionOrigin>) != null) {
					result.push(Std.string(cast(origin, Int)));
				}
			}
		}
		return result;
		#else
		return [];
		#end
   }

   public function getGlyphPNGForActionOrigin(param1:String, param2:Int, param3:Int):String {
      #if air
      return ASCompat.asString(extensionContext.call("AIRSteam_GetGlyphPNGForActionOrigin", [param1, param2, param3]));
      #elseif (cpp && !air)
		return Steam.controllers != null ? Steam.controllers.getGlyphForActionOrigin(cast parseHandle(param1)) : "";
		#else
		return "";
		#end
   }

   public function steamInputShutdown():Bool {
      #if air
      return ASCompat.asBool(extensionContext.call("AIRSteam_SteamInputShutDown"));
      #elseif (cpp && !air)
		if (Steam.controllers != null && Steam.controllers.active) {
			Steam.controllers.shutdown();
		}
		return true;
		#else
		return false;
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
