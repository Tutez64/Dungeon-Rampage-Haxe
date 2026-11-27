package generatedCode;

import networkCode.DcNetworkPacket;

class HeroPreloadLook {
	public var heroType:UInt = 0;

	public var skinType:UInt = 0;

	public var weapons:Vector<WeaponDetails>;

	public var consumableTypes:Vector<UInt>;

	public var petTypes:Vector<UInt>;

	public function new() {}

	public static function readFromPacket(packet:DcNetworkPacket):HeroPreloadLook {
		var work = new HeroPreloadLook();
		work.heroType = packet.readUnsignedInt();
		work.skinType = packet.readUnsignedInt();
		work.weapons = (function(param1:DcNetworkPacket):Vector<WeaponDetails> {
			var _loc3_ = (0 : UInt);
			var _loc5_:WeaponDetails = null;
			var _loc4_ = new Vector<WeaponDetails>();
			var _loc2_ = (3 : UInt);
			_loc3_ = (0 : UInt);
			while (_loc3_ < _loc2_) {
				_loc5_ = WeaponDetails.readFromPacket(param1);
				_loc4_.push(_loc5_);
				_loc3_++;
			}
			return _loc4_;
		})(packet);
		work.consumableTypes = (function(param1:DcNetworkPacket):Vector<UInt> {
			var _loc3_ = (0 : UInt);
			var _loc5_ = (0 : UInt);
			var _loc4_ = new Vector<UInt>();
			var _loc2_ = (2 : UInt);
			_loc3_ = (0 : UInt);
			while (_loc3_ < _loc2_) {
				_loc5_ = param1.readUnsignedInt();
				_loc4_.push(_loc5_);
				_loc3_++;
			}
			return _loc4_;
		})(packet);
		work.petTypes = (function(param1:DcNetworkPacket):Vector<UInt> {
			var _loc5_ = (0 : UInt);
			var _loc3_ = new Vector<UInt>();
			var _loc2_ = param1.readUnsignedShort();
			var _loc4_ = _loc2_ + param1.position;
			while (param1.position < _loc4_) {
				_loc5_ = param1.readUnsignedInt();
				_loc3_.push(_loc5_);
			}
			return _loc3_;
		})(packet);
		return work;
	}

	public function writeToPacket(outpacket:DcNetworkPacket) {
		var weapons_count:UInt;
		var weapons_loop:UInt;
		var consumableTypes_count:UInt;
		var consumableTypes_loop:UInt;
		var petTypesfunc:ASFunction;
		outpacket.writeUnsignedInt(heroType);
		outpacket.writeUnsignedInt(skinType);
		weapons_count = (3 : UInt);
		weapons_loop = (0 : UInt);
		while (weapons_loop < weapons_count) {
			weapons[(weapons_loop : Int)].writeToPacket(outpacket);
			weapons_loop = weapons_loop + 1;
		}
		consumableTypes_count = (2 : UInt);
		consumableTypes_loop = (0 : UInt);
		while (consumableTypes_loop < consumableTypes_count) {
			outpacket.writeUnsignedInt(consumableTypes[(consumableTypes_loop : Int)]);
			consumableTypes_loop = consumableTypes_loop + 1;
		}
		petTypesfunc = function() {
			var _loc1_ = (0 : UInt);
			var _loc3_ = (petTypes.length : UInt);
			var _loc2_ = outpacket;
			outpacket = new DcNetworkPacket();
			_loc1_ = (0 : UInt);
			while (_loc1_ < _loc3_) {
				outpacket.writeUnsignedInt(petTypes[(_loc1_ : Int)]);
				_loc1_++;
			}
			_loc2_.writeShort((outpacket.length : Int));
			_loc2_.writeBytes(outpacket);
			outpacket = _loc2_;
		};
		petTypesfunc();
	}
}
