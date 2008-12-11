package vdom.components.treeEditor
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.containers.Canvas;
	
	import vdom.components.treeEditor.colorMenu02.Levels;

	public class Vector2 extends Canvas
	{
	//	public var color:String;
		private var _numColor:Number;
	//	private var _strColor:String;
		private var _mark:Boolean = false;
		private var fromObj:Object;
		private var toObj:Object;
		
		public function Vector2()
		{
			super();
		}
		
		public function createVector (fromObj:Object,  toObj:Object = null, color:Object = 0, _alpha:Number = 1):void
		{
			color = Number(color);
			this.fromObj = fromObj;
			this.toObj = toObj;
//			if( color!= 0)
				_numColor = levcColor.getColor(color);
			calculatePoints();
			
			
			drawLine(_alpha);
			
			
		}
		
		private var levcColor:Levels = new Levels();
		public function set color(level:String):void
		{
			var levcColor:Levels = new Levels();
	//		_strColor = level;
			_numColor = levcColor.getColor(level);
			
		}
		public function set mark(bl:Boolean):void
		{
			_mark = bl;	
			drawLine();
		}
		/*
		public function get color():String
		{
			return _strColor;
		}
		*/
		public var middleX:Number;
		public var middleY:Number;
		
		private function drawLine(_alpha:Number = 1):void
		{/*
			graphics.clear();
			
			graphics.lineStyle(1, 0.5, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			
			graphics.moveTo(nLeft, nTop);
			graphics.lineTo(nRight, nBottom);*/
			
			var x0:Number = nLeft;
			var y0:Number = nTop;
			var x1:Number = nRight;
			var y1:Number = nBottom;
			var dX:Number;
			var dY:Number;
			var alf:Number;
			var dA:Number = 0.2;
			var dDist:Number = 10;
//			 trace(x0+' : '+ y0+' : '+  x1+' : '+  y1);
			dX = x0-x1;
			dY = y0-y1; 
			
			
			if(!dX && !dY)		return;
			var dist:Number = dX*dX + dY*dY;
//			trace(dist);
			if( dist < 55)
				return;
			middleX = x0 - dX / 2;
			middleY = y0 - dY / 2;
			
			dispatchEvent(new Event
			(Event.CHANGE));
//			dispatchEvent(new Event(Event.CHANGE));

			
			alf = Math.atan(dY/dX);
			if (dX<0) alf+=Math.PI;
			
			
			var btX:Number = x0 - dX/2;
			var btY:Number = y0 - dY/2;
		//	trace('Draw Line: '+ btX );
			this.graphics.clear();
			
			this.graphics.lineStyle(8, _numColor, 0, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			
			this.graphics.moveTo(x0, y0);
			this.graphics.lineTo(x1, y1);
			
			if (_mark)
			{
				this.graphics.lineStyle(10, _numColor, .1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
				this.graphics.moveTo(x0, y0);
				this.graphics.lineTo(x1, y1);
				
				this.graphics.lineTo(x1 + Math.cos(alf+dA)*dDist, y1 + Math.sin(alf+dA)*dDist );
				this.graphics.lineTo(x1 + Math.cos(alf-dA)*dDist, y1 + Math.sin(alf-dA)*dDist);
				this.graphics.lineTo(x1,y1);
				
				
				
				this.graphics.lineStyle(3, _numColor, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
				this.graphics.moveTo(x0, y0);
				this.graphics.lineTo(x1, y1);
				
				this.graphics.lineStyle(3, 0x000000, .4, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
				this.graphics.moveTo(x0, y0);
				this.graphics.lineTo(x1, y1);
				
				this.graphics.lineStyle(1, _numColor, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
				
				this.graphics.moveTo(x0, y0);
				this.graphics.lineTo(x1, y1);
				
			//	this.graphics.beginFill(_numColor);
				
				this.graphics.lineStyle(3, _numColor, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
				this.graphics.lineTo(x1 + Math.cos(alf+dA)*dDist, y1 + Math.sin(alf+dA)*dDist );
				this.graphics.lineTo(x1 + Math.cos(alf-dA)*dDist, y1 + Math.sin(alf-dA)*dDist);
				this.graphics.lineTo(x1,y1);
				
			}else
			{
				
				this.graphics.lineStyle(3, _numColor, 1*_alpha, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
				this.graphics.moveTo(x0, y0);
				this.graphics.lineTo(x1, y1);
				
				this.graphics.lineStyle(3, 0x000000, .4*_alpha, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
				this.graphics.moveTo(x0, y0);
				this.graphics.lineTo(x1, y1);
				
				this.graphics.lineStyle(1, _numColor, 1*_alpha, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
				
				this.graphics.moveTo(x0, y0);
				this.graphics.lineTo(x1, y1);
				
			//	this.graphics.beginFill(_numColor);
				
				this.graphics.lineStyle(3, _numColor, _alpha, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
				this.graphics.lineTo(x1 + Math.cos(alf+dA)*dDist, y1 + Math.sin(alf+dA)*dDist );
				this.graphics.lineTo(x1 + Math.cos(alf-dA)*dDist, y1 + Math.sin(alf-dA)*dDist);
				this.graphics.lineTo(x1,y1);
			//this.graphics.endFill();
			}
			
		}
		//private var arrPolygon:Array;
	
		private var nLeft	:Number;   
		private var nRight	:Number;
		private var nTop	:Number;
		private var nBottom	:Number;
		
		private function calculatePoints( ):void
		{
			nLeft = 0;
			nRight = 0;
			nTop = 0;
			nBottom = 0;
			
			var _pFromObj:Point;
			var _pToObj:Point;
			var pFromObj:Point;
			var pToObj:Point;
			var pArrow1:Point;
			var pArrow2:Point;
			
    		var fromObjWidth:Number = 0;
    		var fromObjHeight:Number = 0;
    		var fromObjHalfWidth:Number = 0;
    		var fromObjHalfHeight:Number = 0;

   			var toObjWidth:Number = 0;
   			var toObjHeight:Number = 0;			
   			var toObjHalfWidth:Number = 0;
   			var toObjHalfHeight:Number = 0;	
   						
			var fromObjVertCross:Boolean = false;
			var toObjVertCross:Boolean = false;
			
			if(fromObj)
			{
				/**
				 * Calculates fromObject center coordinates   
				 */			
    			fromObjWidth = fromObj.width;
    			fromObjHeight = fromObj.height;
    			fromObjHalfWidth = fromObjWidth/2;
    			fromObjHalfHeight = fromObjHeight/2;
    						 	
				_pFromObj = new Point( 
					fromObj.x+fromObjHalfWidth, 
					fromObj.y+fromObjHalfHeight );
   			}
   			   			
   			if(toObj)
   			{
				/**
				 * Calculates toObject center coordinates   
				 */	
   				toObjWidth = toObj.width;
   				toObjHeight = toObj.height;	
   				if(toObjWidth )	
   				{
	   				toObjHalfWidth = toObjWidth/2;
	   				toObjHalfHeight = toObjHeight/2;					 				 
	   				
					_pToObj = new Point( 
						toObj.x+toObjHalfWidth,
	   					toObj.y+toObjHalfHeight );
	   			} else
	   			{
					_pToObj = new Point( 
			   			toObj.x,
			   			toObj.y );
				}
   			}
   			
			if(_pFromObj)
				pFromObj = new Point( _pFromObj.x, _pFromObj.y );
			if(_pToObj)
				pToObj = new Point( _pToObj.x, _pToObj.y );
			
			if(fromObj)
			{
				var arrowWidth:Number = Math.abs( pToObj.x - pFromObj.x );
    			var arrowHeight:Number = Math.abs( pToObj.y - pFromObj.y );				

    			var koef:Number = arrowWidth/arrowHeight;
    			var fromObjKoef:Number = fromObjWidth/fromObjHeight;

    			var toObjKoef:Number = 0;
	   			if(toObjWidth)//---
   				{
	    			toObjKoef = toObjWidth/toObjHeight;
    			}
				
				/**
				 * If objects overlay each other then return from function 
				 */				 
				if(arrowWidth<=fromObjHalfWidth+toObjHalfWidth && arrowHeight<=fromObjHalfHeight+toObjHalfHeight)
   					return;  					

				var dX:Number = 0;
				var dY:Number = 0;
				
				/**
				 * If koef > fromObjKoef then arrow crosses vertical border of fromObject else - horisontal
				 */
   				if( koef > fromObjKoef )
    				fromObjVertCross = true;

				/**
				 * Calculates delta X and delta Y for arrow start point
				 */
				if(fromObjVertCross)
				{
					dX = fromObjHalfWidth;
					dY = dX/koef;
				}
				else
				{
					dY = fromObjHalfHeight;
					dX = dY*koef;
				}  
				
				if( pFromObj.x < pToObj.x ) 	{ nLeft = pFromObj.x+=dX+5; }
   				else 							{ nLeft = pFromObj.x-=dX+5; }    					
					
   				if( pFromObj.y < pToObj.y ) 	{nTop = pFromObj.y+=dY+5; }    					
   				else							{nTop = pFromObj.y-=dY+5; }

    			if(toObj)
   				{	    			
	   				if( koef > toObjKoef )
	    				toObjVertCross = true;
					/**
					 * Calculates delta X and delta Y for arrow end point
					 */	 
					if(toObjVertCross)
					{
						dX = toObjHalfWidth;
						dY = dX/koef;
					}
					else
					{
						dY = toObjHalfHeight;
						dX = dY*koef;
					}  
					
					if( pFromObj.x < pToObj.x ) 	{nRight =  pToObj.x-=dX+5; }
	   				else 							{nRight =  pToObj.x+=dX+5; }    					
						
	   				if( pFromObj.y < pToObj.y ) 	{nBottom =  pToObj.y-=dY+5; }    					
	   				else							{nBottom =  pToObj.y+=dY+5; }					    				
    			}	
				else
				{
					nLeft = parent.mouseX;
					nRight = parent.mouseX;
					nTop = parent.mouseY;
					nBottom = parent.mouseY;
				}
			}
		}
		
		public function clear():void
		{
			graphics.clear();
			this.fromObj = null;
			this.toObj = null;
		}
			
		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}