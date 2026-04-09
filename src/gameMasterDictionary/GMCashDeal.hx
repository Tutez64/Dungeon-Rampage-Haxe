package gameMasterDictionary
;
    class GMCashDeal
   {
      
      public var Id:UInt = 0;
      
      public var Name:String;
      
      public var Currency:String;
      
      public var Partner:String;
      
      var mPrice:Float = Math.NaN;
      
      public var Value:UInt = 0;
      
      public var Bonus:UInt = 0;
      
      public var Default:UInt = 0;
      
      public var ImageURL:String;
      
      public var ProductURL:String;
      
      public var SplitTest:String;
      
      public var Description:String;
      
      public var DragonKnightBonus:Bool = false;
      
      public function new(param1:ASObject, param2:ASObject)
      {
         
         Id = (ASCompat.toInt(param1.Id) : UInt);
         Name = param1.Name;
         mPrice = ASCompat.toNumberField(param1, "Price");
         Value = (ASCompat.toInt(param1.Value) : UInt);
         Bonus = (ASCompat.toInt(param1.Bonus) : UInt);
         ImageURL = param1.ImageURL;
         ProductURL = param1.ProductURL;
         Description = param1.Description;
         Currency = param1.Currency;
         Partner = param1.Partner;
         Default = (ASCompat.toInt(param1.Default) : UInt);
         SplitTest = param1.SplitTest;
         DragonKnightBonus = ASCompat.asBool(param1.DragonKnightBonus );
      }
      
      @:isVar public var Price(get,never):Float;
public function  get_Price() : Float
      {
         return mPrice;
      }
   }


