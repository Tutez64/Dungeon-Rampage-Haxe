package brain.assetRepository
;
   import flash.display.Bitmap;
   
    class ImageAsset extends Asset
   {
      
      var mImage:Bitmap;
      
      public function new(param1:Bitmap)
      {
         super();
         mImage = param1;
      }
      
      @:isVar public var image(get,never):Bitmap;
public function  get_image() : Bitmap
      {
         return mImage;
      }
      
      override public function destroy() 
      {
         mImage = null;
         super.destroy();
      }
   }


