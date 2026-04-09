package box2D.collision
;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class Features
   {
      
      /*b2internal*/ public var _referenceEdge:Int = 0;
      
      /*b2internal*/ public var _incidentEdge:Int = 0;
      
      /*b2internal*/ public var _incidentVertex:Int = 0;
      
      /*b2internal*/ public var _flip:Int = 0;
      
      /*b2internal*/ public var _m_id:B2ContactID;
      
      public function new()
      {
         
      }
      
            
      @:isVar public var referenceEdge(get,set):Int;
public function  get_referenceEdge() : Int
      {
         return this/*b2internal::*/._referenceEdge;
      }
function  set_referenceEdge(param1:Int) :Int      {
         this/*b2internal::*/._referenceEdge = param1;
         this/*b2internal::*/._m_id/*b2internal::*/._key = ((this/*b2internal::*/._m_id/*b2internal::*/._key : Int) & Std.int(0xFFFFFF00) | this/*b2internal::*/._referenceEdge & 0xFF : UInt);
return param1;
      }
      
            
      @:isVar public var incidentEdge(get,set):Int;
public function  get_incidentEdge() : Int
      {
         return this/*b2internal::*/._incidentEdge;
      }
function  set_incidentEdge(param1:Int) :Int      {
         this/*b2internal::*/._incidentEdge = param1;
         this/*b2internal::*/._m_id/*b2internal::*/._key = ((this/*b2internal::*/._m_id/*b2internal::*/._key : Int) & Std.int(0xFFFF00FF) | this/*b2internal::*/._incidentEdge << 8 & 0xFF00 : UInt);
return param1;
      }
      
            
      @:isVar public var incidentVertex(get,set):Int;
public function  get_incidentVertex() : Int
      {
         return this/*b2internal::*/._incidentVertex;
      }
function  set_incidentVertex(param1:Int) :Int      {
         this/*b2internal::*/._incidentVertex = param1;
         this/*b2internal::*/._m_id/*b2internal::*/._key = ((this/*b2internal::*/._m_id/*b2internal::*/._key : Int) & Std.int(0xFF00FFFF) | this/*b2internal::*/._incidentVertex << 16 & 0xFF0000 : UInt);
return param1;
      }
      
            
      @:isVar public var flip(get,set):Int;
public function  get_flip() : Int
      {
         return this/*b2internal::*/._flip;
      }
function  set_flip(param1:Int) :Int      {
         this/*b2internal::*/._flip = param1;
         this/*b2internal::*/._m_id/*b2internal::*/._key = ((this/*b2internal::*/._m_id/*b2internal::*/._key : Int) & 0xFFFFFF | this/*b2internal::*/._flip << 24 & Std.int(0xFF000000) : UInt);
return param1;
      }
   }


