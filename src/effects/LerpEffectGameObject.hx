package effects;

import actor.ActorGameObject;
import brain.event.EventComponent;
import brain.render.tweens.Circ;
import brain.render.tweens.Sine;
import brain.render.tweens.TweenHandle;
import facade.DBFacade;
import flash.events.Event;
import flash.geom.Vector3D;

class LerpEffectGameObject extends EffectGameObject {
	static final sNextPos:Vector3D = new Vector3D();

	var mLerpTargetActor:ActorGameObject;

	var mLerpSpeed:Float = Math.NaN;

	public var mLerpTempSpeed:Float = Math.NaN;

	var mLerpTimeline:TweenHandle;

	var mLerpTargetPositionVector:Vector3D;

	var mLerpGlowColor:UInt = 0;

	var mEventComponent:EventComponent;

	public function new(facade:DBFacade, swfPath:String, className:String, playRate:Float, remoteId:UInt = (0 : UInt), assetLoadedCallback:ASFunction = null,
			lerpToActor:ActorGameObject = null, lerpSpeed:Float = 1, lerpGlowColor:UInt = (13369344 : UInt)) {
		super(facade, swfPath, className, playRate, remoteId, assetLoadedCallback);
		mLerpTargetActor = lerpToActor;
		mLerpSpeed = lerpSpeed + Math.random() * lerpSpeed / 2;
		mLerpGlowColor = lerpGlowColor;
		mLerpTargetPositionVector = new Vector3D(0, -50, 0);
		mEventComponent = new EventComponent(facade);
		mEventComponent.addListener("enterFrame", update);
		mLerpTempSpeed = 0;
		mLerpTimeline = mDBFacade.mTween.createTimeline();
		mDBFacade.mTween.appendTween(mLerpTimeline, mDBFacade.mTween.tweenMaxTo(this, 0.1, {
			"mLerpTempSpeed": -mLerpSpeed,
			"onComplete": function() {
				mLerpTempSpeed = 0;
			}
		}));
		mDBFacade.mTween.appendTween(mLerpTimeline, mDBFacade.mTween.tweenMaxTo(this, 0.65, {
			"mLerpTempSpeed": mLerpSpeed,
			"ease": Circ.easeIn
		}));
		mDBFacade.mTween.playTween(mLerpTimeline);
	}

	function update(evt:Event) {
		var _loc2_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc4_ = Math.NaN;
		if (mLerpTargetActor != null && mLerpTargetActor.hasPosition) {
			_loc2_ = mEffectView.positionX;
			_loc3_ = mEffectView.positionY;
			_loc5_ = mLerpTargetActor.positionX + mLerpTargetPositionVector.x - _loc2_;
			_loc7_ = mLerpTargetActor.positionY + mLerpTargetPositionVector.y - _loc3_;
			_loc6_ = mLerpTargetActor.positionZ + mLerpTargetPositionVector.z;
			_loc4_ = Math.sqrt(_loc5_ * _loc5_ + _loc7_ * _loc7_ + _loc6_ * _loc6_);
			if (_loc4_ != 0) {
				_loc5_ = _loc5_ / _loc4_ * mLerpTempSpeed;
				_loc7_ = _loc7_ / _loc4_ * mLerpTempSpeed;
			}
			sNextPos.x = _loc2_ + _loc5_;
			sNextPos.y = _loc3_ + _loc7_;
			mEffectView.position = sNextPos;
			if (_loc4_ < 15) {
				mDBFacade.mTween.tweenMaxTo(mLerpTargetActor.actorView.body, 0.05, {
					"glowFilter": {
						"color": mLerpGlowColor,
						"alpha": 1,
						"blurX": 15,
						"blurY": 15,
						"remove": true,
						"ease": Sine.easeInOut
					}
				});
				destroy();
			}
		} else {
			destroy();
		}
	}

	override public function destroy() {
		if (mEventComponent != null) {
			mEventComponent.removeListener("enterFrame");
			mEventComponent.destroy();
			mEventComponent = null;
		}
		super.destroy();
	}
}
