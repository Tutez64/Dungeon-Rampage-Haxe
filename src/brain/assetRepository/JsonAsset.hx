package brain.assetRepository
;
    class JsonAsset extends Asset
   {
      
      var mJson:ASObject;
      
      public function new(param1:ASObject)
      {
         super();
         mJson = haxe.Json.parse(Std.string(param1));
      }
      
      @:isVar public var json(get,never):ASObject;
public function  get_json() : ASObject
      {
         return mJson;
      }
      
      override public function destroy() 
      {
         mJson = null;
         super.destroy();
      }
   }


