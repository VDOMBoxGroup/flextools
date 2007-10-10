package vdom.components.treeEditor
{
	import mx.core.Container;
	import flash.display.LineScaleMode;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.geom.Point;
	import flash.net.ObjectEncoding;
	
	
	
	public class TreeVector extends Container
	{
		private var trEl0:TreeElement;
		private var trEl1:TreeElement;
		private var vector:Container = new Container();
		private var color:uint;
		
		public function TreeVector(trEl0:TreeElement, trEl1:TreeElement, level:String):void
		{
		//	this.trEl0 = trEl0;
		//	this.trEl1 = trEl1;
	//	trace('vector: '+trEl1.width)
			this.buttonMode = true;
		//	Math.acos(
			setColor(level);
			
			pointTo(trEl0, trEl1);
			
			createVector (trEl0, pointTo(trEl0, trEl1));
			//trace('**//**');
		}
		
		private function setColor(level:String):void
		{
			switch(level) 
			{
				 case '0':
				   		color = 0xff00ff; 	break;
				 case '1':
				   		color = 0x000099; 	break;
				 case '2':
				   		color = 0x0000ff;  	break;
				 case '3':
				   		color = 0x009900; 	break;
				 case '4':
				   		color = 0x009999;   break;
				 case '5':
				   		color = 0x00ff00; 	break;
				 case '6':
				   		color = 0x00ff99;  	break;
				 case '7':
				   		color = 0x00ffff;  	break;
				  case '8':
				   		color = 0xff0000; 	break;
				  case '9':
				   		color = 0xff0099;  	break;
				 default:
				   		color = 0xffffff; 	break;
			}
		//	return color;
		}
				
		private function pointTo(trEl0:TreeElement, trEl1:TreeElement):Object
		{
			var masPoint:Array = new Array();
			//
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
			
			// find min distase
			var min:uint = 0; 
			for (var i:int= 1; i<16; i++)
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
		
		private function createVector (trEl0:TreeElement, trEl1:Object):void
		{
			this.graphics.lineStyle(2, color, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
//			this.graphics.lineStyle(
			var x0h:Number = trEl0.width/2;
			var y0h:Number = trEl0.height/2;
			var x1h:Number = trEl1.width/2;
			var y1h:Number = trEl1.height/2;
			
			var x0:Number = trEl1.x1;
			var y0:Number = trEl1.y1;
			var x1:Number = trEl1.x2;
			var y1:Number = trEl1.y2;
			
			var poin:Point= new Point();
			var distanse:Number;
			var dX:Number;
			var dY:Number;
			
			///---- point 1----
		//	dX = (trEl1.x + trEl1.width)- trEl0.x;
			//dY = trEl1.y - trEl0.y;
			distanse = dX*dX + dY*dY;

//			poin.x = trEl1.x + trEl1.width;

			this.graphics.moveTo(x0,y0);
			this.graphics.lineTo(x1,y1);
			 dX = x0-x1;
			 dY = y0-y1; 
			var alf:Number = Math.atan(dY/dX);
			if (dX<0) alf+=Math.PI;
	/*		trace('x0:' + trEl0.x +' x1:' + trEl1.x);
			trace('y0:' + trEl0.y +' y1:' + trEl1.y);
			trace('dX: ' + dX);
			trace('dY: ' + dY);
		*/	this.graphics.lineTo(x1 + Math.cos(alf+0.2)*15, y1 + Math.sin(alf+0.2)*15 );
			this.graphics.lineTo(x1 + Math.cos(alf-0.2)*15, y1 + Math.sin(alf-0.2)*15);
			this.graphics.lineTo(x1,y1 );
			
			//this.graphics.endFill()
//			this.graphics.drawCircle(x1 + Math.cos(alf)*15, y1 + Math.sin(alf)*15, 3);
		}
		
	}
}