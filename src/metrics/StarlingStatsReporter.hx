package metrics;

import brain.event.EventListeners;
import brain.logger.Logger;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.system.System;
import starling.core.Starling;
import starling.events.Event;

class StarlingStatsReporter {
	static inline final B_TO_MB:Float = 9.5367431640625e-7;

	static inline final FPS_WINDOW_MS = 1000;

	static inline final WRITE_INTERVAL_MS = 5000;

	var mStarling:Starling;

	var mRunning:Bool = false;

	var mStartDate:Date;

	var mStartTime:Float = Math.NaN;

	var mLastWriteTime:Float = Math.NaN;

	var mFrameCount:Int = 0;

	var mWindowFrames:Int = 0;

	var mWindowStartTime:Float = Math.NaN;

	var mPeakFps:Float = Math.NaN;

	var mDrawCallSum:Float = Math.NaN;

	var mPeakDrawCalls:Int = 0;

	var mMemorySum:Float = Math.NaN;

	var mPeakMemory:Float = Math.NaN;

	var mGpuMemorySum:Float = Math.NaN;

	var mPeakGpuMemory:Float = Math.NaN;

	var mSampleCount:Int = 0;

	public function new(starling:Starling) {
		mStarling = starling;
	}

	static function pad(value:String, width:Int = 15):String {
		var _loc3_ = value;
		while (_loc3_.length < width) {
			_loc3_ += " ";
		}
		return _loc3_;
	}

	@:isVar public var isRunning(get, never):Bool;

	public function get_isRunning():Bool {
		return mRunning;
	}

	public function toggle() {
		if (mRunning) {
			stop();
		} else {
			start();
		}
	}

	public function start() {
		if (mRunning) {
			return;
		}
		mRunning = true;
		mStartDate = Date.now();
		mStartTime = flash.Lib.getTimer();
		mWindowStartTime = mStartTime;
		mLastWriteTime = mStartTime;
		mFrameCount = 0;
		mWindowFrames = 0;
		mPeakFps = 1.7976931348623157e+308;
		mDrawCallSum = 0;
		mPeakDrawCalls = 0;
		mMemorySum = 0;
		mPeakMemory = 0;
		mGpuMemorySum = 0;
		mPeakGpuMemory = 0;
		mSampleCount = 0;
		mStarling.addEventListener("renderComplete", onRenderComplete);
		EventListeners.add(mStarling.nativeStage, "enterFrame", onNativeFrame);
		Logger.log("StarlingStatsReporter: watching Starling stats. Report: " + resolveReportFile().nativePath);
	}

	public function stop() {
		if (!mRunning) {
			return;
		}
		mRunning = false;
		mStarling.removeEventListener("renderComplete", onRenderComplete);
		EventListeners.remove(mStarling.nativeStage, "enterFrame", onNativeFrame);
		writeReport();
		Logger.log("StarlingStatsReporter: stopped. Report written to " + resolveReportFile().nativePath);
	}

	function onRenderComplete(event:Event) {
		var _loc4_ = mStarling.painter_instance.drawCount;
		mDrawCallSum += _loc4_;
		if (_loc4_ > mPeakDrawCalls) {
			mPeakDrawCalls = _loc4_;
		}
		var _loc3_ = System.totalMemory * 9.5367431640625e-7;
		mMemorySum += _loc3_;
		if (_loc3_ > mPeakMemory) {
			mPeakMemory = _loc3_;
		}
		var _loc2_ = supportsGpuMem ? ASCompat.toNumber((mStarling._context : ASAny)["totalGPUMemory"]) * 9.5367431640625e-7 : -1;
		if (_loc2_ >= 0) {
			mGpuMemorySum += _loc2_;
			if (_loc2_ > mPeakGpuMemory) {
				mPeakGpuMemory = _loc2_;
			}
		}
		mSampleCount = mSampleCount + 1;
	}

	function onNativeFrame(event:flash.events.Event) {
		countFrame();
	}

	function countFrame() {
		var _loc2_ = Math.NaN;
		mFrameCount = mFrameCount + 1;
		mWindowFrames = mWindowFrames + 1;
		var _loc1_:Float = flash.Lib.getTimer();
		var _loc3_ = _loc1_ - mWindowStartTime;
		if (_loc3_ >= 1000) {
			_loc2_ = mWindowFrames * 1000 / _loc3_;
			if (_loc2_ < mPeakFps && _loc2_ > 0) {
				mPeakFps = _loc2_;
			}
			mWindowFrames = 0;
			mWindowStartTime = _loc1_;
		}
		if (_loc1_ - mLastWriteTime >= 5000) {
			mLastWriteTime = _loc1_;
			writeReport();
		}
	}

	function writeReport() {
		var _loc6_ = (flash.Lib.getTimer() - mStartTime) / 1000;
		var _loc1_ = _loc6_ > 0 ? mFrameCount / _loc6_ : 0;
		var _loc4_ = mSampleCount > 0 ? mDrawCallSum / mSampleCount : 0;
		var _loc2_ = mSampleCount > 0 ? mMemorySum / mSampleCount : 0;
		var _loc7_ = mSampleCount > 0 ? mGpuMemorySum / mSampleCount : 0;
		var _loc5_:Array<ASAny> = ["Starling Performance Report",
			"Started:  " + mStartDate.toString(),
			"Duration: "
			+ ASCompat.toFixed(_loc6_, (1 : UInt))
			+ " s ("
			+ mFrameCount
			+ " frames, "
			+ mSampleCount
			+ " rendered)",
			"Status:   " + (mRunning ? "running (refreshed every 5 s)" : "stopped"),
			"",
			"                 average        peak",
			"frames/sec:      "
			+ pad(ASCompat.toFixed(_loc1_, (1 : UInt)))
			+ pad(mPeakFps == 1.7976931348623157e+308 ? "n/a" : ASCompat.toFixed(mPeakFps, (1 : UInt)))
			+ "(\"peak\" is lowest)",
			"std memory (MB): " + pad(ASCompat.toFixed(_loc2_, (1 : UInt))) + pad(ASCompat.toFixed(mPeakMemory, (1 : UInt))),
			"gpu memory (MB): " + (supportsGpuMem ? pad(ASCompat.toFixed(_loc7_, (1 : UInt)))
				+ pad(ASCompat.toFixed(mPeakGpuMemory, (1 : UInt))) : "n/a (runtime does not support totalGPUMemory)"),
			"draw calls:      " + pad(ASCompat.toFixed(_loc4_, (1 : UInt))) + pad(Std.string(mPeakDrawCalls))
		];
		var _loc3_ = new FileStream();
		{
			try {
				try {
					_loc3_.open(resolveReportFile(), flash.filesystem.FileMode.WRITE);
					_loc3_.writeUTFBytes(_loc5_.join("\n") + "\n");
				} catch (e:Dynamic) {
					Logger.error("StarlingStatsReporter: failed to write report: " + Std.string(e.message));
				};
			} catch (__finallyError0:Dynamic) {
				{
					_loc3_.close();
				};
				throw __finallyError0;
			};
			{
				_loc3_.close();
			};
		}
	}

	function resolveReportFile():File {
		return File.applicationStorageDirectory.resolvePath("StarlingReport.txt");
	}

	@:isVar var supportsGpuMem(get, never):Bool;

	function get_supportsGpuMem():Bool {
		return mStarling._context != null && (mStarling._context : ASAny).hasOwnProperty("totalGPUMemory");
	}
}
