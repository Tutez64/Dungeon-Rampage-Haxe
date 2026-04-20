package account
;
   import actor.player.SkinInfo;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.jsonRPC.JSONRPCService;
   import events.BoostersParsedEvent;
   import facade.DBFacade;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMKey;
   import gameMasterDictionary.GMMapNode;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMOfferDetail;
   import gameMasterDictionary.GMSkin;
   import gameMasterDictionary.GMStackable;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class DBInventoryInfo
   {
      
      public static inline final II_FIRST_MAPNODE_ID= (50150 : UInt);
      
      var mDBFacade:DBFacade;
      
      var mAvatars:Map;
      
      var mItems:Map;
      
      var mChests:Vector<ChestInfo>;
      
      var mLastPendingChest:Int = 0;
      
      var mKeys:Vector<KeyInfo>;
      
      var mStackablesByDatabaseId:Map;
      
      var mStackablesByStackableId:Map;
      
      var mBoostersByDatabaseId:Map;
      
      var mBoostersByStackableId:Map;
      
      var mPets:Map;
      
      var mSkins:Map;
      
      var mResponseCallback:ASFunction;
      
      var mParseErrorCallback:ASFunction;
      
      var mEventComponent:EventComponent;
      
      var mStorageLimitWeapon:UInt = 0;
      
      var mStorageLimitOther:UInt = 0;
      
      var mFirstParse:Bool = false;
      
      var mTotalHeroesOwned:UInt = 0;
      
      public function new(param1:DBFacade, param2:ASFunction, param3:ASFunction)
      {
         
         mDBFacade = param1;
         mAvatars = new Map();
         mItems = new Map();
         mChests = new Vector<ChestInfo>();
         mLastPendingChest = -1;
         mKeys = new Vector<KeyInfo>();
         mStackablesByDatabaseId = new Map();
         mStackablesByStackableId = new Map();
         mBoostersByDatabaseId = new Map();
         mBoostersByStackableId = new Map();
         mPets = new Map();
         mSkins = new Map();
         mFirstParse = true;
         mTotalHeroesOwned = (0 : UInt);
         mResponseCallback = param2;
         mParseErrorCallback = param3;
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      public function listAllBoosters() : Array<ASAny>
      {
         return mBoostersByStackableId.keysToArray();
      }
      
      public function getStackableByStackId(param1:Int) : StackableInfo
      {
         return ASCompat.dynamicAs(mStackablesByStackableId.itemFor(param1), account.StackableInfo);
      }
      
      public function findHighestBoosterXP() : BoosterInfo
      {
         var _loc4_:ASAny = null;
         var _loc1_:BoosterInfo = null;
         var _loc5_= 0;
         var _loc6_= 0;
         var _loc2_= listAllBoosters();
         var _loc3_:Int;
         if (checkNullIteratee(_loc2_)) for(_tmp_ in 0..._loc2_.length)
         {
            _loc3_ = _tmp_;
            _loc5_ = ASCompat.toInt(_loc2_[_loc3_]);
            _loc1_ = ASCompat.dynamicAs(mBoostersByStackableId.itemFor(_loc5_), account.BoosterInfo);
            _loc6_ = timeTillBoosterExpire(_loc5_);
            if(_loc1_ != null && _loc1_.BuffInfo.Exp > 1 && _loc6_ > 0)
            {
               if(_loc4_ == null || _loc1_.BuffInfo.Exp > ASCompat.toNumberField(_loc4_.BuffInfo, "Exp"))
               {
                  _loc4_ = _loc1_;
               }
            }
         }
         return ASCompat.dynamicAs(_loc4_, account.BoosterInfo);
      }
      
      public function findHighestBoosterGold() : BoosterInfo
      {
         var _loc4_:ASAny = null;
         var _loc1_:BoosterInfo = null;
         var _loc5_= 0;
         var _loc6_= 0;
         var _loc2_= listAllBoosters();
         var _loc3_:Int;
         if (checkNullIteratee(_loc2_)) for(_tmp_ in 0..._loc2_.length)
         {
            _loc3_ = _tmp_;
            _loc5_ = ASCompat.toInt(_loc2_[_loc3_]);
            _loc1_ = ASCompat.dynamicAs(mBoostersByStackableId.itemFor(_loc5_), account.BoosterInfo);
            _loc6_ = timeTillBoosterExpire(_loc5_);
            if(_loc1_ != null && _loc1_.BuffInfo.Gold > 1 && _loc6_ > 0)
            {
               if(_loc4_ == null || _loc1_.BuffInfo.Gold > ASCompat.toNumberField(_loc4_.BuffInfo, "Gold"))
               {
                  _loc4_ = _loc1_;
               }
            }
         }
         return ASCompat.dynamicAs(_loc4_, account.BoosterInfo);
      }
      
      public function timestampBooster(param1:Int) : String
      {
         var _loc2_:BoosterInfo = null;
         if(mBoostersByStackableId.hasKey(param1))
         {
            _loc2_ = ASCompat.dynamicAs(mBoostersByStackableId.itemFor(param1), account.BoosterInfo);
            if(_loc2_ != null)
            {
               return _loc2_.timeStamp();
            }
         }
         return "";
      }
      
      public function timeTillBoosterExpire(param1:Int) : Int
      {
         var _loc3_= ASCompat.dynamicAs(mBoostersByStackableId.itemFor(param1), account.BoosterInfo);
         var _loc2_= dateBooster((_loc3_.gmId : Int));
         return Std.int(_loc2_.getTime()- GameClock.getWebServerTime());
      }
      
      public function timeTillNextBoosterExpire() : Int
      {
         var _loc2_:BoosterInfo = null;
         var _loc6_= 0;
         var _loc5_= 0;
         var _loc3_= listAllBoosters();
         var _loc1_= -1;
         var _loc4_:Int;
         if (checkNullIteratee(_loc3_)) for(_tmp_ in 0..._loc3_.length)
         {
            _loc4_ = _tmp_;
            _loc6_ = ASCompat.toInt(_loc3_[_loc4_]);
            _loc2_ = ASCompat.dynamicAs(mBoostersByStackableId.itemFor(_loc6_), account.BoosterInfo);
            _loc5_ = timeTillBoosterExpire((_loc2_.gmId : Int));
            if(_loc5_ > 0)
            {
               if(_loc1_ == -1 || _loc5_ < _loc1_)
               {
                  _loc1_ = _loc5_;
               }
            }
         }
         return _loc1_;
      }
      
      public function dateBooster(param1:Int) : Date
      {
         var _loc2_= GameClock.getWebServerDate();
         var _loc3_= timestampBooster(param1);
         if(_loc3_ != "")
         {
            return GameClock.parseW3CDTF(_loc3_,true);
         }
         return null;
      }
      
      @:isVar public var unequippedWeaponCount(get,never):UInt;
public function  get_unequippedWeaponCount() : UInt
      {
         var _loc2_:IMapIterator = null;
         var _loc3_:ItemInfo = null;
         var _loc1_= (0 : UInt);
         _loc2_ = ASCompat.reinterpretAs(mItems.iterator() , IMapIterator);
         while(_loc2_.hasNext())
         {
            _loc3_ = ASCompat.dynamicAs(_loc2_.next(), account.ItemInfo);
            if(!_loc3_.isEquipped)
            {
               _loc1_++;
            }
         }
         return _loc1_ + mChests.length;
      }
      
      @:isVar public var numStacks(get,never):UInt;
public function  get_numStacks() : UInt
      {
         return mStackablesByDatabaseId.size;
      }
      
      public function getStackCount(param1:UInt) : UInt
      {
         var _loc2_= ASCompat.dynamicAs(mStackablesByStackableId.itemFor(param1), account.StackableInfo);
         return (ASCompat.toInt(_loc2_ != null ? _loc2_.count : (0 : UInt)) : UInt);
      }
      
      public function getAvatarInfoForAvatarInstanceId(param1:UInt) : AvatarInfo
      {
         return ASCompat.dynamicAs(mAvatars.itemFor(param1), account.AvatarInfo);
      }
      
      public function getAvatarInfoForHeroType(param1:UInt) : AvatarInfo
      {
         var _loc3_:IMapIterator = null;
         var _loc2_:AvatarInfo = null;
         _loc3_ = ASCompat.reinterpretAs(mAvatars.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc3_.next(), account.AvatarInfo);
            if(param1 == _loc2_.avatarType)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      function modifiersMatch(param1:GMOfferDetail, param2:ItemInfo) : Bool
      {
         var _loc3_= (0 : UInt);
         if(ASCompat.stringAsBool(param1.Modifier1))
         {
            _loc3_++;
         }
         if(ASCompat.stringAsBool(param1.Modifier2))
         {
            _loc3_++;
         }
         if(ASCompat.stringAsBool(param1.Modifier3))
         {
            _loc3_++;
         }
         if(_loc3_ != (param2.modifiers.length : UInt))
         {
            return false;
         }
         if(ASCompat.stringAsBool(param1.Modifier1) && !param2.hasModifier(param1.Modifier1))
         {
            return false;
         }
         if(ASCompat.stringAsBool(param1.Modifier2) && !param2.hasModifier(param1.Modifier2))
         {
            return false;
         }
         if(ASCompat.stringAsBool(param1.Modifier3) && !param2.hasModifier(param1.Modifier3))
         {
            return false;
         }
         return true;
      }
      
      public function ownsExactWeapon(param1:GMOfferDetail) : Bool
      {
         var _loc2_:IMapIterator = null;
         var _loc3_:ItemInfo = null;
         _loc2_ = ASCompat.reinterpretAs(mItems.iterator() , IMapIterator);
         while(_loc2_.hasNext())
         {
            _loc3_ = ASCompat.dynamicAs(_loc2_.next(), account.ItemInfo);
            if(param1.WeaponId == _loc3_.gmId && param1.WeaponPower == _loc3_.power && this.modifiersMatch(param1,_loc3_))
            {
               return true;
            }
         }
         return false;
      }
      
      public function ownsItem(param1:UInt) : Bool
      {
         var _loc5_:IMapIterator = null;
         var _loc6_:ItemInfo = null;
         var _loc2_:AvatarInfo = null;
         var _loc4_:PetInfo = null;
         var _loc7_:StackableInfo = null;
         var _loc3_:SkinInfo = null;
         _loc5_ = ASCompat.reinterpretAs(mItems.iterator() , IMapIterator);
         while(_loc5_.hasNext())
         {
            _loc6_ = ASCompat.dynamicAs(_loc5_.next(), account.ItemInfo);
            if(param1 == _loc6_.gmId)
            {
               return true;
            }
         }
         _loc7_ = ASCompat.dynamicAs(mStackablesByStackableId.itemFor(param1), account.StackableInfo);
         if(_loc7_ != null && _loc7_.count > 0)
         {
            return true;
         }
         _loc5_ = ASCompat.reinterpretAs(mAvatars.iterator() , IMapIterator);
         while(_loc5_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc5_.next(), account.AvatarInfo);
            if(param1 == _loc2_.avatarType)
            {
               return true;
            }
         }
         _loc5_ = ASCompat.reinterpretAs(mPets.iterator() , IMapIterator);
         while(_loc5_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc5_.next(), account.PetInfo);
            if(param1 == _loc4_.PetType)
            {
               return true;
            }
         }
         _loc5_ = ASCompat.reinterpretAs(mSkins.iterator() , IMapIterator);
         while(_loc5_.hasNext())
         {
            _loc3_ = ASCompat.dynamicAs(_loc5_.next(), actor.player.SkinInfo);
            if(param1 == _loc3_.skinType)
            {
               return true;
            }
         }
         if(mDBFacade.gameMaster.isSkinTypeADefaultSkin(param1))
         {
            return true;
         }
         return false;
      }
      
      public function getEquipedItemsOnAvatar(param1:UInt) : Vector<ItemInfo>
      {
         var _loc3_:IMapIterator = null;
         var _loc4_:ItemInfo = null;
         var _loc2_= new Vector<ItemInfo>();
         _loc3_ = ASCompat.reinterpretAs(mItems.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc3_.next() , ItemInfo);
            if(_loc4_.avatarId == param1)
            {
               _loc2_.push(_loc4_);
            }
         }
         return _loc2_;
      }
      
      public function getEquipedPetsOnAvatar(param1:UInt) : Vector<PetInfo>
      {
         var _loc4_:IMapIterator = null;
         var _loc3_:PetInfo = null;
         var _loc2_= new Vector<PetInfo>();
         _loc4_ = ASCompat.reinterpretAs(mPets.iterator() , IMapIterator);
         while(_loc4_.hasNext())
         {
            _loc3_ = ASCompat.dynamicAs(_loc4_.next() , PetInfo);
            if(_loc3_.EquippedHero == param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function getEquipedConsumablesOnAvatar(param1:AvatarInfo) : Vector<StackableInfo>
      {
         var _loc4_:ASAny = null;
         var _loc5_:StackableInfo = null;
         var _loc2_:GMStackable = null;
         var _loc3_= new Vector<StackableInfo>();
         if(param1.consumable1Id > 0 && param1.consumable1Count > 0)
         {
            _loc2_ = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(param1.consumable1Id), gameMasterDictionary.GMStackable);
            _loc5_ = new StackableInfo(mDBFacade,null,_loc2_);
            _loc5_.setPropertiesAsConsumable(_loc2_.Id,(0 : UInt),param1.consumable1Count);
            _loc3_.push(_loc5_);
         }
         if(param1.consumable2Id > 0 && param1.consumable2Count > 0)
         {
            _loc2_ = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(param1.consumable2Id), gameMasterDictionary.GMStackable);
            _loc5_ = new StackableInfo(mDBFacade,null,ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(param1.consumable2Id), gameMasterDictionary.GMStackable));
            _loc5_.setPropertiesAsConsumable(_loc2_.Id,(1 : UInt),param1.consumable2Count);
            _loc3_.push(_loc5_);
         }
         return _loc3_;
      }
      
      @:isVar public var highestAvatarLevel(get,never):UInt;
