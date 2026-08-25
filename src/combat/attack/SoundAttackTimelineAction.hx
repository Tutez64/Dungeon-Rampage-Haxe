package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.assetRepository.AssetLoadingComponent;
import facade.DBFacade;
import gameMasterDictionary.GMAttack;
import sound.DBSoundComponent;

class SoundAttackTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "attackSound";

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSoundComponent:DBSoundComponent;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) {
		super(actorGameObject, actorView, dbFacade);
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mSoundComponent = new DBSoundComponent(mDBFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade,
			actionObj:ASObject):SoundAttackTimelineAction {
		return new SoundAttackTimelineAction(actorGameObject, actorView, dbFacade);
	}

	override public function execute(timeline:ScriptTimeline) {
		var gmAttack:GMAttack;
		super.execute(timeline);
		gmAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackById.itemFor(mAttackType), gameMasterDictionary.GMAttack);
		if (gmAttack != null && ASCompat.stringAsBool(gmAttack.AttackSound)) {
			mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"), gmAttack.AttackSound,
				function(param1:brain.sound.SoundAsset) {
					mSoundComponent.playSfxOneShot(param1, mActorView.worldCenter, 0, gmAttack.AttackVolume);
				});
		}
	}

	override public function destroy() {
		mSoundComponent.destroy();
		mSoundComponent = null;
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		super.destroy();
	}
}
