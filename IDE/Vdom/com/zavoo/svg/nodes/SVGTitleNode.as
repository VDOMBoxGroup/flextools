package com.zavoo.svg.nodes
{
	/**
	 * Title of SVG
	 **/
	public class SVGTitleNode extends SVGNode
	{
		
		private var _title:String = "";
		
		public function SVGTitleNode(xml:XML)
		{
			super(xml);
		}
		
		override protected function parse():void {
			this._title = '';
			
			for each(var childXML:XML in this._xml.children()) {
				if (childXML.nodeKind() == 'text') {
					this._title += childXML.toString();
				}
			}
		}
		
		override protected function setAttributes():void {
			this.svgRoot.title = this._title;
		}
		
	}
}