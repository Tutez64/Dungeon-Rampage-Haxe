package gameMasterDictionary
;
    class GMWeaponAesthetic
   {
      
      public var Release:String;
      
      public var WeaponItemConstant:String;
      
      public var Constant:String;
      
      public var Name:String;
      
      public var MinLevel:UInt = 0;
      
      public var MaxLevel:UInt = 0;
      
      public var ModelName:String;
      
      public var IconName:String;
      
      public var IconSwf:String;
      
      public var SwordTrailOverride:String;
      
      public var ItemR:Float = Math.NaN;
      
      public var ItemG:Float = Math.NaN;
      
      public var ItemB:Float = Math.NaN;
      
      public var ItemRAdd:Float = Math.NaN;
      
      public var ItemGAdd:Float = Math.NaN;
      
      public var ItemBAdd:Float = Math.NaN;
      
      public var HasColor:Bool = false;
      
      public var GlowDist:Float = Math.NaN;
      
      public var GlowStr:Float = Math.NaN;
      
      public var GlowColor:UInt = 0;
      
      public var HasGlow:Bool = false;
      
      public var TrailR:Float = Math.NaN;
      
      public var TrailG:Float = Math.NaN;
      
      public var TrailB:Float = Math.NaN;
      
      public var TrailRAdd:Float = Math.NaN;
      
      public var TrailGAdd:Float = Math.NaN;
      
      public var TrailBAdd:Float = Math.NaN;
      
      public var HasTrailColor:Bool = false;
      
      public var Description:String;
      
      public var IsLegendary:Bool = false;
      
      public function new(param1:ASObject)
      {
         
         Release = param1.Release;
         WeaponItemConstant = param1.WeaponItemConstant;
         Constant = param1.Constant;
         Name = param1.Name;
         MinLevel = ASCompat.asUint(param1.MinLvl );
         MaxLevel = ASCompat.asUint(param1.MaxLvl );
         ModelName = param1.ModelName;
         IconName = param1.IconName;
         IconSwf = param1.UISwfFilepath;
         SwordTrailOverride = param1.SwordTrailOverride;
         HasColor = param1.ItemR != null && param1.ItemG != null && param1.ItemB != null && param1.ItemRAdd != null && param1.ItemGAdd != null && param1.ItemBAdd != null;
         if(HasColor)
         {
            ItemR = ASCompat.toNumberField(param1, "ItemR");
            ItemG = ASCompat.toNumberField(param1, "ItemG");
            ItemB = ASCompat.toNumberField(param1, "ItemB");
            ItemRAdd = ASCompat.toNumberField(param1, "ItemRAdd");
            ItemGAdd = ASCompat.toNumberField(param1, "ItemGAdd");
            ItemBAdd = ASCompat.toNumberField(param1, "ItemBAdd");
         }
         HasGlow = param1.GlowDist != null && param1.GlowStr != null && param1.GlowColor != null;
         if(HasGlow)
         {
            GlowDist = ASCompat.toNumberField(param1, "GlowDist");
            GlowStr = ASCompat.toNumberField(param1, "GlowStr");
            GlowColor = (ASCompat.toInt(param1.GlowColor) : UInt);
         }
         HasTrailColor = param1.TrailR != null && param1.TrailG != null && param1.TrailB != null && param1.TrailRAdd != null && param1.TrailGAdd != null && param1.TrailBAdd != null;
         if(HasTrailColor)
         {
            TrailR = ASCompat.toNumberField(param1, "TrailR");
            TrailG = ASCompat.toNumberField(param1, "TrailG");
            TrailB = ASCompat.toNumberField(param1, "TrailB");
            TrailRAdd = ASCompat.toNumberField(param1, "TrailRAdd");
            TrailGAdd = ASCompat.toNumberField(param1, "TrailGAdd");
            TrailBAdd = ASCompat.toNumberField(param1, "TrailBAdd");
         }
         Description = param1.Description;
         IsLegendary = ASCompat.toBool(param1.IsLegendary);
      }
   }


