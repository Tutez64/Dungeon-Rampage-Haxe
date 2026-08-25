package uI.inventory.chests;

import account.KeyInfo;
import brain.assetRepository.AssetLoadingComponent;
import brain.render.MovieClipRenderer;
import facade.DBFacade;
import flash.display.MovieClip;
import flash.text.TextField;

class ChestKeySlot {
	var mSlotMC:MovieClip;

	var mIconMC:MovieClip;

	var mUnequippableMC:MovieClip;

	var mUnusableMC:MovieClip;

	var mIconExistsMC:MovieClip;

	var mNumberLabel:TextField;

	var mKeyInfo:KeyInfo;

	var mKeyMC:MovieClip;

	var mRenderer:MovieClipRenderer;

	var mDBFacade:DBFacade;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mFromHeader:Bool = false;

	public function new(dbFacade:DBFacade, slotMC:MovieClip, keyInfo:KeyInfo, assetLoadingComponent:AssetLoadingComponent, fromHeader:Bool = false) {
		mDBFacade = dbFacade;
		mSlotMC = slotMC;
		mKeyInfo = keyInfo;
		mAssetLoadingComponent = assetLoadingComponent;
		mFromHeader = fromHeader;
		setupUI();
	}

	@:isVar public var keyInfo(get, never):KeyInfo;

	public function get_keyInfo():KeyInfo {
		return mKeyInfo;
	}

	public function setupUI() {
		setSelected(false);
		mIconMC = ASCompat.dynamicAs((mSlotMC : ASAny).icon, flash.display.MovieClip);
		mUnequippableMC = ASCompat.dynamicAs((mSlotMC : ASAny).unequippable, flash.display.MovieClip);
		mUnusableMC = ASCompat.dynamicAs((mSlotMC : ASAny).unusable, flash.display.MovieClip);
		mIconExistsMC = ASCompat.dynamicAs((mSlotMC : ASAny).icon_exists, flash.display.MovieClip);
		mNumberLabel = ASCompat.dynamicAs((mSlotMC : ASAny).number_label, flash.text.TextField);
		mNumberLabel.text = Std.string(mKeyInfo.count);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mKeyInfo.gmKeyOffer.BundleSwfFilepath),
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc2_ = param1.getClass(mKeyInfo.gmKeyOffer.BundleIcon);
				mKeyMC = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
				mKeyMC.scaleX = mKeyMC.scaleY = 1;
				if (mFromHeader) {
					if (mKeyInfo.count == 0) {
						mUnusableMC.addChild(mKeyMC);
					} else {
						mIconExistsMC.addChild(mKeyMC);
					}
				} else {
					mIconMC.addChild(mKeyMC);
				}
				mRenderer = new MovieClipRenderer(mDBFacade, mKeyMC);
			});
	}

	public function refresh(newKeyInfo:KeyInfo) {
		mKeyInfo = newKeyInfo;
		mNumberLabel.text = Std.string(newKeyInfo.count);
	}

	public function setSelected(value:Bool) {
		if (mIconMC != null) {
			if (mIconMC.numChildren > 1) {
				mIconMC.removeChildAt(1);
			}
			if (mUnusableMC.numChildren > 1) {
				mUnusableMC.removeChildAt(1);
			}
			if (mUnequippableMC.numChildren > 1) {
				mUnequippableMC.removeChildAt(1);
			}
			if (value) {
				mIconMC.addChild(mKeyMC);
			} else if (mKeyInfo.count == 0) {
				mUnusableMC.addChild(mKeyMC);
			} else {
				mUnequippableMC.addChild(mKeyMC);
			}
		}
	}

	public function destroy() {
		mRenderer.destroy();
		mRenderer = null;
		mKeyInfo = null;
	}
}
