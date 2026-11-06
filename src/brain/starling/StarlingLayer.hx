package brain.starling;

import flash.geom.Matrix;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.display.Sprite;
import starling.rendering.Painter;
import starling.utils.MeshSubset;

class StarlingLayer extends Sprite {
	public static var propsCulledLastFrame:Int = 0;

	public static var bakedMeshes:Int = 0;

	public static var bakedBatches:Int = 0;

	public static var bakeRebuilds:Int = 0;

	@:allow(brain.starling) static inline final BAKE_IMAGE_SHOWN = 1;

	@:allow(brain.starling) static inline final BAKE_VIEW_SHOWN = 2;

	@:allow(brain.starling) static inline final BAKE_SPRITE_CHANGED = 3;

	public static var bakeWhyImageShown:Int = 0;

	public static var bakeWhyViewShown:Int = 0;

	public static var bakeWhySpriteChange:Int = 0;

	public static var bakeWhyOrder:Int = 0;

	public static var bakeWhyRemove:Int = 0;

	public static var bakeWhyMerge:Int = 0;

	public static var bakeWhyAdd:Int = 0;

	public static var bakeWhyConsolidate:Int = 0;

	public static var bakeFull:Int = 0;

	public static var bakeRunsRebuilt:Int = 0;

	public static var bakeSlotWrites:Int = 0;

	static inline final CONSOLIDATE_FRAMES = 30;

	static final sViewMatrix:Matrix = new Matrix();

	static final sMeshMatrix:Matrix = new Matrix();

	static final sZeroMatrix:Matrix = new Matrix(0, 0, 0, 0, 0, 0);

	static final sImageSubset:MeshSubset = new MeshSubset();

	var sortEveryFrame:Bool = false;

	var ignoreDirtyFlag:Bool = true;

	var dirty:Bool = false;

	var sortFunction:ASFunction;

	var mSortIndex:Int = 0;

	var mScreenSpace:Bool = false;

	var mBakeStaticImages:Bool = false;

	var mBaked:Bool = false;

	var mFullBakeDue:Bool = false;

	var mOrderChanged:Bool = false;

	var mAnyViolated:Bool = false;

	var mNewStatics:Bool = false;

	var mQuietFrames:Int = 0;

	var mLayerBlend:String = "normal";

	final mRuns:Vector<StarlingBakedRun> = new Vector((0 : UInt));

	final mRunPool:Vector<StarlingBakedRun> = new Vector((0 : UInt));

	final mQueue:Vector<StarlingScenerySprite> = new Vector((0 : UInt));

	final mRanges:Vector<Int> = new Vector((0 : UInt));

	final mMaskCandidates:Vector<StarlingScenerySprite> = new Vector((0 : UInt));

	public function new(inSortIndex:Int, inName:String, inBlendMode:String, inSortEveryFrame:Bool = false, inCustomSortFunction:ASFunction = null,
			inScreenSpace:Bool = false) {
		super();
		mSortIndex = inSortIndex;
		mScreenSpace = inScreenSpace;
		blendMode = inBlendMode;
		if (inCustomSortFunction == null) {
			ignoreDirtyFlag = false;
			sortFunction = StarlingLayer.compareByY;
		} else {
			sortFunction = inCustomSortFunction;
		}
		sortEveryFrame = inSortEveryFrame;
		touchable = false;
		name = "StarlingLayer_" + inName;
	}

	public static function bakeStats():ASObject {
		return {
			"meshes": bakedMeshes,
			"batches": bakedBatches,
			"passes": bakeRebuilds,
			"full": bakeFull,
			"runsRebuilt": bakeRunsRebuilt,
			"slotWrites": bakeSlotWrites,
			"imageShown": bakeWhyImageShown,
			"viewShown": bakeWhyViewShown,
			"spriteChange": bakeWhySpriteChange,
			"order": bakeWhyOrder,
			"remove": bakeWhyRemove,
			"merge": bakeWhyMerge,
			"add": bakeWhyAdd,
			"consolidate": bakeWhyConsolidate
		};
	}

	public static function compareByY(a:DisplayObject, b:DisplayObject):Int {
		if (a.y < b.y) {
			return -1;
		}
		if (a.y > b.y) {
			return 1;
		}
		if (a.x > b.x) {
			return -1;
		}
		if (a.x < b.x) {
			return 1;
		}
		if (a.height > b.height) {
			return -1;
		}
		if (a.height < b.height) {
			return 1;
		}
		return 0;
	}

