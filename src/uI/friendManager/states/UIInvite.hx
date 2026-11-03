package uI.friendManager.states;

import account.SteamIdConverter;
import brain.assetRepository.AssetLoadingComponent;
import brain.event.EventComponent;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.uI.UIInputText;
import brain.uI.UIObject;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import brain.jsonRPC.JSONRPCService;
import dBGlobals.DBGlobal;
import distributedObjects.PresenceManager;
import events.FriendSummaryNewsFeedEvent;
import events.FriendshipEvent;
import facade.DBFacade;
import facade.Locale;
import town.TownStateMachine;
import uI.friendManager.UIFriendManager;
import uI.popup.DBUIOneButtonPopup;
import com.amanitadesign.steam.SteamEvent;
import flash.desktop.Clipboard;
import flash.display.MovieClip;
import flash.external.ExternalInterface;

class UIInvite extends UIFMState {
	static inline final MAX_INVITE_STRING = (200 : UInt);

	static inline final TURN_OFF_WARNING_TIMER = (2 : UInt);

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mEventComponent:EventComponent;

	var mEmailText:String;

	var mInviteUIMC:MovieClip;

	var mInviteInputText:UIInputText;

	var mInviteViaEmailButton:UIButton;

	var mCopyFriendCodeButton:UIButton;

	var mLogicalWorkComponent:LogicalWorkComponent;

