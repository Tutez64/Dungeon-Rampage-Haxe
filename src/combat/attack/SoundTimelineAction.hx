package combat.attack;

import actor.ActorGameObject;
import actor.ActorView;
import brain.assetRepository.AssetLoadingComponent;
import brain.logger.Logger;
import facade.DBFacade;
import sound.DBSoundComponent;

class SoundTimelineAction extends AttackTimelineAction {
	public static inline final TYPE = "sound";

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSoundComponent:DBSoundComponent;

	var mSwfPath:String;

	var mSoundName:String;

	public function new(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, swfPath:String, soundName:String) {
		super(actorGameObject, actorView, dbFacade);
		mSwfPath = swfPath;
		mSoundName = soundName;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mSoundComponent = new DBSoundComponent(mDBFacade);
	}

	public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:ASObject):SoundTimelineAction {
		return new SoundTimelineAction(actorGameObject, actorView, dbFacade, actionObj.path, actionObj.name);
	}

	override public function execute(timeline:ScriptTimeline) {
		super.execute(timeline);
		if (ASCompat.stringAsBool(mSwfPath) && ASCompat.stringAsBool(mSoundName)) {
			mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(mSwfPath), mSoundName, function(param1:brain.sound.SoundAsset) {
				mSoundComponent.playSfxOneShot(param1, mActorView.worldCenter);
			});
		} else {
			Logger.error("SoundTimelineAction: invalid sound: swfPath: " + mSwfPath + " soundName: " + mSoundName);
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