	@:isVar public var bakeStaticImages(get, set):Bool;

	public function get_bakeStaticImages():Bool {
		return mBakeStaticImages;
	}

	function set_bakeStaticImages(value:Bool):Bool {
		if (mBakeStaticImages == value) {
			return value;
		}
		mBakeStaticImages = value;
		if (!value) {
			unbake();
		}
		setRequiresRedraw();
		return value;
	}

	public function markDirty() {
		if (ignoreDirtyFlag) {
			dirty = true;
		}
	}

	public function clean() {
		unbake();
		removeChildren(0, numChildren - 1, true);
	}

	public function evaluateFrameLayerUpdate(inMatrix:Matrix) {
		if (!mScreenSpace) {
			transformationMatrix = inMatrix;
		}
		if (sortEveryFrame || dirty) {
			sortLayer(sortFunction);
			dirty = false;
		}
	}

	function cullScenerySprites() {
		var _loc13_ = 0;
		var _loc3_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc10_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc8_ = 0;
		var _loc16_:StarlingScenerySprite = null;
		var _loc1_ = false;
		var _loc6_ = numChildren;
		if (_loc6_ == 0) {
			return;
		}
		getTransformationMatrix(stage, sViewMatrix);
		sViewMatrix.invert();
		var _loc15_:Float = stage.stageWidth;
		var _loc7_:Float = stage.stageHeight;
		var _loc14_ = Math.POSITIVE_INFINITY;
		var _loc12_ = Math.POSITIVE_INFINITY;
		var _loc9_ = Math.NEGATIVE_INFINITY;
		var _loc4_ = Math.NEGATIVE_INFINITY;
		_loc13_ = 0;
		while (_loc13_ < 4) {
			_loc3_ = (_loc13_ & 1) != 0 ? _loc15_ : 0;
			_loc5_ = (_loc13_ & 2) != 0 ? _loc7_ : 0;
			_loc10_ = sViewMatrix.a * _loc3_ + sViewMatrix.c * _loc5_ + sViewMatrix.tx;
			_loc11_ = sViewMatrix.b * _loc3_ + sViewMatrix.d * _loc5_ + sViewMatrix.ty;
			if (_loc10_ < _loc14_) {
				_loc14_ = _loc10_;
			}
			if (_loc10_ > _loc9_) {
				_loc9_ = _loc10_;
			}
			if (_loc11_ < _loc12_) {
				_loc12_ = _loc11_;
			}
			if (_loc11_ > _loc4_) {
				_loc4_ = _loc11_;
			}
			_loc13_++;
		}
		var _loc2_ = 0;
		_loc8_ = 0;
		while (_loc8_ < _loc6_) {
			_loc16_ = ASCompat.reinterpretAs(getChildAt(_loc8_), StarlingScenerySprite);
			if (!(_loc16_ == null || _loc16_.isMember && !_loc16_.isLead)) {
				_loc1_ = !_loc16_.overlaps(_loc14_, _loc12_, _loc9_, _loc4_);
				_loc16_.setCulled(_loc1_);
				if (_loc1_) {
					_loc2_++;
				}
			}
			_loc8_++;
		}
		propsCulledLastFrame += _loc2_;
	}

	override public function render(painter:Painter) {
		if (bakeStaticImages || !mScreenSpace) {
			painter.excludeFromCache(this);
		}
		if (bakeStaticImages) {
			updateBake(painter);
		}
		if (!mScreenSpace && stage != null) {
			cullScenerySprites();
		}
		super.render(painter);
	}

	function updateBake(painter:Painter) {
		var _loc2_ = 0;
		var _loc4_:StarlingBakedRun = null;
		var _loc5_ = 0;
		var _loc3_:StarlingScenerySprite = null;
		recheckMaskCandidates();
		_loc2_ = 0;
		while (_loc2_ < mRuns.length) {
			_loc4_ = mRuns[_loc2_];
			_loc5_ = 0;
			while (_loc5_ < _loc4_.members.length) {
				_loc3_ = _loc4_.members[_loc5_];
				if (_loc3_.run == _loc4_) {
					if (_loc3_.bakeImage != _loc3_.slotImage || !_loc4_.batch.style.canBatchWith(_loc3_.slotImage.style)) {
						trackMaskCandidate(_loc3_);
						violate(_loc4_);
					}
				}
				_loc5_++;
			}
			_loc2_++;
		}
		if (mLayerBlend != painter.state.blendMode) {
			mFullBakeDue = true;
		}
		mLayerBlend = painter.state.blendMode;
		if (!mBaked || mFullBakeDue) {
			fullBake();
			return;
		}
		if (mQueue.length > 0) {
			applyQueue();
		}
		if (mOrderChanged || mAnyViolated) {
			checkOrder();
		}
		if (mAnyViolated) {
			rebuildViolated();
			mQuietFrames = 0;
		} else if (mNewStatics && ++mQuietFrames >= 30) {
			bakeWhyConsolidate = bakeWhyConsolidate + 1;
			fullBake();
		}
	}

