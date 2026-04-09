package box2D.dynamics
;
   import box2D.collision.*;
   import box2D.collision.shapes.*;
   import box2D.common.*;
   import box2D.common.math.*;
   import box2D.dynamics.contacts.*;
   import flash.display.Sprite;
   
   /*use*/ /*namespace*/ /*b2internal*/
   
    class B2DebugDraw
   {
      
      public static var e_shapeBit:UInt = (1 : UInt);
      
      public static var e_jointBit:UInt = (2 : UInt);
      
      public static var e_aabbBit:UInt = (4 : UInt);
      
      public static var e_pairBit:UInt = (8 : UInt);
      
      public static var e_centerOfMassBit:UInt = (16 : UInt);
      
      public static var e_controllerBit:UInt = (32 : UInt);
      
      var m_drawFlags:UInt = 0;
      
      /*b2internal*/ public var m_sprite:Sprite;
      
      var m_drawScale:Float = 1;
      
      var m_lineThickness:Float = 1;
      
      var m_alpha:Float = 1;
      
      var m_fillAlpha:Float = 1;
      
      var m_xformScale:Float = 1;
      
      public function new()
      {
         
         this.m_drawFlags = (0 : UInt);
      }
      
      public function SetFlags(param1:UInt) 
      {
         this.m_drawFlags = param1;
      }
      
      public function GetFlags() : UInt
      {
         return this.m_drawFlags;
      }
      
      public function AppendFlags(param1:UInt) 
      {
         this.m_drawFlags = ((this.m_drawFlags | param1 : UInt) : UInt);
      }
      
      public function ClearFlags(param1:UInt) 
      {
         this.m_drawFlags = ((this.m_drawFlags & (~(param1 : Int) : UInt) : UInt) : UInt);
      }
      
      public function SetSprite(param1:Sprite) 
      {
         this/*b2internal::*/.m_sprite = param1;
      }
      
      public function GetSprite() : Sprite
      {
         return this/*b2internal::*/.m_sprite;
      }
      
      public function SetDrawScale(param1:Float) 
      {
         this.m_drawScale = param1;
      }
      
      public function GetDrawScale() : Float
      {
         return this.m_drawScale;
      }
      
      public function SetLineThickness(param1:Float) 
      {
         this.m_lineThickness = param1;
      }
      
      public function GetLineThickness() : Float
      {
         return this.m_lineThickness;
      }
      
      public function SetAlpha(param1:Float) 
      {
         this.m_alpha = param1;
      }
      
      public function GetAlpha() : Float
      {
         return this.m_alpha;
      }
      
      public function SetFillAlpha(param1:Float) 
      {
         this.m_fillAlpha = param1;
      }
      
      public function GetFillAlpha() : Float
      {
         return this.m_fillAlpha;
      }
      
      public function SetXFormScale(param1:Float) 
      {
         this.m_xformScale = param1;
      }
      
      public function GetXFormScale() : Float
      {
         return this.m_xformScale;
      }
      
      public function DrawPolygon(param1:Array<ASAny>, param2:Int, param3:B2Color) 
      {
         this/*b2internal::*/.m_sprite.graphics.lineStyle(this.m_lineThickness,param3.color,this.m_alpha);
         this/*b2internal::*/.m_sprite.graphics.moveTo(ASCompat.toNumber(ASCompat.toNumberField(param1[0], "x") * this.m_drawScale),ASCompat.toNumber(ASCompat.toNumberField(param1[0], "y") * this.m_drawScale));
         var _loc4_= 1;
         while(_loc4_ < param2)
         {
            this/*b2internal::*/.m_sprite.graphics.lineTo(ASCompat.toNumber(ASCompat.toNumberField(param1[_loc4_], "x") * this.m_drawScale),ASCompat.toNumber(ASCompat.toNumberField(param1[_loc4_], "y") * this.m_drawScale));
            _loc4_++;
         }
         this/*b2internal::*/.m_sprite.graphics.lineTo(ASCompat.toNumber(ASCompat.toNumberField(param1[0], "x") * this.m_drawScale),ASCompat.toNumber(ASCompat.toNumberField(param1[0], "y") * this.m_drawScale));
      }
      
      public function DrawSolidPolygon(param1:Vector<B2Vec2>, param2:Int, param3:B2Color) 
      {
         this/*b2internal::*/.m_sprite.graphics.lineStyle(this.m_lineThickness,param3.color,this.m_alpha);
         this/*b2internal::*/.m_sprite.graphics.moveTo(param1[0].x * this.m_drawScale,param1[0].y * this.m_drawScale);
         this/*b2internal::*/.m_sprite.graphics.beginFill(param3.color,this.m_fillAlpha);
         var _loc4_= 1;
         while(_loc4_ < param2)
         {
            this/*b2internal::*/.m_sprite.graphics.lineTo(param1[_loc4_].x * this.m_drawScale,param1[_loc4_].y * this.m_drawScale);
            _loc4_++;
         }
         this/*b2internal::*/.m_sprite.graphics.lineTo(param1[0].x * this.m_drawScale,param1[0].y * this.m_drawScale);
         this/*b2internal::*/.m_sprite.graphics.endFill();
      }
      
      public function DrawCircle(param1:B2Vec2, param2:Float, param3:B2Color) 
      {
         this/*b2internal::*/.m_sprite.graphics.lineStyle(this.m_lineThickness,param3.color,this.m_alpha);
         this/*b2internal::*/.m_sprite.graphics.drawCircle(param1.x * this.m_drawScale,param1.y * this.m_drawScale,param2 * this.m_drawScale);
      }
      
      public function DrawSolidCircle(param1:B2Vec2, param2:Float, param3:B2Vec2, param4:B2Color) 
      {
         this/*b2internal::*/.m_sprite.graphics.lineStyle(this.m_lineThickness,param4.color,this.m_alpha);
         this/*b2internal::*/.m_sprite.graphics.moveTo(0,0);
         this/*b2internal::*/.m_sprite.graphics.beginFill(param4.color,this.m_fillAlpha);
         this/*b2internal::*/.m_sprite.graphics.drawCircle(param1.x * this.m_drawScale,param1.y * this.m_drawScale,param2 * this.m_drawScale);
         this/*b2internal::*/.m_sprite.graphics.endFill();
         this/*b2internal::*/.m_sprite.graphics.moveTo(param1.x * this.m_drawScale,param1.y * this.m_drawScale);
         this/*b2internal::*/.m_sprite.graphics.lineTo((param1.x + param3.x * param2) * this.m_drawScale,(param1.y + param3.y * param2) * this.m_drawScale);
      }
      
      public function DrawSegment(param1:B2Vec2, param2:B2Vec2, param3:B2Color) 
      {
         this/*b2internal::*/.m_sprite.graphics.lineStyle(this.m_lineThickness,param3.color,this.m_alpha);
         this/*b2internal::*/.m_sprite.graphics.moveTo(param1.x * this.m_drawScale,param1.y * this.m_drawScale);
         this/*b2internal::*/.m_sprite.graphics.lineTo(param2.x * this.m_drawScale,param2.y * this.m_drawScale);
      }
      
      public function DrawTransform(param1:B2Transform) 
      {
         this/*b2internal::*/.m_sprite.graphics.lineStyle(this.m_lineThickness,(16711680 : UInt),this.m_alpha);
         this/*b2internal::*/.m_sprite.graphics.moveTo(param1.position.x * this.m_drawScale,param1.position.y * this.m_drawScale);
         this/*b2internal::*/.m_sprite.graphics.lineTo((param1.position.x + this.m_xformScale * param1.R.col1.x) * this.m_drawScale,(param1.position.y + this.m_xformScale * param1.R.col1.y) * this.m_drawScale);
         this/*b2internal::*/.m_sprite.graphics.lineStyle(this.m_lineThickness,(65280 : UInt),this.m_alpha);
         this/*b2internal::*/.m_sprite.graphics.moveTo(param1.position.x * this.m_drawScale,param1.position.y * this.m_drawScale);
         this/*b2internal::*/.m_sprite.graphics.lineTo((param1.position.x + this.m_xformScale * param1.R.col2.x) * this.m_drawScale,(param1.position.y + this.m_xformScale * param1.R.col2.y) * this.m_drawScale);
      }
   }


