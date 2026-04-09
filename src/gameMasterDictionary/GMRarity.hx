package gameMasterDictionary
;
    class GMRarity
   {
      
      public var Id:UInt = 0;
      
      public var Constant:String;
      
      public var Type:String;
      
      public var NumberOfModifiers:UInt = 0;
      
      public var MaxModifierLevel:UInt = 0;
      
      public var MinModifierLevel:UInt = 0;
      
      public var HasColoredBackground:Bool = false;
      
      public var BackgroundIcon:String;
      
      public var BackgroundIconBorder:String;
      
      public var BackgroundSwf:String;
      
      public var KeyOfferId:Float = Math.NaN;
      
      public var MinSellPercent:Float = Math.NaN;
      
      public var MaxSellPercent:Float = Math.NaN;
      
      public var LevelWeight:Float = Math.NaN;
      
      public var ModifierWeight:Float = Math.NaN;
      
      public var BasePowerScale:Float = Math.NaN;
      
      public var BasePowerConstant:Float = Math.NaN;
      
      public var HasGlow:Bool = false;
      
      public var GlowColor:UInt = 0;
      
      public var GlowStr:UInt = 0;
      
      public var GlowDist:UInt = 0;
      
      public var TextColor:UInt = 0;
      
      public function new(param1:ASObject)
      {
         
         Id = (ASCompat.toInt(param1.Id) : UInt);
         KeyOfferId = ASCompat.toNumberField(param1, "KeyOfferId");
         Constant = Type = param1.Type;
         NumberOfModifiers = (ASCompat.toInt(param1.NumberOfModifiers) : UInt);
         HasColoredBackground = ASCompat.toBool(param1.HasColoredBackground);
         MaxModifierLevel = (ASCompat.toInt(param1.MaxModifierLevel) : UInt);
         MinModifierLevel = (ASCompat.toInt(param1.MinModifierLevel) : UInt);
         MinSellPercent = ASCompat.toNumberField(param1, "MinSellPercent");
         MaxSellPercent = ASCompat.toNumberField(param1, "MaxSellPercent");
         LevelWeight = ASCompat.toNumberField(param1, "LevelWeight");
         ModifierWeight = ASCompat.toNumberField(param1, "ModifierWeight");
         HasGlow = ASCompat.toBool(param1.HasGlow);
         GlowColor = (ASCompat.toInt(param1.GlowColor) : UInt);
         TextColor = (ASCompat.toInt(param1.TextColor) : UInt);
         GlowDist = (ASCompat.toInt(param1.GlowDist) : UInt);
         GlowStr = (ASCompat.toInt(param1.GlowStr) : UInt);
         BasePowerScale = ASCompat.toNumberField(param1, "BasePowerScale");
         BasePowerConstant = ASCompat.toNumberField(param1, "BasePowerConstant");
         if(HasColoredBackground)
         {
            BackgroundIcon = param1.BackgroundIcon;
            BackgroundIconBorder = param1.BackgroundIconBorder != null ? param1.BackgroundIconBorder : "";
            BackgroundSwf = param1.BackgroundSwf;
         }
      }
   }


