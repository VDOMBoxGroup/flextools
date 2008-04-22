package vdom.components.treeEditor
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
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
		
		public function createVector (fromObj:Object,  toObj:Object = null, color:Number = 0):void
		{
			this.fromObj = fromObj;
			this.toObj = toObj;
			if( color!= 0)
			_numColor = color;
			calculatePoints();
			
			
			drawLine();
			
			
		}
		
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
		private function drawLine():void
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
			
			dX = x0-x1;
			dY = y0-y1; 
			alf = Math.atan(dY/dX);
			if (dX<0) alf+=Math.PI;
			
			
			var btX:Number = x0 - dX/2;
			var btY:Number = y0 - dY/2;
		//	trace('Draw Line: '+ btX );
			this.graphics.clear();
			
			this.graphics.lineStyle(8, _numColor, 0, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			
			this.graphics.moveTo(x0, y0);
			this.graphics.lineTo(x1, y1);
			
			this.graphics.lineStyle(2, _numColor, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			
			this.graphics.moveTo(x0, y0);
			this.graphics.lineTo(x1, y1);
			
		//	this.graphics.beginFill(_numColor);
		
			this.graphics.lineTo(x1 + Math.cos(alf+dA)*dDist, y1 + Math.sin(alf+dA)*dDist );
			this.graphics.lineTo(x1 + Math.cos(alf-dA)*dDist, y1 + Math.sin(alf-dA)*dDist);
			this.graphics.lineTo(x1,y1);
			//this.graphics.endFill();
			
			if (_mark)
			{
				this.graphics.lineStyle(5, _numColor, .3, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			
				this.graphics.moveTo(x0, y0);
				this.graphics.lineTo(x1, y1);
			}
		}
		//private var arrPolygon:Array;
	
		private var nLeft	:Number;   
		private var nRight	:Number;
		private var nTop	:Number;
		private var nBottom	:Number;
		
		private function calculatePoints( ):void
		{
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
				
				if( pFromObj.x < pToObj.x ) 	{ nLeft = pFromObj.x+=dX; }
   				else 							{ nLeft = pFromObj.x-=dX; }    					
					
   				if( pFromObj.y < pToObj.y ) 	{nTop = pFromObj.y+=dY; }    					
   				else							{nTop = pFromObj.y-=dY; }

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
					
					if( pFromObj.x < pToObj.x ) 	{nRight =  pToObj.x-=dX; }
	   				else 							{nRight =  pToObj.x+=dX; }    					
						
	   				if( pFromObj.y < pToObj.y ) 	{nBottom =  pToObj.y-=dY; }    					
	   				else							{nBottom =  pToObj.y+=dY; }					    				
    			}	
				else
				{
					nLeft = parent.mouseX;
					nRight = parent.mouseX;
					nTop = parent.mouseY;
					nBottom = parent.mouseY;
					
		//			nWidth = 0;
		//			nHeight = 0;
				}
	   
			}
			
		}
		
		public function clear():void
		{
			trace('vector2 - clear ');
			graphics.clear();
			this.fromObj = null;
			this.toObj = null;
		}
			
	}
}