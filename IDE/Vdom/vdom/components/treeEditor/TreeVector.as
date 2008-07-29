package vdom.components.treeEditor
{
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.LineScaleMode;
	
	import mx.containers.Canvas;
	import mx.core.Container;
	
	public class TreeVector extends Vector2
	{
		private var trEl0:Object;
		private var trEl1:Object;
		private var vector:Container = new Container();
		private var curСolor:String = '';
		//private var button:Button;
		
		
		public function TreeVector(trEl0:Object, trEl1:Object, level:String = '1'):void
		{
			super(); 
					
			this.buttonMode = true;
			color = level;
			this.curСolor = level;
			this.trEl0 = trEl0;
			this.trEl1 = trEl1;
			createVector (trEl0,  trEl1);
		//	createIndex();
		//	index.visible = true;
		}
		
		private var index:Canvas;
		private function createIndex():void
		{
			index = new Canvas();
			index.graphics.lineStyle(1, 0x000000, 1, false, LineScaleMode.NONE, CapsStyle.SQUARE, JointStyle.MITER);
			index.graphics.drawCircle(0, 0, 5);
			index.x = middleX;
			index.y = middleY;
			addChild(index);
		}
		
		public function updateVector():void
		{
//			if(!index)
//				createIndex();
			graphics.clear();
			createVector (trEl0,  trEl1);
			
		//	index.visible = false;
//			
//		 	if(index.visible )
//			{ 
//				index.x = middleX;
//				index.y = middleY;
//		 	}
//		 	trace('middleX: '+ middleX); 
//			trace(' index.x: '+  index.x);
			//changeStatus();
		}
		
//		private var _visibleIndex:Boolean = true;
		public function set visibleIndex(bl:Boolean):void
		{
//			_visibleIndex = bl;
			index.visible = bl;
		}
		
		private var _index:String;
	/*	private function set index(str:String):void
		{
			
		}
	*/	
	/*
		private function changeStatus():void
		{ return
			if (_visibleIndex)
			{
				index.x = middleX;
				index.y = middleY;
				index.visible = true;
				//нарисовать в центре линии 
			}else
			{
				index.visible = false;
			}
		}		
		*/
		
	/*	
		public  function set mark(bool:Boolean):void
		{
			if(bool)
			{
				this._mark = true;
				drawLine();
			}
			else
			{
				this._mark = false;
				drawLine();
		//	trace('mark = fulse')
			}
		}
		*/
		
	}
}