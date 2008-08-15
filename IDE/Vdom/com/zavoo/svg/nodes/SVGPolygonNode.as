package com.zavoo.svg.nodes
{
	import mx.utils.StringUtil;
	
	public class SVGPolygonNode extends SVGNode
	{		
		public function SVGPolygonNode(xml:XML):void {
			super(xml);
		}	
		
		/**
		 * Generate graphics commands to draw a polygon
		 **/
		protected override function generateGraphicsCommands():void {
			
			this._graphicsCommands = new  Array();
			
			var pointsString:String = StringUtil.trim(this.getAttribute('points',''));
			var points:Array = pointsString.split(' ');
			
			for (var i:int = 0; i < points.length; i++) {
				var point:Array = String(points[i]).split(',');
				if (i == 0) {
					this._graphicsCommands.push(['M', point[0], point[1]]);
				}
				else if (i == (points.length - 1)) {
					this._graphicsCommands.push(['L', point[0], point[1]]);	
					this._graphicsCommands.push(['Z']);
				}
				else {
					this._graphicsCommands.push(['L', point[0], point[1]]);
				}				
			}
			
			this._graphicsCommands.push(['R', x, y, width, height]);			
		}	
		
	}
}