package box2D.common;

import haxe.Exception;

class B2Settings {
	public static var VERSION:String = "2.1alpha";

	public static var USHRT_MAX_cpp /*cpp macro conflict*/:Int = 65535;

	public static var b2_maxManifoldPoints:Int = 2;

	public static var b2_aabbExtension:Float = 0.1;

	public static var b2_aabbMultiplier:Float = 2;

	public static var b2_polygonRadius:Float = 0.01;

	public static var b2_linearSlop:Float = 0.005;

	public static var b2_toiSlop:Float = 0.04;

	public static var b2_maxTOIContactsPerIsland:Int = 32;

	public static var b2_maxTOIJointsPerIsland:Int = 32;

	public static var b2_velocityThreshold:Float = 1;

	public static var b2_maxLinearCorrection:Float = 0.2;

	public static var b2_maxTranslation:Float = 2;

	public static var b2_maxTranslationSquared:Float = 4;

	public static var b2_contactBaumgarte:Float = 0.2;

	public static var b2_timeToSleep:Float = 0.5;

	public static var b2_linearSleepTolerance:Float = 0.01;

	public static var b2_pi:Float = Math.PI;

	public static var b2_angularSlop:Float = 0.011111111111111112 * Math.PI;

	public static var b2_maxAngularCorrection:Float = 0.044444444444444446 * Math.PI;

	public static var b2_maxRotation:Float = 0.5 * Math.PI;

	public static var b2_maxRotationSquared:Float = 0.5 * Math.PI * (0.5 * Math.PI);

	public static var b2_angularSleepTolerance:Float = 0.011111111111111112 * Math.PI;

	public function new() {}

	public static function b2MixFriction(friction1:Float, friction2:Float):Float {
		return Math.sqrt(friction1 * friction2);
	}

	public static function b2MixRestitution(restitution1:Float, restitution2:Float):Float {
		if (restitution1 > restitution2) {
			return restitution1;
		}
		return restitution2;
	}

	public static function b2Assert(a:Bool) {
		if (!a) {
			throw Exception.thrown("Assertion Failed");
		}
	}

	public static function B2MixFriction(friction1:Float, friction2:Float):Float {
		return B2Settings.b2MixFriction(friction1, friction2);
	}

	public static function B2MixRestitution(restitution1:Float, restitution2:Float):Float {
		return B2Settings.b2MixRestitution(restitution1, restitution2);
	}

	public static function B2Assert(a:Bool) {
		B2Settings.b2Assert(a);
	}
}
