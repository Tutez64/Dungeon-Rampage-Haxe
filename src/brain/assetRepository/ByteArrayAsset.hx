package brain.assetRepository
;
   import flash.utils.ByteArray;
   
    class ByteArrayAsset extends Asset
   {
      
      var mByteArray:ByteArray;
      
      public function new(param1:ByteArray)
      {
         super();
         mByteArray = param1;
      }
      
      @:isVar public var byteArray(get,never):ByteArray;
public function  get_byteArray() : ByteArray
      {
         return mByteArray;
      }
      
      override public function destroy() 
      {
         mByteArray = null;
         super.destroy();
      }
   }


