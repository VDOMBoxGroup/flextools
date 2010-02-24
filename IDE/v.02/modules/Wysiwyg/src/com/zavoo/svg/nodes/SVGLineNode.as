package com.zavoo.svg.nodes
{
	public class SVGLineNode extends SVGNode
	{		
		public function SVGLineNode(xml:XML):void {
			super(xml);
		}	
		
		/**
		 * Generate graphics commands to draw a line
		 **/
		protected override function generateGraphicsCommands():void {
			
			this._graphicsCommands = new  Array();
			
			var x1:Number = this.getAttribute('x1',0);
			var y1:Number = this.getAttribute('y1',0);
			var x2:Number = this.getAttribute('x2',0);
			var y2:Number = this.getAttribute('y2',0);
			
			this._graphicsCommands.push(['LINE', x1, y1, x2, y2]);
		}		
		
	}
}