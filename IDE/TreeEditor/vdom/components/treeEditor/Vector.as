package vdom.components.treeEditor
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	import flash.geom.Point;
	import flash.net.ObjectEncoding;
	
	import mx.controls.Button;
	import mx.core.Container;
	import mx.containers.Canvas;
	
	public class Vector extends Canvas
	{
		private var _numColor:Number = 0x999922;
		private var _strColor:String = '0';
		private var curLine:Object = new Object;
		public var btX:Number;
		public var btY:Number;
		public var _mark:Boolean = false;
		
		public function Vector():void
		{
			
			//trace('1');
		}
		
		public function createVector (trEl0:Object, trEl1:Object):void
		{
		//	trace('Draw Line!!!' );
		//	trace('2 createVector');
			curLine = pointTo(trEl0, trEl1)
			drawLine(curLine);
		}
		/*
		public function pointTo(trEl0:Object, trEl1:Object):Object
		{
			
			
			
			var objFrom:Object 	;
			var objTo:Object 		= new Object();
			var objReturn:Object	= new Object();
			
			/****---- temp ----****
			//objReturn.x1 = trEl0.x;
			//objReturn.y1 = trEl0.y;
			objReturn.x2 = trEl1.x;
			objReturn.y2 = trEl1.y;
		
			/****---- end of temp ----****
			
			objFrom = getPoint(trEl0, trEl1);
			objReturn.x1 = objFrom.x;
			objReturn.y1 = objFrom.y;
			
			
			return  objReturn;
			
			
			if(trEl1.className != 'TreeElement')
			{
				trace('5a pointTo');
				objReturn.x2 = trEl1.x;
				objReturn.y2 = trEl1.y;
			}else{
				trace('5b pointTo');
				objTo = getPoint(trEl1, trEl0);
				objReturn.x2 = objTo.x;
				objReturn.y2 = objTo.y;
			}
			trace('6 pointTo');
			
			return objReturn;	
		}
		*/
		private function getPoint(pointFrom:Object, pointTo:Object):Object
		{	
			var objReturn:Object = new Object();  
			
			
			
			var vertCross:Boolean = false;
							
			var fromX:Number = 1;
			var fromY:Number = 1;
			
			var toX:Number = 1;
			var toY:Number = 1;
											
			var contWidth:Number = 1;
			var contHeight:Number = 1;
		
			if(pointFrom.width >0)
			{
			 	fromX = pointFrom.width/2;
			 	fromY = pointFrom.height/2;
			 	
			 	contWidth = pointFrom.width;
				contHeight = pointFrom.width;
			}
			
			if (pointTo.width > 0)
			{
				 toX = pointTo.width/2;
				 toY = pointTo.height/2;
			}								
			 
											
			var arrowWidth:int = Math.abs(toX-fromX);
			var arrowHeight:int = Math.abs(toY-fromY);    
			
			
			/******--  temp  --*****/
			
			objReturn.x = pointFrom.x;
			objReturn.y = pointFrom.y;
		//	return objReturn;
			/******--  end  of temp  --*****/				
			
			//if(arrowWidth<=contWidth && arrowHeight<=contHeight)
			//	continue;    				
			// 
			
			var tmp:Number = arrowWidth/arrowHeight;

			if( tmp > contWidth/contHeight )
				vertCross = true;	    			
				
			var dX:Number;
			var dY:Number;
			// если пересекаем с боку....
			if(vertCross)
			{
				dX = contWidth/2;
				dY = dX/tmp;
			}
			else
			{
				dY = contHeight/2;
				dX = dY*tmp;
			}    				
			// определяем направление линий
   			if(fromX<toX) 	{ fromX+=dX; toX-=dX; }
   			else 			{ fromX-=dX; toX+=dX; }    					
				
   			if(fromY<toY) 	{ fromY+=dY; toY-=dY; }    					
   			else			{ fromY-=dY; toY+=dY; }
			
			 			
			objReturn.x = fromX;
			objReturn.y = fromY;
			
		//	trace('objReturn.x ' + objReturn.x);
			return  objReturn;
		}
		
					
		public function pointTo(trEl0:Object, trEl1:Object):Object
		{
			var masPoint:Array = new Array();
			var min:uint = 0; 
		//	trace(trEl1.className);
			if(trEl1.className != 'TreeElement')
			{
				masPoint[0] = getObg( trEl0.x+trEl0.width/2, trEl0.y,					trEl1.x, 	trEl1.y);// верхний
				masPoint[1] = getObg( trEl0.x, trEl0.y+trEl0.height/2,					trEl1.x, 	trEl1.y);//левый 
				masPoint[2] = getObg( trEl0.x+trEl0.width, trEl0.y+trEl0.height/2,		trEl1.x,	trEl1.y);// правый
				masPoint[3] = getObg(  trEl0.x+trEl0.width/2, 	trEl0.y+trEl0.height,	trEl1.x, 	trEl1.y);// нижний
			
			} else{
			///
				masPoint[0] = getObg( trEl0.x+trEl0.width/2, trEl0.y,		trEl1.x+trEl1.width/2, 	trEl1.y);// верхний
				masPoint[1] = getObg( trEl0.x+trEl0.width/2, trEl0.y,		trEl1.x, 				trEl1.y+trEl1.height/2);//левый 
				masPoint[2] = getObg( trEl0.x+trEl0.width/2, trEl0.y,		trEl1.x+trEl1.width,	trEl1.y+trEl1.height/2);// правый
				masPoint[3] = getObg( trEl0.x+trEl0.width/2, trEl0.y,		trEl1.x+trEl1.width/2, 	trEl1.y+trEl1.height);// нижний
				
				masPoint[4] = getObg( trEl0.x, trEl0.y+trEl0.height/2,		trEl1.x+trEl1.width/2, 	trEl1.y);// верхний
				masPoint[5] = getObg( trEl0.x, trEl0.y+trEl0.height/2,		trEl1.x, 				trEl1.y+trEl1.height/2);//левый 
				masPoint[6] = getObg( trEl0.x, trEl0.y+trEl0.height/2,		trEl1.x+trEl1.width,	trEl1.y+trEl1.height/2);// правый
				masPoint[7] = getObg( trEl0.x, trEl0.y+trEl0.height/2,		trEl1.x+trEl1.width/2, 	trEl1.y+trEl1.height);// нижний
				
				masPoint[8] = getObg( trEl0.x+trEl0.width, trEl0.y+trEl0.height/2,		trEl1.x+trEl1.width/2, 	trEl1.y);// верхний
				masPoint[9] = getObg( trEl0.x+trEl0.width, trEl0.y+trEl0.height/2,		trEl1.x, 				trEl1.y+trEl1.height/2);//левый 
				masPoint[10] = getObg( trEl0.x+trEl0.width, trEl0.y+trEl0.height/2,		trEl1.x+trEl1.width,	trEl1.y+trEl1.height/2);// правый
				masPoint[11] = getObg( trEl0.x+trEl0.width, trEl0.y+trEl0.height/2,		trEl1.x+trEl1.width/2, 	trEl1.y+trEl1.height);// нижний
				
				masPoint[12] = getObg( trEl0.x+trEl0.width/2, 	trEl0.y+trEl0.height,		trEl1.x+trEl1.width/2, 	trEl1.y);// верхний
				masPoint[13] = getObg( trEl0.x+trEl0.width/2, 	trEl0.y+trEl0.height,		trEl1.x, 				trEl1.y+trEl1.height/2);//левый 
				masPoint[14] = getObg( trEl0.x+trEl0.width/2, 	trEl0.y+trEl0.height,		trEl1.x+trEl1.width,	trEl1.y+trEl1.height/2);// правый
				masPoint[15] = getObg( trEl0.x+trEl0.width/2, 	trEl0.y+trEl0.height,		trEl1.x+trEl1.width/2, 	trEl1.y+trEl1.height);// нижний
			}
			
			// find min distase
			for (var i:int= 1; i<masPoint.length; i++)
				if (masPoint[i].distanse < masPoint[min].distanse)
				min = i;
			return masPoint[min];
		}			
		
		// вычисляем расстояние между 2-мя точками
		private function getObg(x1:Number, y1:Number, x2:Number, y2:Number):Object
		{
			
			var dX:Number;
			var dY:Number;
			var distanse:Number;
			var obj:Object = new Object();
			
			dX = x1 - x2;
			dY = y1 - y2;
			
			obj.distanse = dX*dX + dY*dY;
			obj.x1 = x1;
			obj.y1 = y1;
			obj.x2 = x2;
			obj.y2 = y2;
			
			return obj;
		}
		
		
		
		public function drawLine( trEl1:Object = null):void
		{
		//	trace('8 drawLine');
			if (!trEl1)
			{
				trEl1 = curLine;
			}
			var x0:Number = trEl1.x1;
			var y0:Number = trEl1.y1;
			var x1:Number = trEl1.x2;
			var y1:Number = trEl1.y2;
			var dX:Number;
			var dY:Number;
			var alf:Number;
			var dA:Number = 0.2;
			var dDist:Number = 10;
			
			dX = x0-x1;
			dY = y0-y1; 
			alf = Math.atan(dY/dX);
			if (dX<0) alf+=Math.PI;
			
			
			btX = x0 - dX/2;
			btY = y0 - dY/2;
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
		
		
		public function set color(level:String):void
		{
			_strColor = level;
			
			switch(level) 
			{
				 case '0':
				   		_numColor = 0xff00ff; 	break;
				 case '1':
				   		_numColor = 0x000099; 	break;
				 case '2':
				   		_numColor = 0x0000ff; 	break;
				 case '3':
				   		_numColor = 0x009900; 	break;
				 case '4':
				   		_numColor = 0x009999;  break;
				 case '5':
				   		_numColor = 0x00ff00; 	break;
				 case '6':
				   		_numColor = 0x00ff99;  break;
				 case '7':
				   		_numColor = 0x00ffff; break;
				 case '8':
				   		_numColor = 0xff0000; 	break;
				 case '9':
				   		_numColor = 0xff0099;  break;
				 default:
				   		_numColor = 0xffff00; 	break;
			}
		}
		
		public function get color():String
		{
			return _strColor;
		}
	}
}