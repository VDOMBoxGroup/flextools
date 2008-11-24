package com.zavoo.svg.nodes
{
	import flash.events.Event;
	
	/** 
	 * Contains drawing instructions used by SVGUseNode
	 * It is not rendered directly
	 **/
	public class SVGDefsNode extends SVGSymbolNode
	{
		
		public function SVGDefsNode(xml:XML):void {
			super(xml);
		}		
				
		public function getDef(name:String):XML {
			for each(var node:XML in this._xml.children()) {
				if (node.@id == name) {
					return node;
				}
			}
			return null;
		}
		
		override protected function registerId(event:Event):void {
			for each (var defNode:XML in this._xml.children()) {
				var id:String = defNode.@id;
				if (defNode.localName().toString().toLocaleLowerCase() != 'filter') {
					if (id != "") {
						this.svgRoot.registerElement(id, this);
					}
				}
			}
		}
	}
}