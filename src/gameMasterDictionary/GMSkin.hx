package gameMasterDictionary
;
    class GMSkin extends GMItem
   {
      
      public var ForHero:String;
      
      public var AssetType:String;
      
      public var SpriteWidth:UInt = 0;
      
      public var SpriteHeight:UInt = 0;
      
      public var AssetClassName:String;
      
      public var PortraitName:String;
      
      public var IconSwfFilepath:String;
      
      public var IconName:String;
      
      public var CardName:String;
      
      public var SwfFilepath:String;
      
      public var UISwfFilepath:String;
      
      public var FeedPostPicture:String;
      
      public var Scale:Float = Math.NaN;
      
      public var NametagY:Float = Math.NaN;
      
      public var HealthbarScale:Float = Math.NaN;
      
      public var ProjEmitOffset:Float = Math.NaN;
      
      public var Hue:Float = Math.NaN;
      
      public var Saturation:Float = Math.NaN;
      
      public var Brightness:Float = Math.NaN;
      
      public var HitVol:Float = Math.NaN;
      
      public var HitSound:String;
      
      public var DeathVol:Float = Math.NaN;
      
      public var DeathSound:String;
      
      public var CharNickname:String;
      
      public var CharLikes:String;
      
      public var CharDislikes:String;
      
      public var CharUnlockLocation:String;
      
      public var Description:String;
      
      public var StoreDescription:String;
      
      public var specialFXSwfPath_Back:String;
      
      public var specialFXName_Back:String;
      
      public var specialFXSwfPath_Front:String;
      
      public var specialFXName_Front:String;
      
      public function new(param1:ASObject)
      {
         super(param1);
         ForHero = ASCompat.asString(param1.ForHero );
         AssetType = ASCompat.asString(param1.AssetType );
         SpriteWidth = ASCompat.asUint(param1.SpriteWidth );
         SpriteHeight = ASCompat.asUint(param1.SpriteHeight );
         AssetClassName = ASCompat.asString(param1.AssetClassName );
         PortraitName = ASCompat.asString(param1.PortraitName );
         IconSwfFilepath = ASCompat.asString(param1.IconSwfFilepath );
         IconName = ASCompat.asString(param1.IconName );
         CardName = ASCompat.asString(param1.CardName );
         SwfFilepath = ASCompat.asString(param1.SwfFilepath );
         UISwfFilepath = ASCompat.asString(param1.UISwfFilepath );
         FeedPostPicture = param1.FeedPostPicture;
         Scale = ASCompat.asNumber(param1.Scale );
         NametagY = ASCompat.asNumber(param1.NametagY );
         HealthbarScale = ASCompat.asNumber(param1.HealthbarScale );
         ProjEmitOffset = ASCompat.asNumber(param1.ProjEmitOffset );
         Hue = ASCompat.toNumberField(param1, "Hue");
         Saturation = ASCompat.toBool(param1.Saturation) ? ASCompat.toNumber(100 + param1.Saturation) / 100 * 2 : 0;
         Brightness = ASCompat.toNumberField(param1, "Brightness");
         HitVol = ASCompat.asNumber(param1.HitVol );
         HitSound = ASCompat.asString(param1.HitSound );
         DeathVol = ASCompat.asNumber(param1.DeathVol );
         DeathSound = ASCompat.asString(param1.DeathSound );
         CharNickname = ASCompat.asString(param1.CharNickname );
         CharLikes = ASCompat.asString(param1.CharLikes );
         CharDislikes = ASCompat.asString(param1.CharDislikes );
         CharUnlockLocation = ASCompat.asString(param1.CharUnlockLocation );
         Description = ASCompat.asString(param1.Description );
         StoreDescription = ASCompat.asString(param1.StoreDescription );
         specialFXSwfPath_Back = param1.SpecialFXSwfPath_Back;
         specialFXName_Back = param1.SpecialFXName_Back;
         specialFXSwfPath_Front = param1.SpecialFXSwfPath_Front;
         specialFXName_Front = param1.SpecialFXName_Front;
      }
      
      public function doesSpecialFXBackExist() : Bool
      {
         if(specialFXSwfPath_Back == null || specialFXSwfPath_Back == "")
         {
            return false;
         }
         if(specialFXName_Back == null || specialFXName_Back == "")
         {
            return false;
         }
         return true;
      }
      
      public function doesSpecialFXFrontExist() : Bool
      {
         if(specialFXSwfPath_Front == null || specialFXSwfPath_Front == "")
         {
            return false;
         }
         if(specialFXName_Front == null || specialFXName_Front == "")
         {
            return false;
         }
         return true;
      }
   }


