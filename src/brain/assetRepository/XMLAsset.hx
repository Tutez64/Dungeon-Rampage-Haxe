package brain.assetRepository
;
    class XMLAsset extends Asset
   {
      
      var mXML:compat.XML;
      
      public function new(param1:compat.XML)
      {
         super();
         mXML = param1;
      }
      
      @:isVar public var xml(get,never):compat.XML;
public function  get_xml() : compat.XML
      {
         return mXML;
      }
      
      override public function destroy() 
      {
         mXML = null;
         super.destroy();
      }
   }


