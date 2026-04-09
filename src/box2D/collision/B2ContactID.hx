package box2D.collision
;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2ContactID
   {
      
      public var features:Features = new Features();
      
      /*b2internal*/ public var _key:UInt = 0;
      
      public function new()
      {
         
         this.features/*b2internal::*/._m_id = this;
      }
      
      public function Set(param1:B2ContactID) 
      {
         this.key = param1/*b2internal::*/._key;
      }
      
      public function Copy() : B2ContactID
      {
         var _loc1_= new B2ContactID();
         _loc1_.key = this.key;
         return _loc1_;
      }
      
            
      @:isVar public var key(get,set):UInt;
public function  get_key() : UInt
      {
         return this/*b2internal::*/._key;
      }
function  set_key(param1:UInt) :UInt      {
         this/*b2internal::*/._key = param1;
         this.features/*b2internal::*/._referenceEdge = (this/*b2internal::*/._key : Int) & 0xFF;
         this.features/*b2internal::*/._incidentEdge = ((this/*b2internal::*/._key : Int) & 0xFF00) >> 8 & 0xFF;
         this.features/*b2internal::*/._incidentVertex = ((this/*b2internal::*/._key : Int) & 0xFF0000) >> 16 & 0xFF;
         this.features/*b2internal::*/._flip = ((this/*b2internal::*/._key : Int) & Std.int(0xFF000000)) >> 24 & 0xFF;
return param1;
      }
   }