	function trackMaskCandidate(sprite:StarlingScenerySprite) {
		if (sprite != null && sprite.hasMaskRole && mMaskCandidates.indexOf(sprite) < 0) {
			mMaskCandidates.push(sprite);
		}
	}

	function recheckMaskCandidates() {
		var _loc2_ = 0;
		var _loc1_:StarlingScenerySprite = null;
		_loc2_ = mMaskCandidates.length - 1;
		while (_loc2_ >= 0) {
			_loc1_ = mMaskCandidates[_loc2_];
			if (!(_loc1_.parent == this && _loc1_.hasMaskRole)) {
				mMaskCandidates.splice(_loc2_, (1 : UInt));
				if (_loc1_.parent == this) {
					_loc1_.maskRoleCleared();
				}
			}
			_loc2_--;
		}
	}

	function fullBake() {
		releaseRuns();
		clearQueue();
		mMaskCandidates.length = 0;
		bakeSpan(0, numChildren - 1);
		mBaked = true;
		mFullBakeDue = false;
		mOrderChanged = false;
		mAnyViolated = false;
		mNewStatics = false;
		mQuietFrames = 0;
		bakeFull = bakeFull + 1;
		bakeRebuilds = bakeRebuilds + 1;
	}

	function bakeSpan(first:Int, last:Int) {
		var _loc6_ = 0;
		var _loc5_:StarlingScenerySprite = null;
		var _loc3_:Image = null;
		var _loc4_:String = null;
		var _loc7_:StarlingBakedRun = null;
		_loc6_ = first;
		while (_loc6_ <= last) {
			_loc5_ = ASCompat.reinterpretAs(getChildAt(_loc6_), StarlingScenerySprite);
			_loc3_ = _loc5_ != null && !_loc5_.isMember ? _loc5_.bakeImage : null;
			if (_loc3_ == null) {
				trackMaskCandidate(_loc5_);
				_loc7_ = closeRun(_loc7_);
			} else {
				_loc4_ = _loc3_.blendMode != "auto" ? _loc3_.blendMode : (_loc5_.blendMode != "auto" ? _loc5_.blendMode : mLayerBlend);
				if (_loc7_ == null || _loc4_ != _loc7_.batch.blendMode || !_loc7_.batch.canAddMesh(_loc3_)) {
					_loc7_ = closeRun(_loc7_);
					if (!_loc5_.canLead) {
						_loc6_++;
						continue;
					}
					_loc7_ = openRun(_loc5_, _loc4_);
				}
				_loc5_.joinRun(_loc7_, _loc7_.members.length, _loc3_);
				_loc7_.members.push(_loc5_);
				writeSlot(_loc7_, _loc5_);
			}
			_loc6_++;
		}
		closeRun(_loc7_);
	}

	function openRun(lead:StarlingScenerySprite, blend:String):StarlingBakedRun {
		var _loc3_ = mRunPool.length > 0 ? mRunPool.pop() : new StarlingBakedRun();
		_loc3_.lead = lead;
		_loc3_.batch.blendMode = blend;
		_loc3_.leadInverse.copyFrom(lead.transformationMatrix);
		_loc3_.leadInverse.invert();
		mRuns.push(_loc3_);
		return _loc3_;
	}

	function closeRun(run:StarlingBakedRun):StarlingBakedRun {
		if (run == null) {
			return null;
		}
		if (run.members.length == 1) {
			releaseRun(run, mRuns.lastIndexOf(run));
		} else {
			bakedBatches = bakedBatches + 1;
			bakedMeshes += run.members.length;
		}
		return null;
	}

