package magicWords;

import brain.clock.GameClock;
import brain.logger.Logger;
import brain.jsonRPC.JSONRPCService;
import facade.DBFacade;
import metrics.DrawCallGraph;
import metrics.GpuMemoryGraph;
import metrics.StarlingStatsReporter;
import com.junkbyte.console.KeyBind;

class MagicWordManager {
	var mDBFacade:DBFacade;

	var mCheckedAdmin:Bool = false;

	var mIsAdmin:Bool = false;

	var mStarlingStatsReporter:StarlingStatsReporter;

	var mGpuMemoryGraph:GpuMemoryGraph;

	var mDrawCallGraph:DrawCallGraph;

	var mSmallTextOverlay:SmallTextOverlay;

	public function new(dbFacade:DBFacade) {
		mDBFacade = dbFacade;
		setupClientWords();
		setupServerWords();
		Logger.bindKey(new KeyBind("`"), askForAdmin);
		mGpuMemoryGraph = new GpuMemoryGraph(dbFacade);
		mDrawCallGraph = new DrawCallGraph(dbFacade);
	}

	public function askForAdmin() {
		var askForAdminFunc:ASFunction;
		if (!mCheckedAdmin) {
			askForAdminFunc = JSONRPCService.getFunction("AskIfAdmin", mDBFacade.rpcRoot + "webMagicWord");
			askForAdminFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, mDBFacade.demographics, function(param1:Int) {
				if (param1 != 0) {
					mIsAdmin = true;
					Logger.enableCommandLine();
					Logger.displayConsole();
					Logger.log("Setting Console Commands for admin. Push the CL button on top of this frame for the commandline.");
				} else {
					Logger.log("You are not an admin.");
				}
				mCheckedAdmin = true;
			}, function(param1:Error) {
				Logger.log("AskIfAdmin: ERROR:" + Std.string(param1));
			});
		} else if (mIsAdmin) {
			if (Logger.isConsoleVisible()) {
				Logger.hideConsole();
			} else {
				Logger.displayConsole();
			}
		}
	}

	public function setupClientWords() {
		Logger.addSlashCommand("listAccountId", function() {
			var _loc1_:Int = mDBFacade.accountId;
			Logger.log("" + _loc1_);
		});
		Logger.addSlashCommand("helpCommands", function() {
			Logger.log("These are the magic words:");
			Logger.listSlashCommands();
		});
		Logger.addSlashCommand("test3", function(param1:String = "") {
			var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
			Logger.log("" + _loc2_);
		});
		Logger.addSlashCommand("showCollisions", function(param1:String = "") {
			Logger.log("showing Collisions");
			mDBFacade.showCollisions = true;
		});
		Logger.addSlashCommand("showFps", function() {
			mDBFacade.toggleFpsOverlay();
			Logger.log("Toggled FPS overlay");
		});
		Logger.addSlashCommand("showSmallText", function(param1:String = "") {
			var _loc2_:SmallTextOverlay = null;
			var _loc3_:ASObject = parseSmallTextOptions(param1);
			if (_loc3_ == null) {
				return;
			}
			if (mSmallTextOverlay != null) {
				_loc2_ = mSmallTextOverlay;
				mSmallTextOverlay = null;
				_loc2_.destroy();
				Logger.log("Small-text overlay off");
			} else {
				mSmallTextOverlay = new SmallTextOverlay(mDBFacade, ASCompat.toNumberField(_loc3_, "minPx"), ASCompat.toBool(_loc3_.useLowercase));
				Logger.log("Outlining visible text under "
					+ Std.string(_loc3_.minPx)
					+ "px ("
					+ (ASCompat.toBool(_loc3_.useLowercase) ? "lowercase" : "uppercase")
					+ " height)");
			}
		},
			"Toggle text outlines: /showSmallText [px] [uppercase|lowercase] (default 9, uppercase)");
		Logger.addSlashCommand("listSmallText", function(param1:String = "") {
			var _loc2_:ASObject = parseSmallTextOptions(param1);
			if (_loc2_ != null) {
				SmallTextOverlay.logSmallText(mDBFacade, ASCompat.toNumberField(_loc2_, "minPx"), ASCompat.toBool(_loc2_.useLowercase));
			}
		},
			"Log small text with display paths: /listSmallText [px] [uppercase|lowercase] (default 9, uppercase)");
		Logger.addSlashCommand("showStarlingStats", function(param1:String = "") {
			var _loc2_:Array<ASAny> = ASCompat.coerce(param1.length > 0 ? (cast new compat.RegExp("\\s+").split(param1)) : [], Array);
			var _loc4_:String = if (ASCompat.toBool(_loc2_[0])) _loc2_[0] else "right";
			var _loc3_:String = if (ASCompat.toBool(_loc2_[1])) _loc2_[1] else "center";
			var _loc5_ = ASCompat.toNumber(if (ASCompat.toBool(_loc2_[2])) _loc2_[2] else 5);
			mDBFacade.starlingLayerManager.toggleStatsAt(_loc4_, _loc3_, _loc5_);
			Logger.log("Toggled Starling stats overlay (fps, memory, gpu memory, draw calls) at " + _loc4_ + "/" + _loc3_);
		}, "Toggle Starling stats overlay (e.g., /showStarlingStats right center 5)");
		Logger.addSlashCommand("createStarlingReport", function() {
			if (mStarlingStatsReporter == null) {
				mStarlingStatsReporter = new StarlingStatsReporter(mDBFacade.starlingLayerManager.starlingInstance);
			}
			mStarlingStatsReporter.toggle();
		},
			"Start/stop sampling Starling stats (fps, memory, gpu memory, draw calls) into StarlingReport.txt next to the game logs");
		Logger.addSlashCommand("setClockOffset", function(param1:String = "") {
			var _loc5_ = Math.NaN;
			var _loc3_ = Math.NaN;
			var _loc4_ = Math.NaN;
			var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
			if (!ASCompat.toBool(_loc2_[0])) {
				showHelp();
				Logger.log("/setClockOffset days [hours] [minutes]");
				Logger.log("\tsets the offset for the webserver time.");
			} else {
				_loc5_ = ASCompat.toNumber(_loc2_[0]);
				_loc3_ = 0;
				_loc4_ = 0;
				if (_loc2_.length >= 2) {
					_loc3_ = ASCompat.toNumber(_loc2_[1]);
				}
				if (_loc2_.length >= 3) {
					_loc4_ = ASCompat.toNumber(_loc2_[2]);
				}
				GameClock.setUserWebOffset(ASCompat.floatToInt(_loc5_), ASCompat.floatToInt(_loc3_), ASCompat.floatToInt(_loc4_));
			}
		});
		Logger.addSlashCommand("getSteamAvatarImage", function(param1:Int) {
			var requestFunc:ASFunction;
			var param = param1;
			Logger.log("Getting Steam avatar image...");
			requestFunc = JSONRPCService.getFunction("GetSteamAvatarPictureUrl", mDBFacade.rpcRoot + "account");
			requestFunc(param, function(param1:String) {
				Logger.info("Result: " + param1);
			}, function(param1:Error) {
				Logger.info("Error: " + param1);
			});
		}, "Call Steam API to get an avatar image URL from an account ID");
	}

	public function setupServerWords() {
		Logger.addSlashCommand("serverTime", function() {
			getServerTime();
		});
		Logger.addSlashCommand("magicWordTest", function() {
			runMagicWordTest();
		});
		Logger.addSlashCommand("unlockAllMapNodes", function() {
			unlockAllMapNodes();
		});
		Logger.addSlashCommand("lockAllMapNodes", function() {
			lockAllMapNodes();
		});
		Logger.addSlashCommand("unlockMapNodes", function(param1:String = "") {
			var _loc3_ = 0;
			var _loc4_ = 0;
			var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
			if (!ASCompat.toBool(_loc2_[0])) {
				showHelp();
				Logger.log("/unlockMapNodes startNode [endNode]");
				Logger.log("\tunlocks map nodes from the start node to the end node");
			} else {
				_loc3_ = ASCompat.toInt(_loc2_[0]);
				_loc4_ = 0;
				if (_loc2_.length >= 2) {
					_loc4_ = ASCompat.toInt(_loc2_[1]);
				}
				unlockMapNodes(_loc3_, _loc4_);
			}
		});
		Logger.addSlashCommand("giveGems", function(param1:String = "") {
			var _loc3_ = 0;
			var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
			if (!ASCompat.toBool(_loc2_[0])) {
				showHelp();
				Logger.log("/giveGems numberGems");
				Logger.log("\tgives you gems.");
			} else {
				_loc3_ = ASCompat.toInt(_loc2_[0]);
				giveGems(_loc3_);
			}
		});
		Logger.addSlashCommand("giveCoins", function(param1:String = "") {
			var _loc3_ = 0;
			var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
			if (!ASCompat.toBool(_loc2_[0])) {
				showHelp();
				Logger.log("/giveCoins numberCoins");
				Logger.log("\tgives you coins.");
			} else {
				_loc3_ = ASCompat.toInt(_loc2_[0]);
				giveCoins(_loc3_);
			}
		});
		Logger.addSlashCommand("giveXp", function(param1:String = "") {
			var _loc3_ = 0;
			var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
			if (!ASCompat.toBool(_loc2_[0])) {
				showHelp();
				Logger.log("/giveXp xp");
				Logger.log("\tgives the current avatar xp");
			} else {
				_loc3_ = ASCompat.toInt(_loc2_[0]);
				giveXp(_loc3_);
			}
		});
		Logger.addSlashCommand("setAscensionLevel", function(param1:String = "") {
			var _loc3_ = 0;
			var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
			if (!ASCompat.toBool(_loc2_[0])) {
				showHelp();
				Logger.log("/setAscensionLevel level");
				Logger.log("\tsets the current avatar\'s ascension level.");
			} else {
				_loc3_ = ASCompat.toInt(_loc2_[0]);
				setAscensionLevel(_loc3_);
			}
		});
		Logger.addSlashCommand("ascendAvatar", function() {
			ascendAvatar();
		});
	}

	public function AskForAccountDetailsRefresh() {
		var useAccountBoosterFunc = JSONRPCService.getFunction("AskForAccountDetails", mDBFacade.rpcRoot + "webMagicWord");
		useAccountBoosterFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, mDBFacade.demographics, function(param1:ASAny) {
			Logger.log("Got new account details");
			mDBFacade.dbAccountInfo.parseResponse(param1);
		}, function(param1:Error) {
			Logger.log("AskForAccountDetails: ERROR:" + Std.string(param1));
		});
	}

	public function getServerTime() {
		var requestFunc = JSONRPCService.getFunction("getWebServerTimestamp", mDBFacade.rpcRoot + "webMagicWord");
		requestFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, mDBFacade.demographics, function(param1:Array<ASAny>) {
			Logger.log("serverTime:" + param1);
		}, function(param1:Error) {
			Logger.log("serverTime: ERROR:" + Std.string(param1));
		});
	}

	public function runMagicWordTest() {
		var argsArray:Array<ASAny> = ["Test"];
		var requestFunc = JSONRPCService.getFunction("doMagicWord", mDBFacade.rpcRoot + "webMagicWord");
		requestFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, argsArray, mDBFacade.demographics, function(param1:Array<ASAny>) {
			Logger.log("magicWordTest:" + param1);
		}, function(param1:Error) {
			Logger.log("magicWordTest: ERROR:" + Std.string(param1));
		});
	}

	public function unlockAllMapNodes() {
		var argsArray:Array<ASAny> = ["UnlockAllMapNodes", mDBFacade.dbAccountInfo.activeAvatarId];
		var requestFunc = JSONRPCService.getFunction("doMagicWord", mDBFacade.rpcRoot + "webMagicWord");
		requestFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, argsArray, mDBFacade.demographics, function(param1:Array<ASAny>) {
			Logger.log("unlockAllMapNodes:" + param1);
			AskForAccountDetailsRefresh();
		}, function(param1:Error) {
			Logger.log("unlockAllMapNodes: ERROR:" + Std.string(param1));
		});
	}

	public function lockAllMapNodes() {
		var argsArray:Array<ASAny> = ["LockAllMapNodes", mDBFacade.dbAccountInfo.activeAvatarId];
		var requestFunc = JSONRPCService.getFunction("doMagicWord", mDBFacade.rpcRoot + "webMagicWord");
		requestFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, argsArray, mDBFacade.demographics, function(param1:Array<ASAny>) {
			Logger.log("lockAllMapNodes:" + param1);
			AskForAccountDetailsRefresh();
		}, function(param1:Error) {
			Logger.log("lockAllMapNodes: ERROR:" + Std.string(param1));
		});
	}

	public function unlockMapNodes(startNode:Int, endNode:Int = 0) {
		var argsArray:Array<ASAny>;
		var requestFunc:ASFunction;
		if (endNode < startNode) {
			endNode = startNode;
		}
		argsArray = ["UnlockMapNodes", mDBFacade.dbAccountInfo.activeAvatarId, startNode, endNode];
		requestFunc = JSONRPCService.getFunction("doMagicWord", mDBFacade.rpcRoot + "webMagicWord");
		requestFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, argsArray, mDBFacade.demographics, function(param1:Array<ASAny>) {
			Logger.log("unlockMapNodes:" + param1);
			AskForAccountDetailsRefresh();
		}, function(param1:Error) {
			Logger.log("unlockMapNodes: ERROR:" + Std.string(param1));
		});
	}

	public function giveGems(numGems:Int) {
		var argsArray:Array<ASAny> = ["GiveGems", numGems];
		var requestFunc = JSONRPCService.getFunction("doMagicWord", mDBFacade.rpcRoot + "webMagicWord");
		requestFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, argsArray, mDBFacade.demographics, function(param1:Array<ASAny>) {
			Logger.log("giveGems:" + param1);
			AskForAccountDetailsRefresh();
		}, function(param1:Error) {
			Logger.log("giveGems: ERROR:" + Std.string(param1));
		});
	}

	public function giveCoins(numCoins:Int) {
		var argsArray:Array<ASAny> = ["GiveCoins", numCoins];
		var requestFunc = JSONRPCService.getFunction("doMagicWord", mDBFacade.rpcRoot + "webMagicWord");
		requestFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, argsArray, mDBFacade.demographics, function(param1:Array<ASAny>) {
			Logger.log("giveCoins:" + param1);
			AskForAccountDetailsRefresh();
		}, function(param1:Error) {
			Logger.log("giveCoins: ERROR:" + Std.string(param1));
		});
	}

	public function giveXp(xpAmount:Int) {
		var argsArray:Array<ASAny> = ["GiveXp", mDBFacade.dbAccountInfo.activeAvatarId, xpAmount];
		var requestFunc = JSONRPCService.getFunction("doMagicWord", mDBFacade.rpcRoot + "webMagicWord");
		requestFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, argsArray, mDBFacade.demographics, function(param1:Array<ASAny>) {
			Logger.log("giveXp:" + param1);
			AskForAccountDetailsRefresh();
		}, function(param1:Error) {
			Logger.log("giveXp: ERROR:" + Std.string(param1));
		});
	}

	public function setAscensionLevel(level:Int) {
		var argsArray:Array<ASAny> = ["SetAscensionLevel", mDBFacade.dbAccountInfo.activeAvatarId, level];
		var requestFunc = JSONRPCService.getFunction("doMagicWord", mDBFacade.rpcRoot + "webMagicWord");
		requestFunc(mDBFacade.dbAccountInfo.id, mDBFacade.validationToken, argsArray, mDBFacade.demographics, function(param1:Array<ASAny>) {
			Logger.log("setAscensionLevel:" + param1);
			AskForAccountDetailsRefresh();
		}, function(param1:Error) {
			Logger.log("setAscensionLevel: ERROR:" + Std.string(param1));
		});
	}

	public function ascendAvatar() {
		var requestFunc = JSONRPCService.getFunction("ascendAvatar", mDBFacade.rpcRoot + "avatarrecord");
		requestFunc(mDBFacade.dbAccountInfo.activeAvatarId, function(param1:ASAny) {
			Logger.log("ascendAvatar:" + Std.string(param1));
			AskForAccountDetailsRefresh();
		}, function(param1:Error) {
			Logger.log("ascendAvatar: ERROR:" + Std.string(param1));
		});
	}

	function parseSmallTextOptions(param:String):ASObject {
		var _loc3_:String = null;
		var _loc2_:Array<ASAny> = ASCompat.coerce(ASCompat.orValue((cast new compat.RegExp("\\S+", "g").match(param)), []), Array);
		var _loc4_ = false;
		if (_loc2_.length > 0) {
			_loc3_ = ASCompat.toString(_loc2_[_loc2_.length - 1]).toLowerCase();
			if (_loc3_ == "uppercase" || _loc3_ == "lowercase") {
				_loc4_ = _loc3_ == "lowercase";
				_loc2_.pop();
			}
		}
		var _loc5_ = _loc2_.length == 0 ? 9 : ASCompat.toNumber(_loc2_[0]);
		if (_loc2_.length > 1 || !Math.isFinite(_loc5_) || _loc5_ <= 0) {
			Logger.log("Usage: /showSmallText [px] [uppercase|lowercase] or /listSmallText [px] [uppercase|lowercase], px a positive number (default 9, uppercase)");
			return null;
		}
		return {
			"minPx": _loc5_,
			"useLowercase": _loc4_
		};
	}

	public function showHelp() {
		Logger.log("Please use the command following this format:");
		Logger.log("/command parameter [optional parameter]");
	}
}
