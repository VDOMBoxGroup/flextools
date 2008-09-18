package com.zavoo.svg.nodes
{
	import flash.display.DisplayObject;
	
	public class SVGRectNode extends SVGNode
	{				
		public function SVGRectNode(xml:XML):void {
			super(xml);
		}	
		
		/**
		 * Generate graphics commands to draw a rectangle
		 **/
		protected override function generateGraphicsCommands():void {
			
			this._graphicsCommands = new  Array();
			
			//x & y loaded in setAttributes()
			var x:Number = 0; //this.getAttribute('x',0);
			var y:Number = 0; //this.getAttribute('y',0);
			
			var width:Number = this.getAttribute('width', 0);
			
			var height:Number = this.getAttribute('height', 0);
			
			var rx:String = this.getAttribute('rx');
			var ry:String = this.getAttribute('ry');			
			
			if ((rx != null) && (ry == null)) {
				ry = rx;
			}
			if ((ry != null) && (rx == null)) {
				rx = ry;
			}
			if (rx != null) {
				this._graphicsCommands.push(['RECT', x, y, width, height, (Number(rx) * 2), Number(ry) * 2]);
			}
			else {
				this._graphicsCommands.push(['RECT', x, y, width, height]);
			}
		}		
	}
}