	function releaseRun(run:StarlingBakedRun, index:Int) {
		var _loc4_ = 0;
		var _loc3_:StarlingScenerySprite = null;
		_loc4_ = 0;
		while (_loc4_ < run.members.length) {
			_loc3_ = run.members[_loc4_];
			if (_loc3_.run == run) {
				_loc3_.leaveRun();
			}
			_loc4_++;
		}
		if (run.members.length > 1) {
			bakedBatches = bakedBatches - 1;
			bakedMeshes -= run.members.length;
		}
		run.clear();
		mRuns[index] = mRuns[mRuns.length - 1];
		mRuns.length--;
		mRunPool.push(run);
	}

	function releaseRuns() {
		var _loc1_ = 0;
		_loc1_ = mRuns.length - 1;
		while (_loc1_ >= 0) {
			releaseRun(mRuns[_loc1_], _loc1_);
			_loc1_--;
		}
	}

	function writeSlot(run:StarlingBakedRun, sprite:StarlingScenerySprite) {
		var _loc3_ = sprite.slotImage;
		var _loc5_ = sprite.slot * 4;
		var _loc7_ = sprite.slot * 6;
		var _loc4_ = sprite.bakeShown;
		if (_loc4_ != sprite.slotShown) {
			run.shownCount += _loc4_ ? 1 : -1;
			sprite.slotShown = _loc4_;
		}
		sImageSubset.setTo(0, _loc3_.numVertices, 0, _loc3_.numIndices);
		if (!_loc4_) {
			run.batch.addMeshAt(_loc3_, _loc7_, _loc5_, sZeroMatrix, 1, sImageSubset);
			return;
		}
		sMeshMatrix.copyFrom(_loc3_.transformationMatrix);
		sMeshMatrix.concat(sprite.transformationMatrix);
		sMeshMatrix.concat(run.leadInverse);
		var _loc6_ = sprite.alpha * _loc3_.alpha;
		run.batch.addMeshAt(_loc3_, _loc7_, _loc5_, sMeshMatrix, _loc6_, sImageSubset);
	}

	@:allow(brain.starling) function queueBake(sprite:StarlingScenerySprite, reason:Int) {
		if (!bakeStaticImages) {
			return;
		}
		if (!sprite.isMember) {
			if (sprite.bakeImage != null) {
				mNewStatics = true;
			}
			return;
		}
		if (reason == 1) {
			bakeWhyImageShown = bakeWhyImageShown + 1;
		} else if (reason == 2) {
			bakeWhyViewShown = bakeWhyViewShown + 1;
		} else {
			sprite.bakeShownOnly = false;
		}
		if (sprite.bakeQueued) {
			return;
		}
		sprite.bakeQueued = true;
		mQueue.push(sprite);
	}

	function applyQueue() {
		var _loc2_ = 0;
		var _loc1_:StarlingScenerySprite = null;
		var _loc3_:StarlingBakedRun = null;
		var _loc4_ = false;
		_loc2_ = 0;
		while (_loc2_ < mQueue.length) {
			_loc1_ = mQueue[_loc2_];
			_loc3_ = _loc1_.run;
			_loc4_ = _loc1_.bakeShownOnly;
			_loc1_.bakeQueued = false;
			_loc1_.bakeShownOnly = true;
			if (!(_loc3_ == null || _loc3_.violated || _loc1_.parent != this)) {
				if (_loc4_ && _loc1_.bakeImage == _loc1_.slotImage && (!_loc1_.isLead || _loc1_.canLead)) {
					writeSlot(_loc3_, _loc1_);
					bakeSlotWrites = bakeSlotWrites + 1;
				} else {
					bakeWhySpriteChange = bakeWhySpriteChange + 1;
					violate(_loc3_);
				}
			}
			_loc2_++;
		}
		mQueue.length = 0;
	}

