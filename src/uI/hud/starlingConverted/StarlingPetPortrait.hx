package uI.hud.starlingConverted;

import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import distributedObjects.NPCGameObject;
import events.GameObjectEvent;
import events.HpEvent;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import flash.display.MovieClip;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;

class StarlingPetPortrait {
	var mFacade:DBFacade;

	var mView:ArtView;

	var mPet:NPCGameObject;

	var mDead:Bool = false;

	var mEvents:EventComponent;

	var mWork:LogicalWorkComponent;

	var mTask:Task;

	var mHp:StarlingBar;

	var mCooldown:TimelineView;

	var mIcon:StarlingHudIcon;

	var mPetButton:StarlingButton;

	var mNoneButton:StarlingButton;

	var mTooltip:StarlingTooltip;

	var mNoneTooltip:StarlingTooltip;

	var mClip:MovieClip;

	var mInput:StarlingInput;

	var mChanged:ASFunction;

	var mSeconds:Float = Math.NaN;

	var mRespawnPrefix:String;

	public function new(facade:DBFacade, view:ArtView, ticker:HudTicker, input:StarlingInput, space:DisplayObject, model:MovieClip, pet:NPCGameObject,
			changed:ASFunction) {
		var _loc10_:MovieClip = null;

		mFacade = facade;
		mView = view;
		mPet = pet;
		mInput = input;
		mChanged = changed;
		mEvents = new EventComponent(facade);
		mWork = new LogicalWorkComponent(facade, "StarlingPetPortrait");
		mClip = ASCompat.coerce((model : ASAny).pet.tooltip, flash.display.MovieClip);
		HudArtConverter.stopTree(ASCompat.coerce((model : ASAny).pet, flash.display.DisplayObject));
		mPetButton = new StarlingButton(view, "pet", space);
		mTooltip = new StarlingTooltip(facade, mPetButton.root, space, mClip);
		mPetButton.rollOverCallback = mTooltip.rollOver;
		mPetButton.rollOutCallback = mTooltip.hide;
		input.add(mPetButton, false, true);
		var _loc9_ = (model : ASAny).hasOwnProperty("pet_none") ? ASCompat.dynamicAs((model : ASAny).pet_none, MovieClip) : null;
		if (_loc9_ != null && view.node("pet_none") != null) {
			HudArtConverter.stopTree(_loc9_);
			mNoneButton = new StarlingButton(view, "pet_none", space);
			_loc10_ = ASCompat.dynamicAs((_loc9_ : ASAny).tooltip, MovieClip);
			if (_loc10_ != null) {
				Locale.setText(ASCompat.coerce((_loc10_ : ASAny).title_label, flash.text.TextField), "NO_PET_EQUIPPED_TOOLTIP_TITLE");
				Locale.setText(ASCompat.coerce((_loc10_ : ASAny).description_label, flash.text.TextField), "NO_PET_EQUIPPED_TOOLTIP_DESCRIPTION");
				mNoneTooltip = new StarlingTooltip(facade, mNoneButton.root, space, _loc10_);
				mNoneButton.rollOverCallback = mNoneTooltip.rollOver;
				mNoneButton.rollOutCallback = mNoneTooltip.hide;
			}
			input.add(mNoneButton, false, true);
		}
		mHp = new StarlingBar(view.node("pet.hp.hpBar"), null, ticker);
		mCooldown = ASCompat.reinterpretAs(view.node("pet.cooldown"), TimelineView);
		if (mCooldown != null) {
			mCooldown.stop();
			mCooldown.stageRate = false;
		}
		show("pet.hp_death", false);
		show("pet.cooldown", false);
		show("pet", pet != null);
		show("pet_none", pet == null);
		if (pet != null) {
			TextUtil.setText(ASCompat.coerce((mClip : ASAny).title_label, flash.text.TextField),
				GameMasterLocale.getGameMasterSubString("PET_NAME", pet.gmNpc.Constant).toUpperCase());
			TextUtil.setText(ASCompat.coerce((mClip : ASAny).description_label, flash.text.TextField),
				GameMasterLocale.getGameMasterSubString("PET_DESCRIPTION", pet.gmNpc.Constant));
			mEvents.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE", pet.id), hpChanged);
			mHp.value = pet.maxHitPoints > 0 ? pet.hitPoints / pet.maxHitPoints : 0;
			mIcon = new StarlingHudIcon(facade, ticker, ASCompat.reinterpretAs(view.node("pet.graphic"), DisplayObjectContainer), changed);
			loadIcon(pet);
		}
		changed();
	}

