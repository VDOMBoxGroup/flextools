package com.zavoo.svg.nodes
{
	public class SVGCircleNode extends SVGNode
	{
		
		public function SVGCircleNode(xml:XML):void {
			super(xml);
		}	
		
		/**
		 * Generate graphics commands to draw a circle
		 **/
		protected override function generateGraphicsCommands():void {
			
			this._graphicsCommands = new  Array();
			
			var cx:Number = this.getAttribute('cx',0);
			var cy:Number = this.getAttribute('cy',0);
			var r:Number = this.getAttribute('r',0);
			
			this._graphicsCommands.push(['CIRCLE', cx, cy, r]);
		}
		
	}
}