	function clearQueue() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mQueue.length) {
			mQueue[_loc1_].bakeQueued = false;
			mQueue[_loc1_].bakeShownOnly = true;
			_loc1_++;
		}
		mQueue.length = 0;
	}

	function violate(run:StarlingBakedRun) {
		run.violated = true;
		mAnyViolated = true;
	}

	function checkOrder() {
		var _loc5_:StarlingBakedRun = null;
		var _loc1_ = 0;
		var _loc4_ = 0;
		var _loc3_:StarlingScenerySprite = null;
		var _loc6_ = mRuns.length;
		_loc1_ = 0;
		while (_loc1_ < _loc6_) {
			_loc5_ = mRuns[_loc1_];
			_loc5_.first = -1;
			_loc5_.last = -1;
			_loc5_.seen = 0;
			_loc1_++;
		}
		var _loc8_:StarlingBakedRun = null;
		var _loc7_:StarlingBakedRun = null;
		var _loc2_ = numChildren;
		_loc4_ = 0;
		while (_loc4_ < _loc2_) {
			_loc3_ = ASCompat.reinterpretAs(getChildAt(_loc4_), StarlingScenerySprite);
			_loc5_ = _loc3_ != null ? _loc3_.run : null;
			if (_loc5_ != null) {
				if (_loc5_.first < 0) {
					_loc5_.first = _loc4_;
				}
				_loc5_.last = _loc4_;
				if (_loc3_.slot != _loc5_.seen) {
					violateByOrder(_loc5_);
				}
				if (_loc7_ != null && _loc3_.slot == 0) {
					violateToMerge(_loc7_, _loc5_, _loc3_);
				}
				_loc5_.seen++;
				if (_loc8_ != null && _loc8_ != _loc5_) {
					violateByOrder(_loc8_);
				}
				_loc8_ = _loc5_.seen < _loc5_.members.length ? _loc5_ : null;
				_loc7_ = _loc8_ == null ? _loc5_ : null;
			} else {
				if (_loc8_ != null) {
					violateByOrder(_loc8_);
				}
				_loc7_ = null;
			}
			_loc4_++;
		}
		_loc1_ = 0;
		while (_loc1_ < _loc6_) {
			_loc5_ = mRuns[_loc1_];
			if (_loc5_.seen != _loc5_.members.length) {
				violateByOrder(_loc5_);
			}
			_loc1_++;
		}
		mOrderChanged = false;
	}

	function violateToMerge(before:StarlingBakedRun, after:StarlingBakedRun, afterLead:StarlingScenerySprite) {
		if (before == after || before.violated || after.violated) {
			return;
		}
		if (before.batch.blendMode != after.batch.blendMode || !before.batch.canAddMesh(afterLead.slotImage)) {
			return;
		}
		bakeWhyMerge = bakeWhyMerge + 1;
		violate(before);
		violate(after);
	}

	function violateByOrder(run:StarlingBakedRun) {
		if (run.violated) {
			return;
		}
		bakeWhyOrder = bakeWhyOrder + 1;
		violate(run);
	}

	function rebuildViolated() {
		var _loc2_ = 0;
		var _loc3_:StarlingBakedRun = null;
		var _loc5_ = 0;
		mRanges.length = 0;
		_loc2_ = mRuns.length - 1;
		while (_loc2_ >= 0) {
			_loc3_ = mRuns[_loc2_];
			if (_loc3_.violated) {
				if (_loc3_.first >= 0) {
					addRange(_loc3_.first, _loc3_.last);
				}
				releaseRun(_loc3_, _loc2_);
				bakeRunsRebuilt = bakeRunsRebuilt + 1;
			}
			_loc2_--;
		}
		var _loc1_ = -1;
		var _loc4_ = -1;
		_loc5_ = 0;
		while (_loc5_ < mRanges.length) {
			if (_loc1_ < 0 || mRanges[_loc5_] > _loc4_ + 1) {
				if (_loc4_ >= 0) {
					bakeSpan(_loc1_, _loc4_);
				}
				_loc1_ = mRanges[_loc5_];
				_loc4_ = mRanges[_loc5_ + 1];
			} else if (mRanges[_loc5_ + 1] > _loc4_) {
				_loc4_ = mRanges[_loc5_ + 1];
			}
			_loc5_ += 2;
		}
		if (_loc4_ >= 0) {
			bakeSpan(_loc1_, _loc4_);
		}
		mAnyViolated = false;
		bakeRebuilds = bakeRebuilds + 1;
	}

	function addRange(first:Int, last:Int) {
		var _loc3_ = mRanges.length;
		mRanges.length = _loc3_ + 2;
		while (_loc3_ > 0 && mRanges[_loc3_ - 2] > first) {
			mRanges[_loc3_] = mRanges[_loc3_ - 2];
			mRanges[_loc3_ + 1] = mRanges[_loc3_ - 1];
			_loc3_ -= 2;
		}
		mRanges[_loc3_] = first;
		mRanges[_loc3_ + 1] = last;
	}

	function unbake() {
		var _loc1_ = 0;
		recheckMaskCandidates();
		releaseRuns();
		clearQueue();
		_loc1_ = 0;
		while (_loc1_ < mRunPool.length) {
			mRunPool[_loc1_].dispose();
			_loc1_++;
		}
		mRunPool.length = 0;
		mMaskCandidates.length = 0;
		mBaked = false;
	}

	override public function dispose() {
		unbake();
		super.dispose();
	}

	function sortLayer(compare:ASFunction) {
		var _loc6_:DisplayObject = null;
		var _loc4_ = 0;
		var _loc2_ = numChildren;
		var _loc3_ = 1;
		while (_loc3_ < _loc2_ && ASCompat.toNumber(compare(getChildAt(_loc3_ - 1), getChildAt(_loc3_))) <= 0) {
			_loc3_++;
		}
		if (_loc3_ >= _loc2_) {
			return;
		}
		var _loc5_ = _loc2_ * 2;
		while (_loc3_ < _loc2_) {
			_loc6_ = getChildAt(_loc3_);
			_loc4_ = _loc3_;
			while (_loc4_ > 0 && ASCompat.toNumber(compare(getChildAt(_loc4_ - 1), _loc6_)) > 0) {
				if (--_loc5_ < 0) {
					sortChildren(compare);
					return;
				}
				_loc4_--;
			}
			if (_loc4_ != _loc3_) {
				_loc5_ -= _loc2_;
				if (_loc5_ < 0) {
					sortChildren(compare);
					return;
				}
				setChildIndex(_loc6_, _loc4_);
			}
			_loc3_++;
		}
	}

	@:isVar public var sortIndex(get, never):Int;

	public function get_sortIndex():Int {
		return mSortIndex;
	}

	@:isVar public var screenSpace(get, never):Bool;

	public function get_screenSpace():Bool {
		return mScreenSpace;
	}

	override public function addChild(child:DisplayObject):DisplayObject {
		if (sortEveryFrame || ignoreDirtyFlag) {
			dirty = true;
		}
		return super.addChild(child);
	}

	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject {
		var _loc4_:StarlingScenerySprite = null;
		if (sortEveryFrame || ignoreDirtyFlag) {
			dirty = true;
		}
		if (bakeStaticImages && child.parent != this) {
			bakeWhyAdd = bakeWhyAdd + 1;
			_loc4_ = ASCompat.reinterpretAs(child, StarlingScenerySprite);
			if (_loc4_ != null && _loc4_.bakeImage != null) {
				mNewStatics = true;
			}
			mQuietFrames = 0;
		}
		mOrderChanged = true;
		var _loc3_ = super.addChildAt(child, index);
		if (bakeStaticImages) {
			trackMaskCandidate(ASCompat.reinterpretAs(_loc3_, StarlingScenerySprite));
		}
		return _loc3_;
	}

	override public function removeChildAt(index:Int, dispose:Bool = false):DisplayObject {
		var _loc3_ = 0;
		var _loc5_ = index >= 0 && index < numChildren ? ASCompat.reinterpretAs(getChildAt(index), StarlingScenerySprite) : null;
		var _loc4_ = _loc5_ != null ? mMaskCandidates.indexOf(_loc5_) : -1;
		if (_loc4_ >= 0) {
			if (!_loc5_.hasMaskRole) {
				_loc5_.maskRoleCleared();
			}
			mMaskCandidates.splice(_loc4_, (1 : UInt));
		}
		if (_loc5_ != null && _loc5_.bakeQueued) {
			_loc3_ = mQueue.indexOf(_loc5_);
			if (_loc3_ >= 0) {
				mQueue.splice(_loc3_, (1 : UInt));
			}
			_loc5_.bakeQueued = false;
			_loc5_.bakeShownOnly = true;
		}
		if (_loc5_ != null && _loc5_.run != null) {
			if (!_loc5_.run.violated) {
				bakeWhyRemove = bakeWhyRemove + 1;
			}
			violate(_loc5_.run);
			_loc5_.leaveRun();
		}
		if (_loc5_ != null) {
			_loc5_.setCulled(false);
		}
		mQuietFrames = 0;
		mOrderChanged = true;
		return super.removeChildAt(index, dispose);
	}

	override public function setChildIndex(child:DisplayObject, index:Int) {
		mOrderChanged = true;
		super.setChildIndex(child, index);
	}

	override public function swapChildrenAt(index1:Int, index2:Int) {
		mOrderChanged = true;
		super.swapChildrenAt(index1, index2);
	}

	override public function sortChildren(compareFunction:ASFunction) {
		mOrderChanged = true;
		super.sortChildren(compareFunction);
	}

	public function destroy() {
		clean();
		parent.removeChild(this);
	}
}