public function  get_highestAvatarLevel() : UInt
      {
         var _loc1_:AvatarInfo = null;
         var _loc2_= (0 : UInt);
         var _loc3_= ASCompat.reinterpretAs(mAvatars.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc1_ = ASCompat.dynamicAs(_loc3_.next(), account.AvatarInfo);
            _loc2_ = (Std.int(Math.max(_loc2_,_loc1_.level)) : UInt);
         }
         return _loc2_;
      }
      
      @:isVar public var items(get,never):Map;
public function  get_items() : Map
      {
         return mItems;
      }
      
      @:isVar public var chests(get,never):Vector<ChestInfo>;
public function  get_chests() : Vector<ChestInfo>
      {
         return mChests;
      }
      
      @:isVar public var keys(get,never):Vector<KeyInfo>;
public function  get_keys() : Vector<KeyInfo>
      {
         return mKeys;
      }
      
      @:isVar public var stackables(get,never):Map;
public function  get_stackables() : Map
      {
         return mStackablesByDatabaseId;
      }
      
      @:isVar public var stackablesByStackableID(get,never):Map;
public function  get_stackablesByStackableID() : Map
      {
         return mStackablesByStackableId;
      }
      
      @:isVar public var avatars(get,never):Map;
public function  get_avatars() : Map
      {
         return mAvatars;
      }
      
      @:isVar public var mapnodes1(get,never):Map;
