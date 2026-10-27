package uI;

import facade.DBFacade;
import com.greensock.TimelineMax;
import com.greensock.TweenMax;
import flash.display.MovieClip;

class UITownTweens {
	public static inline final HEADER_TWEEN_START_DELAY:Float = 0.20833333333333334;

	public static inline final RIGHT_PANEL_TWEEN_START_DELAY:Float = 0.16666666666666666;

	public static inline final FOOTER_TWEEN_START_DELAY:Float = 0.5;

	public function new() {}

	public static function avatarFadeInTweenSequence(clip:MovieClip) {
		clip.alpha = 0;
		TweenMax.to(clip, 0.2916666666666667, {"alpha": 1});
	}

	public static function headerTweenSequence(clip:MovieClip, dbFacade:DBFacade) {
		var _loc4_ = clip.y;
		clip.y = 0 - clip.height;
		clip.visible = true;
		var _loc3_ = new TimelineMax({
			"tweens": [
				TweenMax.to(clip, 0.08333333333333333, {"y": _loc4_}),
				TweenMax.to(clip, 0.08333333333333333, {"scaleY": 1.25}),
				TweenMax.to(clip, 0.08333333333333333, {
					"scaleY": 0.85,
					"y": _loc4_ * 0.85
				}),
				TweenMax.to(clip, 0.041666666666666664, {
					"scaleY": 1,
					"y": _loc4_
				})
			],
			"align": "sequence"
		});
	}

	public static function footerTweenSequence(clip:MovieClip, dbFacade:DBFacade) {
		var _loc5_ = clip.y;
		var _loc3_ = clip.height;
		clip.y = dbFacade.viewHeight + clip.height;
		clip.visible = true;
		var _loc4_ = new TimelineMax({
			"tweens": [
				TweenMax.to(clip, 0.125, {"y": _loc5_}),
				TweenMax.to(clip, 0.08333333333333333, {"scaleY": 1.25}),
				TweenMax.to(clip, 0.041666666666666664, {
					"scaleY": 0.85,
					"y": _loc5_ + _loc3_ * 0.15
				}),
				TweenMax.to(clip, 0.041666666666666664, {
					"scaleY": 1,
					"y": _loc5_
				})
			],
			"align": "sequence"
		});
	}

	public static function rightPanelTweenSequence(clip:MovieClip, dbFacade:DBFacade) {
		var _loc4_ = clip.x;
		clip.x = dbFacade.viewWidth + clip.width;
		clip.scaleX = 1.25;
		clip.visible = true;
		var _loc3_ = new TimelineMax({
			"tweens": [
				TweenMax.to(clip, 0.2916666666666667, {
					"scaleX": 1,
					"x": _loc4_ - 10
				}),
				TweenMax.to(clip, 0.041666666666666664, {"x": _loc4_ + 10}),
				TweenMax.to(clip, 0.041666666666666664, {"x": _loc4_})
			],
			"align": "sequence"
		});
	}
}
