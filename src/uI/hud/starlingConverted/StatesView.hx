package uI.hud.starlingConverted;

class StatesView extends ArtDisplay {
	var mFrame:Int = -1;

	public function new(art:ArtNode) {
		super(art);
	}

	public function gotoAndStop(frame:ASObject) {
		var _loc2_ = Std.isOfType(frame, String) ? ASCompat.toInt(mArt.labels[ASCompat.toString(frame)]) : ASCompat.toInt(frame);
		showFrame(ASCompat.floatToInt(Math.max(0, Math.min(mArt.totalFrames - 1, _loc2_))));
	}

	function showFrame(index:Int) {
		var _loc2_ = 0;
		var _loc3_:ArtChildState = null;
		var _loc5_:ArtDisplay = null;
		if (index == mFrame || index < 0 || index >= mArt.frames.length) {
			return;
		}
		mFrame = index;
		var _loc4_ = mArt.frames[index];
		_loc2_ = 0;
		while (_loc2_ < mChildren.length) {
			mChildren[_loc2_].authoredVisibility(false);
			_loc2_++;
		}
		if (mImage != null) {
			showCells(ASCompat.coerce(_loc4_ != null ? _loc4_.cell : null, brain.starling.swfConverter.BakedCell));
		}
		if (_loc4_ == null) {
			return;
		}
		applyFilters(_loc4_.filterState);
		_loc2_ = 0;
		while (_loc2_ < _loc4_.children.length) {
			_loc3_ = _loc4_.children[_loc2_];
			if (!(_loc3_.child < 0 || _loc3_.child >= mChildren.length)) {
				_loc5_ = mChildren[_loc3_.child];
				setChildIndex(_loc5_, _loc2_);
				_loc5_.authoredMatrix(_loc3_.matrix);
				_loc5_.alpha = _loc3_.alpha;
				_loc5_.authoredVisibility(_loc3_.visible);
				_loc5_.blendMode = _loc3_.blendMode;
				_loc5_.setLocalColor(_loc3_.colorTransform);
				_loc5_.applyClip(_loc3_.parentClip);
				_loc5_.applyFilters(_loc3_.filterState);
				applyChildFrame(_loc5_, _loc3_.frame);
			}
			_loc2_++;
		}
	}

	function applyChildFrame(child:ArtDisplay, frame:Int) {
		if (Std.isOfType(child, StatesView)) {
			cast(child, StatesView).gotoAndStop(frame);
		}
	}

	@:isVar public var currentFrame(get, never):Int;

	public function get_currentFrame():Int {
		return mFrame;
	}
}