public function  get_mapnodes1() : Map
      {
         var _loc5_= 0;
         var _loc1_:MapnodeInfo = null;
         var _loc2_:GMMapNode = null;
         var _loc12_= 0;
         var _loc9_= false;
         var _loc10_= 0;
         var _loc11_= 0;
         var _loc4_= new Map();
         var _loc3_= mDBFacade.dbAccountInfo.activeAvatarInfo;
         var _loc7_= _loc3_.level;
         var _loc6_= mDBFacade.dbAccountInfo.trophies;
         var _loc8_:ASObject = mDBFacade.dbAccountInfo.activeAvatarInfo.mapNodes;
         _loc5_ = 0;
         while(_loc5_ < _loc3_.mapNodes.length)
         {
            _loc1_ = new MapnodeInfo();
            _loc12_ = (_loc3_.mapNodes[_loc5_].node_id : Int);
            if(_loc3_.mapNodes[_loc5_].isCompleted)
            {
               _loc1_.init((_loc12_ : UInt),(1 : UInt));
            }
            else
            {
               _loc1_.init((_loc12_ : UInt),(3 : UInt));
            }
            _loc4_.add(_loc12_,_loc1_);
            _loc5_ = ASCompat.toInt(_loc5_) + 1;
         }
         _loc5_ = 0;
         while(_loc5_ < mDBFacade.gameMaster.MapNodes.length)
         {
            _loc2_ = mDBFacade.gameMaster.MapNodes[_loc5_];
            if(ASCompat.mapItemForEqNull(_loc4_, _loc2_.Id) && _loc2_.LevelRequirement <= _loc7_ && _loc2_.TrophyRequirement <= _loc6_)
            {
               if(_loc2_.ParentNodes.length == 0)
               {
                  _loc1_ = new MapnodeInfo();
                  _loc1_.init(_loc2_.Id,(2 : UInt));
                  _loc4_.add(_loc2_.Id,_loc1_);
               }
               else
               {
                  _loc9_ = false;
                  _loc10_ = 0;
                  while(_loc10_ < _loc3_.mapNodes.length && !_loc9_)
                  {
                     _loc11_ = 0;
                     while(_loc11_ < _loc2_.ParentNodes.length && !_loc9_)
                     {
                        if(ASCompat.toNumberField(_loc2_.ParentNodes[_loc11_], "Id") == _loc3_.mapNodes[_loc10_].node_id)
                        {
                           _loc9_ = true;
                        }
                        _loc11_ = ASCompat.toInt(_loc11_) + 1;
                     }
                     _loc10_ = ASCompat.toInt(_loc10_) + 1;
                  }
                  if(_loc9_)
                  {
                     _loc1_ = new MapnodeInfo();
                     _loc1_.init(_loc2_.Id,(2 : UInt));
                     _loc4_.add(_loc2_.Id,_loc1_);
                  }
               }
            }
            _loc5_ = ASCompat.toInt(_loc5_) + 1;
         }
         return _loc4_;
      }
      
      @:isVar public var pets(get,never):Map;
