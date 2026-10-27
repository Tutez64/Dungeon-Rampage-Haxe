package uI.modifiers;

import brain.assetRepository.SwfAsset;
import brain.sceneGraph.SceneGraphComponent;
import facade.DBFacade;
import flash.display.MovieClip;
import flash.geom.Point;

class UIModifierTooltip extends MovieClip {
	public var mRoot:MovieClip;

	var mSceneGraphComponent:SceneGraphComponent;

	public function new(facade:DBFacade, parentMC:MovieClip, swfAsset:SwfAsset, title:String, desc:String) {
		super();
		var _loc6_ = swfAsset.getClass("modifier_tooltip");
		mRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc6_, []), MovieClip);
		ASCompat.setProperty((mRoot : ASAny).title_label, "text", title.toUpperCase());
		ASCompat.setProperty((mRoot : ASAny).title_description, "text", desc);
		mRoot.mouseChildren = false;
		mRoot.mouseEnabled = false;
		parentMC.addChild(mRoot);
		var _loc7_ = parentMC.localToGlobal(new Point());
		mRoot.x = _loc7_.x;
		mRoot.y = _loc7_.y + 20;
		mSceneGraphComponent = new SceneGraphComponent(facade, "UIModifierTooltip");
		mSceneGraphComponent.addChild(mRoot, (107 : UInt));
	}

	public function show() {
		mRoot.visible = true;
	}

	public function hide() {
		mRoot.visible = false;
	}

	public function destroy() {
		mSceneGraphComponent.destroy();
		mSceneGraphComponent = null;
		mRoot = null;
	}
}
