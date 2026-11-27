package starling.utils;

import flash.display.Stage3D;
import flash.events.Event;
import starling.core.Starling;
import starling.errors.AbstractClassError;
import starling.textures.Texture;
import flash.errors.ArgumentError;

class RenderUtil {
	public function new() {
		throw new AbstractClassError();
	}

	public static function clear(rgb:UInt = (0 : UInt), alpha:Float = 0, depth:Float = 1, stencil:UInt = (0 : UInt)) {
		Starling.context.clear(Color.getRed(rgb) / 255, Color.getGreen(rgb) / 255, Color.getBlue(rgb) / 255, alpha, depth, stencil);
	}

	public static function getTextureLookupFlags(format:String, mipMapping:Bool, repeat:Bool = false, smoothing:String = "bilinear"):String {
		var _loc5_:Array<ASAny> = ["2d", repeat ? "repeat" : "clamp"];
		if (format == "compressed") {
			_loc5_.push("dxt1");
		} else if (format == "compressedAlpha") {
			_loc5_.push("dxt5");
		}
		if (smoothing == "none") {
			ASCompat.ASArray.pushMultiple(_loc5_, "nearest", mipMapping ? "mipnearest" : "mipnone");
		} else if (smoothing == "bilinear") {
			ASCompat.ASArray.pushMultiple(_loc5_, "linear", mipMapping ? "mipnearest" : "mipnone");
		} else {
			ASCompat.ASArray.pushMultiple(_loc5_, "linear", mipMapping ? "miplinear" : "mipnone");
		}
		return "<" + _loc5_.join(",") + ">";
	}

	public static function getTextureVariantBits(texture:Texture):UInt {
		if (texture == null) {
			return (0 : UInt);
		}
		var _loc2_ = (0 : UInt);
		var _loc3_ = (0 : UInt);
		switch (texture.format) {
			case "compressedAlpha":
				_loc3_ = (3 : UInt);

			case "compressed":
				_loc3_ = (2 : UInt);

			default:
				_loc3_ = (1 : UInt);
		}
		_loc2_ = ((_loc2_ | _loc3_ : UInt) : UInt);
		if (!texture.premultipliedAlpha) {
			_loc2_ = ((_loc2_ | (4 : UInt) : UInt) : UInt);
		}
		return _loc2_;
	}

	public static function setSamplerStateAt(sampler:Int, mipMapping:Bool, smoothing:String = "bilinear", repeat:Bool = false) {
		var _loc5_:String = null;
		var _loc6_:String = null;
		var _loc7_ = repeat ? "repeat" : "clamp";
		if (smoothing == "none") {
			_loc5_ = "nearest";
			_loc6_ = mipMapping ? "mipnearest" : "mipnone";
		} else if (smoothing == "bilinear") {
			_loc5_ = "linear";
			_loc6_ = mipMapping ? "mipnearest" : "mipnone";
		} else {
			_loc5_ = "linear";
			_loc6_ = mipMapping ? "miplinear" : "mipnone";
		}
		Starling.context.setSamplerStateAt(sampler, _loc7_, _loc5_, _loc6_);
	}

	public static function createAGALTexOperation(resultReg:String, uvReg:String, sampler:Int, texture:Texture, convertToPmaIfRequired:Bool = true,
			tempReg:String = "ft0"):String {
		var _loc8_:String = null;
		var _loc10_:String;
		switch (_loc10_ = texture.format) {
			case "compressed":
				_loc8_ = "dxt1";

			case "compressedAlpha":
				_loc8_ = "dxt5";

			default:
				_loc8_ = "rgba";
		}
		var _loc9_ = convertToPmaIfRequired && !texture.premultipliedAlpha;
		var _loc7_ = _loc9_ && resultReg == "oc" ? tempReg : resultReg;
		var _loc11_ = "tex " + _loc7_ + ", " + uvReg + ", fs" + sampler + " <2d, " + _loc8_ + ">\n";
		if (_loc9_) {
			if (resultReg == "oc") {
				_loc11_ += "mul " + _loc7_ + ".xyz, " + _loc7_ + ".xyz, " + _loc7_ + ".www\n";
				_loc11_ = _loc11_ + ("mov " + resultReg + ", " + _loc7_);
			} else {
				_loc11_ += "mul " + resultReg + ".xyz, " + _loc7_ + ".xyz, " + _loc7_ + ".www\n";
			}
		}
		return _loc11_;
	}

	public static function requestContext3D(stage3D:Stage3D, renderMode:String, profile:ASAny) {
		var requestNextProfile:() -> Void = null;
		var onError:Event->Void = null;
		var onFinished:() -> Void = null;
		var executeFunc:ASFunction = null;
		var profiles:Array<ASAny> = null;
		var currentProfile:String;
		requestNextProfile = function() {
			currentProfile = profiles.shift();
			try {
				executeFunc(stage3D.requestContext3D, renderMode, currentProfile);
			} catch (error:Dynamic) {
				if (profiles.length == 0) {
					throw error;
				}
				ASCompat.setTimeout(requestNextProfile, 1);
			}
		};
		var onCreated = function(param1:Event) {
			var _loc2_ = stage3D.context3D;
			if (renderMode == "auto" && profiles.length != 0 && _loc2_.driverInfo.indexOf("Software") != -1) {
				onError(param1);
			} else {
				onFinished();
			}
		};
		onError = function(param1:Event) {
			if (profiles.length != 0) {
				param1.stopImmediatePropagation();
				ASCompat.setTimeout(requestNextProfile, 1);
			} else {
				onFinished();
			}
		};
		onFinished = function() {
			stage3D.removeEventListener("context3DCreate", onCreated);
			stage3D.removeEventListener("error", onError);
		};
		executeFunc = SystemUtil.isDesktop ? Execute.execute : SystemUtil.executeWhenApplicationIsActive;
		if (profile == "auto") {
			profiles = [
				"enhanced",
				"standardExtended",
				"standard",
				"standardConstrained",
				"baselineExtended",
				"baseline",
				"baselineConstrained"
			];
		} else if (Std.isOfType(profile, String)) {
			profiles = [ASCompat.asString(profile)];
		} else {
			if (!Std.isOfType(profile, Array)) {
				throw new ArgumentError("Profile must be of type \'String\' or \'Array\'");
			}
			profiles = ASCompat.dynamicAs(profile, Array);
		}
		stage3D.addEventListener("context3DCreate", onCreated, false, 100);
		stage3D.addEventListener("error", onError, false, 100);
		requestNextProfile();
	}
}