public function  get_pets() : Map
      {
         return mPets;
      }
      
      public function getTotalHeroesOwned() : UInt
      {
         return mTotalHeroesOwned;
      }
      
      public function parseJson(param1:ASObject) 
      {
         if(ASCompat.toBool(param1.account_avatars))
         {
            parseAvatars(param1.account_avatars);
         }
         if(ASCompat.toBool(param1.account_items))
         {
            parseItems(param1.account_items);
         }
         if(ASCompat.toBool(param1.account_chests))
         {
            parseChests(param1.account_chests);
         }
         if(ASCompat.toBool(param1))
         {
            parseKeys(param1);
         }
         if(ASCompat.toBool(param1.account_stackables))
         {
            parseStackables(param1.account_stackables);
         }
         if(ASCompat.toBool(param1.buckets_weapon))
         {
            mStorageLimitWeapon = (ASCompat.toInt(param1.buckets_weapon) : UInt);
         }
         if(ASCompat.toBool(param1.buckets_other))
         {
            mStorageLimitOther = (ASCompat.toInt(param1.buckets_other) : UInt);
         }
         if(ASCompat.toBool(param1.account_pets))
         {
            parsePetInfo(param1.account_pets);
         }
         if(ASCompat.toBool(param1.account_skins))
         {
            parseSkinInfo(param1.account_skins);
         }
         if(ASCompat.toBool(param1.account_boosters))
         {
            parseBoosters(param1.account_boosters);
         }
         mFirstParse = false;
         mTotalHeroesOwned = mAvatars.size;
      }
      
      function parseAvatars(param1:ASObject) 
      {
         var _loc2_:AvatarInfo = null;
         var _loc4_= 0;
         mAvatars.clear();
         var _loc3_:Array<ASAny> = ASCompat.dynamicAs(param1 , Array);
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc2_ = new AvatarInfo(mDBFacade,_loc3_[_loc4_],mResponseCallback);
            mAvatars.add(_loc2_.id,_loc2_);
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      function parseItems(param1:ASObject) 
      {
         var _loc4_:ItemInfo = null;
         var _loc2_= 0;
         var _loc3_= mItems.keysToArray();
         mItems.clear();
         var _loc5_:Array<ASAny> = ASCompat.dynamicAs(param1 , Array);
         _loc2_ = 0;
         while(_loc2_ < _loc5_.length)
         {
            _loc4_ = new ItemInfo(mDBFacade,_loc5_[_loc2_]);
            if(!mFirstParse && _loc3_.indexOf(_loc5_[_loc2_].id) == -1)
            {
               _loc4_.isNew = true;
            }
            mItems.add(_loc4_.databaseId,_loc4_);
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      function parseChests(param1:ASObject) 
      {
         var _loc4_:ChestInfo;
         var _loc6_:ChestInfo = null;
         var _loc7_= 0;
         var _loc5_= false;
         var _loc3_= mChests.slice(0);
         mChests.splice(0,(mChests.length : UInt));
         var _loc2_:Array<ASAny> = ASCompat.dynamicAs(param1 , Array);
         _loc7_ = 0;
         while(_loc7_ < _loc2_.length)
         {
            _loc5_ = false;
            if(!mFirstParse)
            {
               if (checkNullIteratee(_loc3_)) for (_tmp_ in _loc3_)
               {
                  _loc4_ = _tmp_;
                  if(_loc4_.databaseId == (_loc2_[_loc7_].id : UInt))
                  {
                     _loc5_ = true;
                     break;
                  }
               }
            }
            else
            {
               _loc5_ = true;
            }
            _loc6_ = new ChestInfo(mDBFacade,_loc2_[_loc7_]);
            if(!_loc5_)
            {
               _loc6_.isNew = true;
            }
            mChests.push(_loc6_);
            _loc7_ = ASCompat.toInt(_loc7_) + 1;
         }
      }
      
      function parseKeys(param1:ASObject) 
      {
         var _loc6_:KeyInfo = null;
         var _loc4_= 0;
         var _loc5_= 0;
         var _loc2_= 0;
         mKeys.splice(0,(mKeys.length : UInt));
         var _loc3_= mDBFacade.gameMaster.Keys;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = (_loc3_[_loc4_].OfferId : Int);
            _loc2_ = 0;
            switch(_loc4_)
            {
               case 0:
                  _loc2_ = ASCompat.toInt(param1.basic_keys);
                  
               case 1:
                  _loc2_ = ASCompat.toInt(param1.uncommon_keys);
                  
               case 2:
                  _loc2_ = ASCompat.toInt(param1.rare_keys);
                  
               case 3:
                  _loc2_ = ASCompat.toInt(param1.legendary_keys);
            }
            _loc6_ = new KeyInfo(ASCompat.dynamicAs(mDBFacade.gameMaster.keysByOfferId.itemFor(_loc5_), gameMasterDictionary.GMKey),ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(_loc5_), gameMasterDictionary.GMOffer),(_loc2_ : UInt));
            mKeys.push(_loc6_);
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      function parseStackables(param1:ASObject) 
      {
         var _loc5_:StackableInfo = null;
         var _loc4_= 0;
         var _loc2_= mStackablesByDatabaseId.keysToArray();
         mStackablesByDatabaseId.clear();
         mStackablesByStackableId.clear();
         var _loc3_:Array<ASAny> = ASCompat.dynamicAs(param1 , Array);
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = new StackableInfo(mDBFacade,_loc3_[_loc4_]);
            if(!mFirstParse && _loc2_.indexOf(_loc3_[_loc4_].id) == -1)
            {
               _loc5_.isNew = true;
            }
            mStackablesByDatabaseId.add(_loc5_.databaseId,_loc5_);
            mStackablesByStackableId.add(_loc5_.gmId,_loc5_);
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      function parseBoosters(param1:ASObject) 
      {
         var _loc2_:BoosterInfo = null;
         var _loc3_= 0;
         var _loc5_= mBoostersByDatabaseId.keysToArray();
         mBoostersByDatabaseId.clear();
         mBoostersByStackableId.clear();
         var _loc4_:Array<ASAny> = ASCompat.dynamicAs(param1 , Array);
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            _loc2_ = new BoosterInfo(mDBFacade,_loc4_[_loc3_]);
            if(!mFirstParse && _loc5_.indexOf(_loc4_[_loc3_].id) == -1)
            {
               _loc2_.isNew = true;
            }
            mBoostersByDatabaseId.add(_loc2_.databaseId,_loc2_);
            mBoostersByStackableId.add(_loc2_.gmId,_loc2_);
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
         mDBFacade.eventManager.dispatchEvent(new BoostersParsedEvent("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE"));
      }
      
      function parsePetInfo(param1:ASObject) 
      {
         var _loc3_:PetInfo = null;
         var _loc4_= 0;
         var _loc5_= mPets.keysToArray();
         mPets.clear();
         var _loc2_:Array<ASAny> = ASCompat.dynamicAs(param1 , Array);
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = new PetInfo(mDBFacade,_loc2_[_loc4_]);
            if(!mFirstParse && _loc5_.indexOf(_loc2_[_loc4_].id) == -1)
            {
               _loc3_.isNew = true;
            }
            mPets.add(_loc3_.databaseId,_loc3_);
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      function parseSkinInfo(param1:ASObject) 
      {
         var _loc3_:SkinInfo = null;
         var _loc4_= 0;
         mSkins.clear();
         var _loc2_:Array<ASAny> = ASCompat.dynamicAs(param1 , Array);
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = new SkinInfo(mDBFacade,_loc2_[_loc4_]);
            mSkins.add(_loc3_.skinType,_loc3_);
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      public function openChest(param1:UInt, param2:UInt, param3:UInt, param4:ASFunction = null, param5:ASFunction = null) 
      {
         var rpcFunc:ASFunction;
         var chestInstanceId= param1;
         var forHeroId= param2;
         var forHeroSkinId= param3;
         var responseFinishedCallback= param4;
         var errorCallback= param5;
         if((mLastPendingChest : UInt) == chestInstanceId && 0 != 0)
         {
            Logger.error("Chest has already been opened on Server. Chest id:" + chestInstanceId);
            mLastPendingChest = -1;
            return;
         }
         mLastPendingChest = (chestInstanceId : Int);
         rpcFunc = JSONRPCService.getFunction("OpenChest",mDBFacade.rpcRoot + "account");
         rpcFunc(mDBFacade.dbAccountInfo.id,chestInstanceId,mDBFacade.validationToken,forHeroId,forHeroSkinId,function(param1:ASAny)
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback(chestInstanceId,param1);
            }
         },function(param1:Error)
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function dropChest(param1:UInt, param2:ASFunction = null, param3:ASFunction = null) 
      {
         var chestInstanceId= param1;
         var responseFinishedCallback= param2;
         var errorCallback= param3;
         var rpcFunc= JSONRPCService.getFunction("DropChest",mDBFacade.rpcRoot + "account");
         rpcFunc(mDBFacade.dbAccountInfo.id,chestInstanceId,mDBFacade.validationToken,function(param1:ASAny)
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback(chestInstanceId,param1);
            }
         },function(param1:Error)
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function canThisAvatarEquipThisItem(param1:AvatarInfo, param2:ItemInfo) : Bool
      {
         if(param1 == null)
         {
            return false;
         }
         if(param2 == null)
         {
            return false;
         }
         if(!canAvatarEquipThisMasterType(param1,param2.gmWeaponItem.MasterType))
         {
            return false;
         }
         if(param1.level < param2.requiredLevel)
         {
            return false;
         }
         return true;
      }
      
      public function canAvatarEquipThisMasterType(param1:AvatarInfo, param2:String) : Bool
      {
         return param1.gmHero.AllowedWeapons.hasKey(param2);
      }
      
      public function recalculateWeaponPowers(param1:ASFunction = null, param2:ASFunction = null) 
      {
         var itemInfo:ItemInfo;
         var rpcFunc:ASFunction;
         var responseFinishedCallback= param1;
         var errorCallback= param2;
         var iter= ASCompat.reinterpretAs(mItems.iterator() , IMapIterator);
         var itemIds:Array<ASAny> = [];
         while(iter.hasNext())
         {
            itemInfo = ASCompat.dynamicAs(iter.next(), account.ItemInfo);
            itemIds.push(itemInfo.databaseId);
         }
         rpcFunc = JSONRPCService.getFunction("RecalculateWeaponPowers",mDBFacade.rpcRoot + "inventorymanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,itemIds,mDBFacade.validationToken,function(param1:ASAny)
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback(param1);
            }
         },function(param1:Error)
         {
            mParseErrorCallback(param1);
            if(errorCallback != null)
            {
               errorCallback();
            }
         });
      }
      
      public function equipItemOnAvatar(param1:UInt, param2:UInt, param3:UInt, param4:ASFunction = null, param5:ASFunction = null) 
      {
         var avatarInstanceId= param1;
         var itemInstanceId= param2;
         var equipSlot= param3;
         var responseFinishedCallback= param4;
         var errorCallback= param5;
         var rpcFunc= JSONRPCService.getFunction("equipItemOnAvatar",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,avatarInstanceId,itemInstanceId,equipSlot,mDBFacade.validationToken,function(param1:ASAny)
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error)
         {
            mParseErrorCallback(param1);
            if(errorCallback != null)
            {
               errorCallback();
            }
         });
      }
      
      public function unequipItemOffAvatar(param1:InventoryBaseInfo, param2:ASFunction = null, param3:ASFunction = null) 
      {
         var rpcFunc:ASFunction;
         var itemInfo= param1;
         var responseFinishedCallback= param2;
         var errorCallback= param3;
         if(!itemInfo.isEquipped)
         {
            Logger.error("Trying to unequip an item that is not currently equipped.");
            if(errorCallback != null)
            {
               errorCallback(new Error("Trying to unequip an item that is not currently equipped.",-1));
            }
         }
         rpcFunc = JSONRPCService.getFunction("unequipItemOffAvatar",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,itemInfo.databaseId,mDBFacade.validationToken,function(param1:ASAny)
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error)
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function equipConsumableOnAvatar(param1:UInt, param2:UInt, param3:UInt, param4:Bool = false, param5:ASFunction = null, param6:ASFunction = null) 
      {
         var avatarInstanceId= param1;
         var stackableId= param2;
         var equipSlot= param3;
         var swapping= param4;
         var responseFinishedCallback= param5;
         var errorCallback= param6;
         var rpcFunc= JSONRPCService.getFunction("equipConsumableOnAvatar",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,avatarInstanceId,stackableId,equipSlot,swapping,mDBFacade.validationToken,function(param1:ASAny)
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error)
         {
            mParseErrorCallback(param1);
            if(errorCallback != null)
            {
               errorCallback();
            }
         });
      }
      
      public function unequipConsumableOffAvatar(param1:UInt, param2:UInt, param3:UInt, param4:ASFunction = null, param5:ASFunction = null) 
      {
         var avatarInstanceId= param1;
         var stackableId= param2;
         var equipSlot= param3;
         var responseFinishedCallback= param4;
         var errorCallback= param5;
         var rpcFunc= JSONRPCService.getFunction("unequipConsumableOffAvatar",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,avatarInstanceId,stackableId,equipSlot,mDBFacade.validationToken,function(param1:ASAny)
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error)
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function canEquipThisConsumable(param1:AvatarInfo, param2:UInt, param3:UInt) : Bool
      {
         var _loc4_= true;
         if(param2 == 0)
         {
            if(param1.consumable2Id > 0 && param1.consumable2Count > 0)
            {
               _loc4_ = param1.consumable2Id != param3;
            }
         }
         else if(param2 == 1)
         {
            if(param1.consumable1Id > 0 && param1.consumable1Count > 0)
            {
               _loc4_ = param1.consumable1Id != param3;
            }
         }
         return _loc4_;
      }
      
      public function equipPetOnAvatar(param1:UInt, param2:UInt, param3:ASFunction = null, param4:ASFunction = null) 
      {
         var avatarInstanceId= param1;
         var petId= param2;
         var responseFinishedCallback= param3;
         var errorCallback= param4;
         var rpcFunc= JSONRPCService.getFunction("equipPetOnAvatar",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,avatarInstanceId,petId,mDBFacade.validationToken,function(param1:ASAny)
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error)
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function unequipPet(param1:PetInfo, param2:ASFunction = null, param3:ASFunction = null) 
      {
         var rpcFunc:ASFunction;
         var petInfo= param1;
         var responseFinishedCallback= param2;
         var errorCallback= param3;
         if(!petInfo.isEquipped)
         {
            Logger.error("Trying to unequip a pet that is not currently equipped.");
            if(errorCallback != null)
            {
               errorCallback(new Error("Trying to unequip a pet that is not currently equipped.",-1));
            }
         }
         rpcFunc = JSONRPCService.getFunction("unEquipPet",mDBFacade.rpcRoot + "avatarmanager");
         rpcFunc(mDBFacade.dbAccountInfo.id,petInfo.databaseId,mDBFacade.validationToken,function(param1:ASAny)
         {
            mResponseCallback(param1);
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         },function(param1:Error)
         {
            mParseErrorCallback(param1);
            errorCallback();
         });
      }
      
      public function numberOfEmptySlotsInWeaponStorage() : UInt
      {
         return mStorageLimitWeapon - unequippedWeaponCount;
      }
      
      public function isThereEmptySpaceInWeaponStorage() : Bool
      {
         return unequippedWeaponCount < mStorageLimitWeapon;
      }
      
      @:isVar public var storageLimitWeapon(get,never):UInt;
public function  get_storageLimitWeapon() : UInt
      {
         return mStorageLimitWeapon;
      }
      
      public function isEquippableByAnyOwnedAvatar(param1:ItemInfo) : Bool
      {
         var _loc3_:IMapIterator = null;
         var _loc2_:AvatarInfo = null;
         _loc3_ = ASCompat.reinterpretAs(mAvatars.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc3_.next(), account.AvatarInfo);
            if(this.canThisAvatarEquipThisItem(_loc2_,param1))
            {
               return true;
            }
         }
         return false;
      }
      
      @:isVar public var hasNewEquippableItems(get,never):Bool;
public function  get_hasNewEquippableItems() : Bool
      {
         var _loc3_:IMapIterator = null;
         var _loc4_:ItemInfo = null;
         var _loc5_:StackableInfo = null;
         var _loc1_:PetInfo = null;
         _loc3_ = ASCompat.reinterpretAs(mItems.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc3_.next(), account.ItemInfo);
            if(_loc4_.isNew && this.isEquippableByAnyOwnedAvatar(_loc4_))
            {
               return true;
            }
         }
         _loc3_ = ASCompat.reinterpretAs(mStackablesByStackableId.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc5_ = ASCompat.dynamicAs(_loc3_.next(), account.StackableInfo);
            if(_loc5_.isNew)
            {
               return true;
            }
         }
         _loc3_ = ASCompat.reinterpretAs(mPets.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc1_ = ASCompat.dynamicAs(_loc3_.next(), account.PetInfo);
            if(_loc1_.isNew)
            {
               return true;
            }
         }
         var _loc2_:ChestInfo;
         final __ax4_iter_9 = mChests;
         if (checkNullIteratee(__ax4_iter_9)) for (_tmp_ in __ax4_iter_9)
         {
            _loc2_ = _tmp_;
            if(ASCompat.toBool(_loc2_.isNew))
            {
               return true;
            }
         }
         return false;
      }
      
      public function markItemsNotNew() 
      {
         var _loc3_:IMapIterator = null;
         var _loc4_:ItemInfo = null;
         var _loc5_:StackableInfo = null;
         var _loc1_:PetInfo = null;
         _loc3_ = ASCompat.reinterpretAs(mItems.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc4_ = ASCompat.dynamicAs(_loc3_.next(), account.ItemInfo);
            _loc4_.isNew = false;
         }
         _loc3_ = ASCompat.reinterpretAs(mStackablesByStackableId.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc5_ = ASCompat.dynamicAs(_loc3_.next(), account.StackableInfo);
            _loc5_.isNew = false;
         }
         _loc3_ = ASCompat.reinterpretAs(mPets.iterator() , IMapIterator);
         while(_loc3_.hasNext())
         {
            _loc1_ = ASCompat.dynamicAs(_loc3_.next(), account.PetInfo);
            _loc1_.isNew = false;
         }
         var _loc2_:ChestInfo;
         final __ax4_iter_10 = mChests;
         if (checkNullIteratee(__ax4_iter_10)) for (_tmp_ in __ax4_iter_10)
         {
            _loc2_ = _tmp_;
            ASCompat.setProperty(_loc2_, "isNew", false);
         }
      }
      
      public function getSkinsForHero(param1:GMHero, param2:Map) : Vector<GMSkin>
      {
         var skin:GMSkin;
         var offer:GMOffer;
         var gmHero= param1;
         var offerBySkinId= param2;
         var result= new Vector<GMSkin>();
         final __ax4_iter_11 = mDBFacade.gameMaster.Skins;
         if (checkNullIteratee(__ax4_iter_11)) for (_tmp_ in __ax4_iter_11)
         {
            skin  = _tmp_;
            if(skin.ForHero == gmHero.Constant)
            {
               offer = ASCompat.dynamicAs(offerBySkinId.itemFor(skin.Id), gameMasterDictionary.GMOffer);
               if(!isSkinExpired(skin,offer))
               {
                  result.push(skin);
               }
            }
         }
         ASCompat.ASVector.sort(result, function(param1:GMSkin, param2:GMSkin):Int
         {
            return (param1.Id - param2.Id : Int);
         });
         return result;
      }
      
      public function isSkinExpired(param1:GMSkin, param2:GMOffer) : Bool
      {
         var _loc7_= GameClock.date.getTime();
         var _loc4_= false;
         var _loc3_:Float = 0;
         var _loc6_= false;
         var _loc5_:Float = 0;
         if(param2 != null)
         {
            _loc4_ = param2.VisibleDate != null || param2.StartDate != null;
            if(_loc4_)
            {
               _loc3_ = param2.VisibleDate != null ? param2.VisibleDate.getTime(): param2.StartDate.getTime();
            }
            _loc6_ = param2.EndDate != null || param2.SoldOutDate != null;
            if(_loc6_)
            {
               _loc5_ = param2.SoldOutDate != null ? param2.SoldOutDate.getTime(): param2.EndDate.getTime();
            }
         }
         if(doesPlayerOwnSkin(param1.Id) || (param2 != null && !_loc4_ || _loc3_ <= _loc7_ && (!_loc6_ || _loc5_ > _loc7_)))
         {
            return false;
         }
         return true;
      }
      
      public function doesPlayerOwnSkin(param1:UInt) : Bool
      {
         return mSkins.hasKey(param1) || mDBFacade.gameMaster.isSkinTypeADefaultSkin(param1);
      }
      
      public function getSkinInfo(param1:UInt) : SkinInfo
      {
         if(mSkins.hasKey(param1))
         {
            return ASCompat.dynamicAs(mSkins.itemFor(param1), actor.player.SkinInfo);
         }
         return null;
      }
      
      public function getDefaultSkinForHero(param1:GMHero) : GMSkin
      {
         var _loc2_= mDBFacade.gameMaster.getSkinByConstant(param1.DefaultSkin);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find default skin for hero type: " + param1.Id);
         }
         return _loc2_;
      }
      
      public function canShowInfiniteIsland() : Bool
      {
         var _loc1_= ASCompat.dynamicAs(mapnodes1.itemFor(50150), account.MapnodeInfo);
         return _loc1_ != null;
      }
   }


