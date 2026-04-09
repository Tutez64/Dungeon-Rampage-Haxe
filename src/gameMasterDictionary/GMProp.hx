package gameMasterDictionary
;
    class GMProp extends GMItem
   {
      
      public var PropType:String;
      
      public var AssetClassName:String;
      
      public var SwfFilepath:String;
      
      public var DefaultLayer:String;
      
      public var ArchwayAlpha:Bool = false;
      
      public var TileTheme:String;
      
      public function new(param1:ASObject)
      {
         super(param1);
         PropType = param1.PropType;
         AssetClassName = param1.AssetClassName;
         SwfFilepath = param1.SwfFilepath;
         DefaultLayer = param1.DefaultLayer;
         ArchwayAlpha = param1.ArchwayAlpha == true;
         TileTheme = param1.TileTheme;
      }
   }