	public function new(uiFriendManager:UIFriendManager, dbFacade:DBFacade, townStateMachine:TownStateMachine) {
		super(dbFacade, uiFriendManager, townStateMachine);
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mEventComponent = new EventComponent(mDBFacade);
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "UIInvite");
	}

	override public function enter() {
		Logger.debug("Entered Invite State");
		mUIFriendManager.updateHeading(Locale.getString("FRIEND_MANAGEMENT_HEADING_INVITE"));
		var _loc1_ = SteamIdConverter.convertSteamID64ToSteamHex(mDBFacade.mSteamUserId);
		mUIFriendManager.updateDescription(Locale.getString("FRIEND_MANAGEMENT_DESCRIPTION_INVITE") + _loc1_, true);
		setupUI();
	}

	public function setupUI() {
		var steamHex:String;
		var inviteUIClass = mTownStateMachine.getTownAsset("popup_invite_B");
		mInviteUIMC = ASCompat.dynamicAs(ASCompat.createInstance(inviteUIClass, []), MovieClip);
		mUIFriendManager.addToUI(mInviteUIMC);
		mInviteUIMC.x = 300;
		mInviteUIMC.y = 150;
		steamHex = SteamIdConverter.convertSteamID64ToSteamHex(mDBFacade.mSteamUserId);
		Locale.setText(ASCompat.coerce((mInviteUIMC : ASAny).search_label2, flash.text.TextField), "FRIEND_MANAGEMENT_DESCRIPTION_INVITE_2", null, 2.73);
		TextUtil.fitToField(ASCompat.coerce((mInviteUIMC : ASAny).search_label2, flash.text.TextField));
		ASCompat.setProperty((mInviteUIMC : ASAny).search_label1, "visible", false);
		ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "textColor", 16711680);
		ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
		ASCompat.setProperty((mInviteUIMC : ASAny).message_label, "visible", false);
		mInviteInputText = new UIInputText(mDBFacade, ASCompat.coerce((mInviteUIMC : ASAny).friend_enterEmailId, flash.display.MovieClip));
		mInviteInputText.defaultText = Locale.getString("DRINVITE_PROMPT");
		mInviteInputText.enterCallback = inviteViaEmail;
		mInviteInputText.focusInCallback = function() {
			if (mDBFacade.steamInputManager.usesSteamOnScreenKeyboard) {
				mDBFacade.steamInputManager.showFloatingGamepadTextInputForField(mInviteInputText.textField);
			}
		};
		mInviteInputText.cancelCallback = function() {
			mInviteInputText.releaseKeyboardFocus();
		};
		mInviteInputText.focusOutCallback = function() {
			if (mInviteInputText.text == "") {
				mInviteInputText.defaultText = Locale.getString("DRINVITE_PROMPT");
			}
		};
		mInviteInputText.textField.maxChars = 200;
		mInviteInputText.textField.multiline = false;
		mInviteInputText.textField.wordWrap = false;
		mInviteInputText.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mInviteInputText.menuNavigationKeysEnabled = true;
		mDBFacade.mSteamworks.addEventListener(SteamEvent.STEAM_RESPONSE, onSteamResponse);
		mInviteViaEmailButton = new UIButton(mDBFacade, ASCompat.coerce((mInviteUIMC : ASAny).send_button, flash.display.MovieClip));
		Locale.setText(mInviteViaEmailButton.label, "DRINVITE_FRIEND_EMAIL_BUTTON");
		mInviteViaEmailButton.releaseCallback = function() {
			var _loc1_ = new compat.RegExp("[\\s\\r\\n]*", "gim");
			ASCompat.setProperty((mInviteUIMC : ASAny).friend_enterEmailId.textField, "text",
				_loc1_.replace(Std.string((mInviteUIMC : ASAny).friend_enterEmailId.textField.text), ""));
			inviteViaEmail((mInviteUIMC : ASAny).friend_enterEmailId.textField.text, inviteViaEmailSuccessCallback);
			ASCompat.setProperty((mInviteUIMC : ASAny).friend_enterEmailId.textField, "text", "");
		};
		mCopyFriendCodeButton = new UIButton(mDBFacade, ASCompat.coerce((mInviteUIMC : ASAny).copy_button, flash.display.MovieClip));
		Locale.setText(mCopyFriendCodeButton.label, "DRINVITE_COPY_FRIEND_CODE_BUTTON");
		mCopyFriendCodeButton.releaseCallback = function() {
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData("air:text", steamHex);
		};
		setupMenuNavigation();
	}

	function setupMenuNavigation() {
		mInviteInputText.navigationSetToUnselectedInteraction = function() {
			mInviteInputText.releaseKeyboardFocus();
		};
		mInviteInputText.isAbove(mInviteViaEmailButton);
		mInviteViaEmailButton.isAbove(mCopyFriendCodeButton);
		mInviteViaEmailButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mCopyFriendCodeButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
	}

	function inviteViaEmail(value:String, successCallback:ASFunction = null) {
		var finalValue:String;
		var accountIdRegex:compat.RegExp;
		var steamID64:String;
		var rpcSuccessCallback:ASFunction;
		var deadFacebookIdParameter:String;
		var rpcFunc = JSONRPCService.getFunction("DRFriendRequest", mDBFacade.rpcRoot + "friendrequests");
		var rex = new compat.RegExp("[\\s\\r\\n]*", "gim");
		mInviteInputText.text = rex.replace(mInviteInputText.text, "");
		finalValue = mInviteInputText.text;
		accountIdRegex = new compat.RegExp("^1[0-9]{9}$");
		if (accountIdRegex.test(finalValue)) {
			Logger.debug("Requested friend looks like an account ID, not a Steam ID, so not converting to email. Value: " + finalValue);
		} else {
			if (!SteamIdConverter.isValidSteamId(mInviteInputText.text)) {
				mInviteInputText.text = "";
				Locale.setText(ASCompat.coerce((mInviteUIMC : ASAny).search_label, flash.text.TextField), "DRINVITE_PROMPT_INVALID_EMAIL");
				ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", true);
				mLogicalWorkComponent.doLater(2, function(param1:brain.clock.GameClock) {
					ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
				});
				return;
			}
			steamID64 = SteamIdConverter.normalizeSteamIdToSteamID64(mInviteInputText.text);
			if (steamID64 == "") {
				mInviteInputText.text = "";
				Locale.setText(ASCompat.coerce((mInviteUIMC : ASAny).search_label, flash.text.TextField), "DRINVITE_PROMPT_INVALID_EMAIL");
				ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", true);
				mLogicalWorkComponent.doLater(2, function(param1:brain.clock.GameClock) {
					ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
				});
				return;
			}
			finalValue = steamID64 + "@steam.dr.g17s.net";
			rex = new compat.RegExp("([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}");
			if (rex.test(finalValue) == false) {
				mInviteInputText.text = "";
				Locale.setText(ASCompat.coerce((mInviteUIMC : ASAny).search_label, flash.text.TextField), "DRINVITE_PROMPT_INVALID_EMAIL");
				ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", true);
				mLogicalWorkComponent.doLater(2, function(param1:brain.clock.GameClock) {
					ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
				});
				return;
			}
		}
		rpcSuccessCallback = function(param1:ASAny) {
			var popup:DBUIOneButtonPopup;
			var requestJson:ASObject;
			var details:ASAny = param1;
			if (mInviteUIMC == null) {
				Logger.debug("Dropping DRFriendRequest result: the Invite state was exited before it returned");
				return;
			}
			if (details == null) {
				Locale.setText(ASCompat.coerce((mInviteUIMC : ASAny).search_label, flash.text.TextField), "DRINVITE_PROMPT_ALREADY_FRIEND");
				ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", true);
				mLogicalWorkComponent.doLater(2, function(param1:brain.clock.GameClock) {
					ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
				});
				return;
			}
			if (ASCompat.getQualifiedClassName(details) == "Array" && ASCompat.toNumberField(details, "length") <= 0) {
				mEmailText = value;
				popup = new DBUIOneButtonPopup(mDBFacade, "INVITE_FAILED_POPUP", Locale.getString("DRINVITE_FAILED_POPUP_TITLE"),
					Locale.getString("DRINVITE_FAILED_POPUP_DESC"), Locale.getString("OK"), invokeMailClient);
				MemoryTracker.track(popup, "DBUIOneButtonPopup - created in UIInvite.UIInvite()");
				return;
			}
			if (details == false) {
				Locale.setText(ASCompat.coerce((mInviteUIMC : ASAny).search_label, flash.text.TextField), "DRINVITE_PROMPT_INVITE_SENT");
				ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", true);
				mLogicalWorkComponent.doLater(2, function(param1:brain.clock.GameClock) {
					ASCompat.setProperty((mInviteUIMC : ASAny).search_label, "visible", false);
				});
				return;
			}
			requestJson = parseJson(details);
			mEventComponent.dispatchEvent(FriendSummaryNewsFeedEvent.forPortrait(Locale.getString("Friend_Request_Sent_to_"),
				(ASCompat.toInt(requestJson.active_skin) : UInt), value));
			mDBFacade.metrics.log("DRFriendRequest", {"friendId": requestJson.to_account_id});
			mDBFacade.steamAchievementsHelper.unlockAchievement("ADD_FRIEND");
			if (successCallback != null) {
				successCallback();
			}
		};
		deadFacebookIdParameter = "";
		rpcFunc(mDBFacade.dbAccountInfo.name, mDBFacade.dbAccountInfo.trophies, mDBFacade.dbAccountInfo.activeAvatarSkinId, deadFacebookIdParameter,
			mDBFacade.dbAccountInfo.id, finalValue, mDBFacade.demographics, mDBFacade.validationToken, rpcSuccessCallback,
			UIFriendManager.createFriendRPCErrorCallback(mDBFacade, "InviteViaEmail"));
		mInviteInputText.text = "";
	}

	function invokeMailClient() {
		if (ExternalInterface.available) {
			ExternalInterface.call("sendInviteEmail", mDBFacade.dbAccountInfo.id, mDBFacade.dbConfigManager.networkId, mDBFacade.dbAccountInfo.name,
				mEmailText);
		}
	}

	function onSteamResponse(event:SteamEvent) {
		if (event.req_type != 35 && event.req_type != 34) {
			return;
		}
		if (mInviteInputText == null || mDBFacade == null) {
			return;
		}
		if (mDBFacade.stageRef.focus != mInviteInputText.textField) {
			return;
		}
		mInviteInputText.releaseKeyboardFocus();
		mDBFacade.inputManager.clear();
	}

	public function parseJson(details:ASAny):ASObject {
		var _loc2_:Array<ASAny> = null;
		var _loc4_:ASObject = null;
		var _loc3_:Vector<UInt> = /*undefined*/ null;
		if (ASCompat.getQualifiedClassName(details) == "Array") {
			_loc2_ = ASCompat.coerce(details[0], Array);
			_loc4_ = details[1];
			_loc3_ = new Vector<UInt>();
			_loc3_.push((ASCompat.toInt(_loc4_.account_id) : UInt));
			PresenceManager.instance().addFriends(_loc3_);
			mDBFacade.dbAccountInfo.addFriendCallback(_loc2_);
			mEventComponent.dispatchEvent(new FriendshipEvent(UIFriendManager.FRIENDSHIP_MADE, (ASCompat.toInt(_loc4_.id) : UInt)));
		} else {
			_loc4_ = (details : ASObject);
		}
		Logger.debug("friendRequest: id:" + Std.string(_loc4_.id) + " from:" + Std.string(_loc4_.account_id) + " to:" + Std.string(_loc4_.to_account_id)
			+ " state:" + Std.string(_loc4_.curr_state));
		return _loc4_;
	}

	function inviteViaEmailSuccessCallback() {
		if (mInviteInputText == null) {
			return;
		}
		mInviteInputText.defaultText = Locale.getString("DRINVITE_PROMPT");
	}

	override public function exit() {
		Logger.debug("Exiting Invite State");
		mDBFacade.mSteamworks.removeEventListener(SteamEvent.STEAM_RESPONSE, onSteamResponse);
		mLogicalWorkComponent.clear();
		if (mInviteInputText != null) {
			mInviteInputText.clearNavigationAndInteractions();
			mInviteInputText.destroy();
			mInviteInputText = null;
		}
		if (mInviteViaEmailButton != null) {
			mInviteViaEmailButton.destroy();
			mInviteViaEmailButton = null;
		}
		if (mCopyFriendCodeButton != null) {
			mCopyFriendCodeButton.destroy();
			mCopyFriendCodeButton = null;
		}
		mInviteUIMC = null;
		if (mUIFriendManager != null) {
			mUIFriendManager.clearUI();
		}
	}

	override public function destroy() {
		exit();
		mLogicalWorkComponent.destroy();
		mAssetLoadingComponent.destroy();
		mEventComponent.destroy();
		super.destroy();
	}

	override public function getFirstNavigationUIObject():UIObject {
		return mInviteInputText;
	}
}
