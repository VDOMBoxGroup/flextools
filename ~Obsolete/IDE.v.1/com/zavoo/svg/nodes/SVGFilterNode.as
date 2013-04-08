package com.zavoo.svg.nodes
{
	import com.zavoo.svg.data.SVGColors;
	
	import flash.filters.BlurFilter;
	
	public class SVGFilterNode extends SVGNode
	{
		
		private var _filters:Array;
		
		public function SVGFilterNode(xml:XML)
		{
			super(xml);
		}
		
		override protected function parse():void {
				
		}
		
		/**
		 * 
		 **/
		public function getFilters():Array {
			var nodeFilters:Array = new Array();
			var list:XMLList = 	this._xml.svg::feGaussianBlur;
			
			if (list.length()) {
				var stdDeviation:String = this._xml.svg::feGaussianBlur.@stdDeviation.toString();
				if (stdDeviation == null) {
					stdDeviation = '4';
				}
				var blurAmount:Number = SVGColors.cleanNumber(stdDeviation);
				nodeFilters.push(new BlurFilter(blurAmount, blurAmount));
			}	
			
			return nodeFilters;
		} 
		
		
	}
}