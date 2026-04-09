package com.junkbyte.console.view
;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.ui.Mouse;
   
    class Ruler extends Sprite
   {
      
      var _master:Console;
      
      var _config:ConsoleConfig;
      
      var _area:Rectangle;
      
      var _pointer:Shape;
      
      var _posTxt:TextField;
      
      var _zoom:Bitmap;
      
      var _points:Array<ASAny>;
      
      public function new(param1:Console)
      {
         super();
         this._master = param1;
         this._config = param1.config;
         buttonMode = true;
         this._points = new Array<ASAny>();
         this._pointer = new Shape();
         addChild(this._pointer);
         var _loc2_= new Point();
         _loc2_ = globalToLocal(_loc2_);
         this._area = new Rectangle(-param1.stage.stageWidth * 1.5 + _loc2_.x,-param1.stage.stageHeight * 1.5 + _loc2_.y,param1.stage.stageWidth * 3,param1.stage.stageHeight * 3);
         graphics.beginFill(this._config.style.backgroundColor,0.2);
         graphics.drawRect(this._area.x,this._area.y,this._area.width,this._area.height);
         graphics.endFill();
         this._posTxt = this._master.panels.mainPanel.makeTF("positionText",true);
         this._posTxt.autoSize = TextFieldAutoSize.LEFT;
         addChild(this._posTxt);
         this._zoom = new Bitmap();
         this._zoom.scaleY = this._zoom.scaleX = 2;
         addChild(this._zoom);
         addEventListener(MouseEvent.CLICK,this.onMouseClick,false,0,true);
         addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove,false,0,true);
         this.onMouseMove();
         if(this._config.rulerHidesMouse)
         {
            Mouse.hide();
         }
         this._master.report("<b>Ruler started. Click on two locations to measure.</b>",-1);
      }
      
      function onMouseMove(param1:MouseEvent = null) 
      {
         var bmd:BitmapData;
         var d:Int;
         var m:Matrix = null;
         var e= param1;
         this._pointer.graphics.clear();
         this._pointer.graphics.lineStyle(1,(11193344 : UInt),1);
         this._pointer.graphics.moveTo(this._area.x,mouseY);
         this._pointer.graphics.lineTo(this._area.x + this._area.width,mouseY);
         this._pointer.graphics.moveTo(mouseX,this._area.y);
         this._pointer.graphics.lineTo(mouseX,this._area.y + this._area.height);
         this._pointer.blendMode = BlendMode.INVERT;
         this._posTxt.text = "<low>" + mouseX + "," + mouseY + "</low>";
         bmd = new BitmapData(30,30);
         try
         {
            m = new Matrix();
            m.tx = -stage.mouseX + 15;
            m.ty = -stage.mouseY + 15;
            bmd.draw(stage,m);
         }
         catch(err:Dynamic)
         {
            bmd = null;
         }
         this._zoom.bitmapData = bmd;
         d = 10;
         this._posTxt.x = mouseX - this._posTxt.width - d;
         this._posTxt.y = mouseY - this._posTxt.height - d;
         this._zoom.x = this._posTxt.x + this._posTxt.width - this._zoom.width;
         this._zoom.y = this._posTxt.y - this._zoom.height;
         if(this._posTxt.x < 16)
         {
            this._posTxt.x = mouseX + d;
            this._zoom.x = this._posTxt.x;
         }
         if(this._posTxt.y < 38)
         {
            this._posTxt.y = mouseY + d;
            this._zoom.y = this._posTxt.y + this._posTxt.height;
         }
      }
      
      function onMouseClick(param1:MouseEvent) 
      {
         var _loc2_:Point = null;
         var _loc4_:Point = null;
         var _loc5_:Point = null;
         var _loc6_:Point = null;
         var _loc7_:Point = null;
         var _loc8_:Point = null;
         var _loc9_:Point = null;
         var _loc10_= Math.NaN;
         var _loc11_= Math.NaN;
         var _loc12_= Math.NaN;
         var _loc13_:TextField = null;
         var _loc14_= Math.NaN;
         var _loc15_= Math.NaN;
         param1.stopPropagation();
         var _loc3_= this._config.style;
         if(this._points.length == 0)
         {
            _loc2_ = new Point(param1.localX,param1.localY);
            graphics.lineStyle(1,(16711680 : UInt));
            graphics.drawCircle(_loc2_.x,_loc2_.y,3);
            this._points.push(_loc2_);
         }
         else if(this._points.length == 1)
         {
            this._zoom.bitmapData = null;
            if(this._config.rulerHidesMouse)
            {
               Mouse.show();
            }
            removeChild(this._pointer);
            removeChild(this._posTxt);
            removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMove);
            _loc2_ = ASCompat.dynamicAs(this._points[0], flash.geom.Point);
            _loc4_ = new Point(param1.localX,param1.localY);
            this._points.push(_loc4_);
            graphics.clear();
            graphics.beginFill(_loc3_.backgroundColor,0.4);
            graphics.drawRect(this._area.x,this._area.y,this._area.width,this._area.height);
            graphics.endFill();
            graphics.lineStyle(1.5,(16711680 : UInt));
            graphics.drawCircle(_loc2_.x,_loc2_.y,4);
            graphics.lineStyle(1.5,(16750848 : UInt));
            graphics.drawCircle(_loc4_.x,_loc4_.y,4);
            _loc5_ = Point.interpolate(_loc2_,_loc4_,0.5);
            graphics.lineStyle(1,(11184810 : UInt));
            graphics.drawCircle(_loc5_.x,_loc5_.y,4);
            _loc6_ = _loc2_;
            _loc7_ = _loc4_;
            if(_loc2_.x > _loc4_.x)
            {
               _loc6_ = _loc4_;
               _loc7_ = _loc2_;
            }
            _loc8_ = _loc2_;
            _loc9_ = _loc4_;
            if(_loc2_.y > _loc4_.y)
            {
               _loc8_ = _loc4_;
               _loc9_ = _loc2_;
            }
            _loc10_ = _loc7_.x - _loc6_.x;
            _loc11_ = _loc9_.y - _loc8_.y;
            _loc12_ = Point.distance(_loc2_,_loc4_);
            _loc13_ = this.makeTxtField(_loc3_.highColor);
            _loc13_.text = this.round(_loc2_.x) + "," + this.round(_loc2_.y);
            _loc13_.x = _loc2_.x;
            _loc13_.y = _loc2_.y - (_loc8_ == _loc2_ ? 14 : 0);
            addChild(_loc13_);
            _loc13_ = this.makeTxtField(_loc3_.highColor);
            _loc13_.text = this.round(_loc4_.x) + "," + this.round(_loc4_.y);
            _loc13_.x = _loc4_.x;
            _loc13_.y = _loc4_.y - (_loc8_ == _loc4_ ? 14 : 0);
            addChild(_loc13_);
            if(_loc10_ > 40 || _loc11_ > 25)
            {
               _loc13_ = this.makeTxtField(_loc3_.lowColor);
               _loc13_.text = this.round(_loc5_.x) + "," + this.round(_loc5_.y);
               _loc13_.x = _loc5_.x;
               _loc13_.y = _loc5_.y;
               addChild(_loc13_);
            }
            graphics.lineStyle(1,(11193344 : UInt),0.5);
            graphics.moveTo(this._area.x,_loc8_.y);
            graphics.lineTo(this._area.x + this._area.width,_loc8_.y);
            graphics.moveTo(this._area.x,_loc9_.y);
            graphics.lineTo(this._area.x + this._area.width,_loc9_.y);
            graphics.moveTo(_loc6_.x,this._area.y);
            graphics.lineTo(_loc6_.x,this._area.y + this._area.height);
            graphics.moveTo(_loc7_.x,this._area.y);
            graphics.lineTo(_loc7_.x,this._area.y + this._area.height);
            _loc14_ = this.round(this.angle(_loc2_,_loc4_),(100 : UInt));
            _loc15_ = this.round(this.angle(_loc4_,_loc2_),(100 : UInt));
            graphics.lineStyle(1,(11141120 : UInt),0.8);
            this.drawCircleSegment(graphics,10,_loc2_,_loc14_,-90);
            graphics.lineStyle(1,(13404160 : UInt),0.8);
            this.drawCircleSegment(graphics,10,_loc4_,_loc15_,-90);
            graphics.lineStyle(2,(65280 : UInt),0.7);
            graphics.moveTo(_loc2_.x,_loc2_.y);
            graphics.lineTo(_loc4_.x,_loc4_.y);
            this._master.report("Ruler results: (red) <b>[" + _loc2_.x + "," + _loc2_.y + "]</b> to (orange) <b>[" + _loc4_.x + "," + _loc4_.y + "]</b>",-2);
            this._master.report("Distance: <b>" + this.round(_loc12_,(100 : UInt)) + "</b>",-2);
            this._master.report("Mid point: <b>[" + _loc5_.x + "," + _loc5_.y + "]</b>",-2);
            this._master.report("Width:<b>" + _loc10_ + "</b>, Height: <b>" + _loc11_ + "</b>",-2);
            this._master.report("Angle from first point (red): <b>" + _loc14_ + "°</b>",-2);
            this._master.report("Angle from second point (orange): <b>" + _loc15_ + "°</b>",-2);
         }
         else
         {
            this.exit();
         }
      }
      
      public function exit() 
      {
         this._master = null;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      function makeTxtField(param1:Float, param2:Bool = true) : TextField
      {
         var _loc3_= new TextFormat(this._config.style.menuFont,this._config.style.menuFontSize,ASCompat.toInt(param1),param2,true,null,null,TextFormatAlign.RIGHT);
         var _loc4_= new TextField();
         _loc4_.autoSize = TextFieldAutoSize.RIGHT;
         _loc4_.selectable = false;
         _loc4_.defaultTextFormat = _loc3_;
         return _loc4_;
      }
      
      function round(param1:Float, param2:UInt = (10 : UInt)) : Float
      {
         return Math.fround(param1 * param2) / param2;
      }
      
      function angle(param1:Point, param2:Point) : Float
      {
         var _loc3_= Math.atan2(param2.y - param1.y,param2.x - param1.x) / Math.PI * 180;
         _loc3_ += 90;
         if(_loc3_ > 180)
         {
            _loc3_ -= 360;
         }
         return _loc3_;
      }
      
      function drawCircleSegment(param1:Graphics, param2:Float, param3:Point, param4:Float = 180, param5:Float = 0) : Point
      {
         var _loc12_= Math.NaN;
         var _loc13_= Math.NaN;
         var _loc14_= Math.NaN;
         var _loc15_:Point = null;
         var _loc6_= false;
         if(param4 < 0)
         {
            _loc6_ = true;
            param4 = Math.abs(param4);
         }
         var _loc7_= param4 * Math.PI / 180;
         var _loc8_= param5 * Math.PI / 180;
         var _loc9_= this.getPointOnCircle(param2,_loc8_);
         _loc9_.offset(param3.x,param3.y);
         param1.moveTo(_loc9_.x,_loc9_.y);
         var _loc10_:Float = 0;
         var _loc11_= 1;
         while(_loc11_ <= _loc7_ + 1)
         {
            _loc12_ = _loc11_ <= _loc7_ ? _loc11_ : _loc7_;
            _loc13_ = _loc12_ - _loc10_;
            _loc14_ = 1 + 0.12 * _loc13_ * _loc13_;
            _loc15_ = this.getPointOnCircle(param2 * _loc14_,(_loc12_ - _loc13_ / 2) * (_loc6_ ? -1 : 1) + _loc8_);
            _loc15_.offset(param3.x,param3.y);
            _loc9_ = this.getPointOnCircle(param2,_loc12_ * (_loc6_ ? -1 : 1) + _loc8_);
            _loc9_.offset(param3.x,param3.y);
            param1.curveTo(_loc15_.x,_loc15_.y,_loc9_.x,_loc9_.y);
            _loc10_ = _loc12_;
            _loc11_++;
         }
         return _loc9_;
      }
      
      function getPointOnCircle(param1:Float, param2:Float) : Point
      {
         return new Point(param1 * Math.cos(param2),param1 * Math.sin(param2));
      }
   }


