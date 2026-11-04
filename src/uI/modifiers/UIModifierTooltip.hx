package uI.modifiers;

import brain.assetRepository.SwfAsset;
import brain.sceneGraph.SceneGraphComponent;
import brain.utils.TextUtil;
import facade.DBFacade;
import uI.inventory.UIWeaponTooltip;
import flash.display.MovieClip;
import flash.geom.Point;

class UIModifierTooltip extends MovieClip {
	public var mRoot:MovieClip;

	var mSceneGraphComponent:SceneGraphComponent;

	var mFacade:DBFacade;

	var mAnchor:MovieClip;

	public function new(facade:DBFacade, parentMC:MovieClip, swfAsset:SwfAsset, title:String, desc:String) {
		super();
		mFacade = facade;
		mAnchor = parentMC;
		var _loc6_ = swfAsset.getClass("modifier_tooltip");
		mRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc6_, []), MovieClip);
		mRoot.scaleX = mRoot.scaleY = UIWeaponTooltip.tooltipScale(ASCompat.coerce((mRoot : ASAny).title_description, flash.text.TextField), 1.55);
		TextUtil.setText(ASCompat.coerce((mRoot : ASAny).title_label, flash.text.TextField), title.toUpperCase());
		TextUtil.setText(ASCompat.coerce((mRoot : ASAny).title_description, flash.text.TextField), desc);
		mRoot.mouseChildren = false;
		mRoot.mouseEnabled = false;
		mSceneGraphComponent = new SceneGraphComponent(facade, "UIModifierTooltip");
		mSceneGraphComponent.addChild(mRoot, (107 : UInt));
	}

	public function show() {
		if (mRoot == null || mAnchor == null) {
			return;
		}
		var _loc1_ = mAnchor.getBounds(mAnchor).top;
		var _loc2_ = mFacade.designLocalToGlobal(mAnchor, new Point(0, _loc1_));
		mRoot.x = _loc2_.x;
		mRoot.y = _loc2_.y;
		mRoot.visible = true;
	}

	public function hide() {
		if (mRoot != null) {
			mRoot.visible = false;
		}
	}

	public function destroy() {
		mSceneGraphComponent.destroy();
		mSceneGraphComponent = null;
		mRoot = null;
		mAnchor = null;
		mFacade = null;
	}
}
