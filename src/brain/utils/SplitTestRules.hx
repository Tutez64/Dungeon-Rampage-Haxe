package brain.utils
;
   import flash.utils.ByteArray;
   
    class SplitTestRules
   {
      
      static final k:Array<ASAny> = [1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298];
      
      static final h:Array<ASAny> = [1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225];
      
      public function new()
      {
         
      }
      
      public static function testSha256() 
      {
         var _loc4_= 0;
         var _loc1_:ByteArray = null;
         var _loc3_:ByteArray = null;
         var _loc5_:Array<ASAny> = [fromString(""),fromString("a"),fromString("abc"),fromString("message digest"),fromString("abcdefghijklmnopqrstuvwxyz"),fromString("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),fromString("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"),fromString("12345678901234567890123456789012345678901234567890123456789012345678901234567890"),fromString("The quick brown fox jumps over the lazy dog")];
         var _loc2_:Array<ASAny> = ["E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855","CA978112CA1BBDCAFAC231B39A23DC4DA786EFF8147C4E72B9807785AFEE48BB","BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD","F7846F55CF23E14EEBEAB5B4E1550CAD5B509E3348FBC4EFA3A1413D393CB650","71C480DF93D6AE2F1EFAD1447C66C9525E316218CF51FC8D9ED832F2DAF18B73","248D6A61D20638B8E5C026930C3E6039A33CE45964FF2167F6ECEDD419DB06C1","DB4BFCBD4DA0CD85A60C3C37D3FBD8805C77F15FC6B1FDFE614EE0A7C8FDB4C0","F371BC4A311F2B009EEF952DD83CA80E2B60026C8E935592D0F9C308453C813E","d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"];
         _loc4_ = 0;
         while(_loc4_ < _loc5_.length)
         {
            _loc1_ = toArray(_loc5_[_loc4_]);
            _loc3_ = hash(_loc1_);
            trace("SHA256 Test " + _loc4_,fromArray(_loc3_) == Std.string(_loc2_[_loc4_]).toLowerCase());
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      public static function getStringHash(param1:String) : String
      {
         return fromArray(hash(toArray(fromString(param1))));
      }
      
      public static function Random(param1:String, param2:UInt) : UInt
      {
         var _loc3_= fromArray(hash(toArray(fromString(param1))));
         _loc3_ = _loc3_.substr(0,7);
         var _loc4_= (ASCompat.toInt("0x" + _loc3_.toUpperCase()) : UInt);
         return (_loc4_ % param2 : UInt);
      }
      
      static function getHashSize() : UInt
      {
         return (32 : UInt);
      }
      
      static function hash(param1:ByteArray) : ByteArray
      {
         var _loc7_= 0;
         var _loc6_= param1.length;
         var _loc8_= param1.endian;
         param1.endian = "bigEndian";
         var _loc3_= _loc6_ * 8;
         while(param1.length % 4 != 0)
         {
            param1[param1.length] = 0;
         }
         param1.position = (0 : UInt);
         var _loc2_:Array<ASAny> = [];
         _loc7_ = 0;
         while((_loc7_ : UInt) < param1.length)
         {
            _loc2_.push(param1.readUnsignedInt());
            _loc7_ += 4;
         }
         var _loc4_= SHA256(_loc2_,_loc3_);
         var _loc9_= new ByteArray();
         var _loc5_= (Std.int(getHashSize() / 4) : UInt);
         _loc7_ = 0;
         while((_loc7_ : UInt) < _loc5_)
         {
            _loc9_.writeUnsignedInt((ASCompat.toInt(_loc4_[_loc7_]) : UInt));
            _loc7_ = ASCompat.toInt(_loc7_) + 1;
         }
         param1.length = _loc6_;
         param1.endian = _loc8_;
         return _loc9_;
      }
      
      static function SHA256(param1:Array<ASAny>, param2:UInt) : Array<ASAny>
      {
         var _loc14_= 0;
         var _loc16_= 0;
         var _loc21_= 0;
         var _loc22_= 0;
         var _loc15_= 0;
         var _loc17_= 0;
         var _loc18_= 0;
         var _loc20_= 0;
         var _loc3_= 0;
         var _loc4_= 0;
         var _loc19_= 0;
         var _loc5_= 0;
         var _loc6_= 0;
         var _loc25_= 0;
         var _loc24_= 0;
         var __tmpAssignObj1 = param1;
         var __tmpAssignIdx2 = (param2 : Int) >> 5;
__tmpAssignObj1[__tmpAssignIdx2] = ASCompat.toInt(__tmpAssignObj1[__tmpAssignIdx2]) | 128 << (24 - param2 % 32 : Int);
         param1[((param2 + 64 : Int) >> 9 << 4) + 15] = param2;
         var _loc23_:Array<ASAny> = [];
         var _loc7_= (ASCompat.toInt((_loc14_ : ASAny)[0]) : UInt);
         var _loc8_= ASCompat.toInt((_loc14_ : ASAny)[1]);
         var _loc9_= ASCompat.toInt((_loc14_ : ASAny)[2]);
         var _loc10_= ASCompat.toInt((_loc14_ : ASAny)[3]);
         var _loc11_= (ASCompat.toInt((_loc14_ : ASAny)[4]) : UInt);
         var _loc12_= ASCompat.toInt((_loc14_ : ASAny)[5]);
         var _loc13_= ASCompat.toInt((_loc14_ : ASAny)[6]);
         _loc14_ = ASCompat.toInt((_loc14_ : ASAny)[7]);
         _loc16_ = 0;
         while(_loc16_ < param1.length)
         {
            _loc21_ = (_loc7_ : Int);
            _loc22_ = _loc8_;
            _loc15_ = _loc9_;
            _loc17_ = _loc10_;
            _loc18_ = (_loc11_ : Int);
            _loc20_ = _loc12_;
            _loc3_ = _loc13_;
            _loc4_ = _loc14_;
            _loc19_ = 0;
            while(_loc19_ < 64)
            {
               if(_loc19_ < 16)
               {
                  _loc23_[_loc19_] = ASCompat.thisOrDefault(param1[ASCompat.toInt(_loc16_ + _loc19_)] , 0);
               }
               else
               {
                  _loc5_ = (rrol((ASCompat.toInt(_loc23_[ASCompat.toInt(_loc19_ - 15)]) : UInt),(7 : UInt)) : Int) ^ (rrol((ASCompat.toInt(_loc23_[ASCompat.toInt(_loc19_ - 15)]) : UInt),(18 : UInt)) : Int) ^ ASCompat.toInt(_loc23_[ASCompat.toInt(_loc19_ - 15)]) >>> 3;
                  _loc6_ = (rrol((ASCompat.toInt(_loc23_[ASCompat.toInt(_loc19_ - 2)]) : UInt),(17 : UInt)) : Int) ^ (rrol((ASCompat.toInt(_loc23_[ASCompat.toInt(_loc19_ - 2)]) : UInt),(19 : UInt)) : Int) ^ ASCompat.toInt(_loc23_[ASCompat.toInt(_loc19_ - 2)]) >>> 10;
                  _loc23_[_loc19_] = _loc23_[ASCompat.toInt(_loc19_ - 16)] + _loc5_ + _loc23_[ASCompat.toInt(_loc19_ - 7)] + _loc6_;
               }
               _loc25_ = ((rrol(_loc7_,(2 : UInt)) : Int) ^ (rrol(_loc7_,(13 : UInt)) : Int) ^ (rrol(_loc7_,(22 : UInt)) : Int)) + ((_loc7_ : Int) & _loc8_ ^ (_loc7_ : Int) & _loc9_ ^ _loc8_ & _loc9_);
               _loc24_ = ASCompat.toInt(_loc14_ + ((rrol(_loc11_,(6 : UInt)) : Int) ^ (rrol(_loc11_,(11 : UInt)) : Int) ^ (rrol(_loc11_,(25 : UInt)) : Int)) + ((_loc11_ : Int) & _loc12_ ^ _loc13_ & ~(_loc11_ : Int)) + k[_loc19_] + _loc23_[_loc19_]);
               _loc14_ = _loc13_;
               _loc13_ = _loc12_;
               _loc12_ = (_loc11_ : Int);
               _loc11_ = (ASCompat.toInt(_loc10_ + _loc24_) : UInt);
               _loc10_ = _loc9_;
               _loc9_ = _loc8_;
               _loc8_ = (_loc7_ : Int);
               _loc7_ = (ASCompat.toInt(_loc24_ + _loc25_) : UInt);
               _loc19_ = ASCompat.toInt(_loc19_) + 1;
            }
            _loc7_ += (_loc21_ : UInt);
            _loc8_ += _loc22_;
            _loc9_ += _loc15_;
            _loc10_ += _loc17_;
            _loc11_ += (_loc18_ : UInt);
            _loc12_ += _loc20_;
            _loc13_ += _loc3_;
            _loc14_ += _loc4_;
            _loc16_ += 16;
         }
         return [_loc7_,_loc8_,_loc9_,_loc10_,_loc11_,_loc12_,_loc13_,_loc14_];
      }
      
      static function rrol(param1:UInt, param2:UInt) : UInt
      {
         return ((param1 : Int) << (32 - param2 : Int) | (param1 : Int) >>> (param2 : Int) : UInt);
      }
      
      static function toArray(param1:String) : ByteArray
      {
         var _loc3_= 0;
         param1 = new compat.RegExp("\\s|:", "gm").replace(param1,"");
         var _loc2_= new ByteArray();
         if(param1.length != 0)
         {
            param1 = "0" + param1;
         }
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_[Std.int(_loc3_ / 2)] = ASCompat.parseInt(param1.substr(_loc3_,2),16);
            _loc3_ += 2;
         }
         return _loc2_;
      }
      
      static function fromArray(param1:ByteArray, param2:Bool = false) : String
      {
         var _loc4_= 0;
         var _loc3_= "";
         _loc4_ = 0;
         while((_loc4_ : UInt) < param1.length)
         {
            _loc3_ += ("0" + ASCompat.toRadix(param1[_loc4_], (16 : UInt))).substr(-2,2);
            if(param2)
            {
               if((_loc4_ : UInt) < param1.length - 1)
               {
                  _loc3_ += ":";
               }
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         return _loc3_;
      }
      
      static function toString_static/*renamed*/(param1:String) : String
      {
         var _loc2_= toArray(param1);
         return _loc2_.readUTFBytes(_loc2_.length);
      }
      
      static function fromString(param1:String, param2:Bool = false) : String
      {
         var _loc3_= new ByteArray();
         _loc3_.writeUTFBytes(param1);
         return fromArray(_loc3_,param2);
      }
   }


