package gameMasterDictionary
;
   import brain.clock.GameClock;
   
    class GMOffer
   {
      
      public static inline final BASIC_CURRENCY= "BASIC";
      
      public static inline final PREMIUM_CURRENCY= "PREMIUM";
      
      static inline final SPECIAL_NEW= "NEW";
      
      static inline final SPECIAL_FEATURED= "FEATURED";
      
      static inline final SPECIAL_SALE= "SALE";
      
      var mPrice:UInt = 0;
      
      public var Id:UInt = 0;
      
      public var CurrencyType:String;
      
      public var Tab:String;
      
      public var Location:String;
      
      public var CoinOfferId:UInt = 0;
      
      public var CoinOffer:GMOffer;
      
      public var IsCoinAltOffer:Bool = false;
      
      public var VisibleDate:Date;
      
      public var StartDate:Date;
      
      public var EndDate:Date;
      
      public var SoldOutDate:Date;
      
      public var SaleTargetOfferId:UInt = 0;
      
      public var SaleTargetOffer:GMOffer;
      
      public var SaleOffers:Vector<GMOffer>;
      
      public var SalePercentOff:UInt = 0;
      
      public var SaleStartDate:Date;
      
      public var SaleEndDate:Date;
      
      public var LimitedQuantity:UInt = 0;
      
      var mSpecial:String;
      
      public var Gift:Bool = false;
      
      public var IsBundle:Bool = false;
      
      public var BundleName:String;
      
      public var BundleIcon:String;
      
      public var BundleSwfFilepath:String;
      
      public var BundleDescription:String = "";
      
      public var Rarity:String;
      
      public var OrigPriceA:UInt = 0;
      
      public var Details:Vector<GMOfferDetail>;
      
      public function new(param1:ASObject, param2:ASObject)
      {
         
         Id = (ASCompat.toInt(param1.Id) : UInt);
         CurrencyType = param1.CurrencyType;
         this.determinePrice(param1,param2);
         Tab = param1.Tab;
         Location = param1.Location;
         CoinOfferId = (ASCompat.toInt(param1.CoinOfferId) : UInt);
         SaleTargetOfferId = (ASCompat.toInt(param1.SaleOffer) : UInt);
         IsBundle = ASCompat.toBool(param1.IsBundle);
         if(IsBundle)
         {
            BundleName = param1.BundleName;
            BundleIcon = param1.BundleIcon;
            BundleSwfFilepath = param1.BundleSwfFilepath;
            BundleDescription = param1.BundleDescription;
         }
         Rarity = param1.Rarity;
         if(ASCompat.toBool(param1.VisibleDate))
         {
            VisibleDate = GameClock.parseW3CDTF(param1.VisibleDate);
         }
         if(ASCompat.toBool(param1.StartDate))
         {
            StartDate = GameClock.parseW3CDTF(param1.StartDate);
         }
         if(ASCompat.toBool(param1.EndDate))
         {
            EndDate = GameClock.parseW3CDTF(param1.EndDate);
         }
         if(ASCompat.toBool(param1.SoldOutDate))
         {
            SoldOutDate = GameClock.parseW3CDTF(param1.SoldOutDate);
         }
         if(ASCompat.toBool(param1.SaleStartDate))
         {
            SaleStartDate = GameClock.parseW3CDTF(param1.SaleStartDate);
         }
         if(ASCompat.toBool(param1.SaleEndDate))
         {
            SaleEndDate = GameClock.parseW3CDTF(param1.SaleEndDate);
         }
         SalePercentOff = (ASCompat.toInt(param1.SalePercentOff) : UInt);
         LimitedQuantity = (ASCompat.toInt(param1.LimitedQuantity) : UInt);
         mSpecial = param1.Special;
         Gift = ASCompat.toBool(param1.Gift);
         Details = new Vector<GMOfferDetail>();
      }
      
      @:isVar public var percentOff(get,never):UInt;
public function  get_percentOff() : UInt
      {
         if(SaleTargetOffer != null && SalePercentOff != 0)
         {
            return SalePercentOff;
         }
         return (0 : UInt);
      }
      
      @:isVar public var Special(get,never):Bool;
public function  get_Special() : Bool
      {
         if(isFeatured)
         {
            return true;
         }
         if(this.isOnSaleNow != null && this.isSale)
         {
            return true;
         }
         return ASCompat.toBool(mSpecial);
      }
      
      public function isVisible() : Bool
      {
         var _loc3_= Math.NaN;
         var _loc2_= Math.NaN;
         var _loc5_= Math.NaN;
         var _loc4_= Math.NaN;
         var _loc6_= Math.NaN;
         var _loc1_= Math.NaN;
         var _loc7_= GameClock.getWebServerTime();
         if(VisibleDate != null)
         {
            _loc3_ = VisibleDate.getTime();
            if(_loc3_ > _loc7_)
            {
               return false;
            }
            if(SoldOutDate != null)
            {
               _loc2_ = SoldOutDate.getTime();
               if(_loc2_ < _loc7_)
               {
                  return false;
               }
            }
            else if(EndDate != null)
            {
               _loc5_ = EndDate.getTime();
               if(_loc5_ < _loc7_)
               {
                  return false;
               }
            }
            return true;
         }
         if(StartDate != null)
         {
            _loc4_ = StartDate.getTime();
            if(_loc4_ > _loc7_)
            {
               return false;
            }
            if(SoldOutDate != null)
            {
               _loc6_ = SoldOutDate.getTime();
               if(_loc6_ < _loc7_)
               {
                  return false;
               }
            }
            else if(EndDate != null)
            {
               _loc1_ = EndDate.getTime();
               if(_loc1_ < _loc7_)
               {
                  return false;
               }
            }
            return true;
         }
         return true;
      }
      
      public function isAvailableTime() : Bool
      {
         var _loc1_= Math.NaN;
         var _loc2_= Math.NaN;
         var _loc3_= GameClock.getWebServerTime();
         if(StartDate != null)
         {
            _loc1_ = StartDate.getTime();
            if(_loc1_ > _loc3_)
            {
               return false;
            }
         }
         if(EndDate != null)
         {
            _loc2_ = EndDate.getTime();
            if(_loc2_ < _loc3_)
            {
               return false;
            }
         }
         return true;
      }
      
      @:isVar public var isFeatured(get,never):Bool;
public function  get_isFeatured() : Bool
      {
         var _loc1_= isOnSaleNow;
         if(_loc1_ != null && _loc1_.mSpecial == "FEATURED")
         {
            return true;
         }
         return mSpecial == "FEATURED";
      }
      
      @:isVar public var isNew(get,never):Bool;
public function  get_isNew() : Bool
      {
         return mSpecial == "NEW";
      }
      
      @:isVar public var isSale(get,never):Bool;
public function  get_isSale() : Bool
      {
         return mSpecial == "SALE" || mSpecial == "FEATURED";
      }
      
      @:isVar public var isOnSaleNow(get,never):GMOffer;
public function  get_isOnSaleNow() : GMOffer
      {
         var _loc2_= Math.NaN;
         var _loc3_= Math.NaN;
         if(this.SaleOffers == null)
         {
            return null;
         }
         var _loc4_= GameClock.getWebServerTime();
         var _loc1_:GMOffer;
         final __ax4_iter_47 = this.SaleOffers;
         if (checkNullIteratee(__ax4_iter_47)) for (_tmp_ in __ax4_iter_47)
         {
            _loc1_ = _tmp_;
            if(!(ASCompat.toBool(_loc1_.SaleStartDate) && ASCompat.toBool(_loc1_.SaleEndDate)))
            {
               return _loc1_;
            }
            _loc2_ = ASCompat.toNumber(_loc1_.SaleStartDate.getTime());
            _loc3_ = ASCompat.toNumber(_loc1_.SaleEndDate.getTime());
            if(_loc2_ < _loc4_ && _loc4_ < _loc3_)
            {
               return _loc1_;
            }
         }
         return null;
      }
      
      function determinePrice(param1:ASObject, param2:ASObject) 
      {
         var _loc3_:ASAny = null;
         OrigPriceA = (ASCompat.toInt(param1.Price) : UInt);
         mPrice = OrigPriceA;
         if (checkNullIteratee(param2)) for (_tmp_ in iterateDynamicValues(param2))
         {
            _loc3_  = _tmp_;
            if(_loc3_.name == "GemValue1" && CurrencyType == "PREMIUM")
            {
               mPrice = (Math.ceil(ASCompat.toNumber(mPrice * ASCompat.toNumberField(_loc3_, "value"))) : UInt);
            }
         }
         if(CurrencyType == "PREMIUM")
         {
            if (checkNullIteratee(param2)) for (_tmp_ in iterateDynamicValues(param2))
            {
               _loc3_  = _tmp_;
               if(_loc3_.name == "InDungeonHealthBombSale" && Id == 51304)
               {
                  mPrice = (Math.ceil(mPrice * ASCompat.toNumber(_loc3_.value)) : UInt);
               }
            }
         }
      }
      
      public function getDisplayName(param1:GameMaster, param2:String = "", param3:Bool = false) : String
      {
         var _loc10_:GMOfferDetail = null;
         var _loc6_:GMHero = null;
         var _loc4_:GMWeaponItem = null;
         var _loc5_:GMWeaponAesthetic = null;
         var _loc7_:GMNpc = null;
         var _loc9_:GMSkin = null;
         var _loc8_= param2;
         if(this.IsBundle)
         {
            _loc8_ = this.BundleName.toUpperCase();
         }
         else
         {
            _loc10_ = this.Details[0];
            if(_loc10_.HeroId != 0)
            {
               _loc6_ = ASCompat.dynamicAs(param1.heroById.itemFor(_loc10_.HeroId), gameMasterDictionary.GMHero);
               if(_loc6_ != null)
               {
                  _loc8_ = _loc6_.Name.toUpperCase();
               }
            }
            else if(_loc10_.WeaponId != 0)
            {
               _loc4_ = ASCompat.dynamicAs(param1.weaponItemById.itemFor(_loc10_.WeaponId), gameMasterDictionary.GMWeaponItem);
               _loc5_ = _loc4_.getWeaponAesthetic(_loc10_.Level,param3);
               _loc8_ = _loc5_.Name.toUpperCase();
            }
            else if(_loc10_.PetId != 0)
            {
               _loc7_ = ASCompat.dynamicAs(param1.npcById.itemFor(_loc10_.PetId), gameMasterDictionary.GMNpc);
               if(_loc7_ != null)
               {
                  _loc8_ = _loc7_.Name.toUpperCase();
               }
            }
            else if(_loc10_.SkinId != 0)
            {
               _loc9_ = param1.getSkinByType(_loc10_.SkinId);
               if(_loc9_ != null)
               {
                  _loc8_ = _loc9_.Name.toUpperCase();
               }
            }
         }
         return _loc8_;
      }
      
      @:isVar public var Price(get,never):Float;
public function  get_Price() : Float
      {
         return mPrice;
      }
   }