	function loadIcon(pet:NPCGameObject) {
		mIcon.load(pet.actorData.gMActor.IconSwfFilepath, pet.actorData.gMActor.IconName, 1.1764705882352942);
	}

	function hpChanged(event:HpEvent) {
		try {
			mHp.value = event.maxHp > 0 ? event.hp / event.maxHp : 0;
			mChanged();
		} catch (error:Dynamic) {
			StarlingHud.reportError(ASCompat.asError(error));
		}
	}

	function show(path:String, value:Bool) {
		var _loc3_ = ASCompat.reinterpretAs(mView.node(path), ArtDisplay);
		if (_loc3_ != null) {
			_loc3_.setHudVisibility(value);
		}
	}

	public function petDeath() {
		if (mPet == null) {
			return;
		}
		mDead = true;
		mEvents.removeAllListeners();
		mSeconds = mPet.gmNpc.RespawnT;
		if (mSeconds > 0) {
			mRespawnPrefix = new compat.RegExp("[:\\s]+$").replace(Locale.getString("PET_RESPAWNS_IN"), "") + ": ";
			loadIcon(mPet);
			show("pet.hp_death", true);
			show("pet.cooldown", true);
			if (mCooldown != null) {
				mCooldown.playRate = mCooldown.art.totalFrames * mFacade.gameClock.tickLength / mPet.gmNpc.RespawnT;
				mCooldown.play();
			}
			updateDescription();
			mTask = mWork.doEverySeconds(1, countdown);
		} else {
			show("pet", false);
		}
		mPet = null;
		mChanged();
	}

	function updateDescription() {
		TextUtil.setText(ASCompat.coerce((mClip : ASAny).description_label, flash.text.TextField), mRespawnPrefix + Std.string(mSeconds));
	}

	function countdown(clock:GameClock) {
		try {
			mSeconds = mSeconds - 1;
			updateDescription();
			if (mSeconds <= 0) {
				mTask.destroy();
				mTask = null;
			}
		} catch (error:Dynamic) {
			StarlingHud.reportError(ASCompat.asError(error));
		}
	}

	@:isVar public var petNPCGameObject(get, never):NPCGameObject;

	public function get_petNPCGameObject():NPCGameObject {
		return mPet;
	}

	@:isVar public var isDead(get, never):Bool;

	public function get_isDead():Bool {
		return mDead;
	}

	public function hideTooltip() {
		mTooltip.hide();
		if (mNoneTooltip != null) {
			mNoneTooltip.hide();
		}
	}

	public function dispose() {
		StarlingHud.disposeResource(mTask, "destroy");
		StarlingHud.disposeResource(mWork, "destroy");
		StarlingHud.disposeResource(mEvents, "destroy");
		StarlingHud.disposeResource(mTooltip);
		StarlingHud.disposeResource(mNoneTooltip);
		try {
			mInput.remove(mPetButton);
		} catch (error:Dynamic) {
			StarlingHud.reportError(ASCompat.asError(error));
		}
		try {
			if (mNoneButton != null) {
				mInput.remove(mNoneButton);
			}
		} catch (noneError:Dynamic) {
			StarlingHud.reportError(ASCompat.asError(noneError));
		}
		StarlingHud.disposeResource(mPetButton);
		StarlingHud.disposeResource(mNoneButton);
		StarlingHud.disposeResource(mHp);
		StarlingHud.disposeResource(mIcon);
		StarlingHud.disposeResource(mCooldown, "stop");
		show("pet", false);
		show("pet_none", false);
		mPet = null;
		mChanged();
	}
}
