package com.zavoo.svg.nodes
{
	/** 
	 * Contains drawing instructions used by SVGUseNode
	 * It is not rendered directly
	 **/
	public class SVGSymbolNode extends SVGNode
	{		
		/**
		 * Track changes to symbol,
		 * If numbers do not match, 
		 * update XML in Use node 
		 **/
		private var _revision:uint = 0;
		
		public function SVGSymbolNode(xml:XML):void {
			super(xml);
		}	
		
		protected override function parse():void {
			//Only Register Filter Nodes
			for each (var childXML:XML in this._xml.children()) {
				var nodeName:String = childXML.localName();
				
				if (childXML.nodeKind() == 'element') {
					
					nodeName = nodeName.toLowerCase();					
					if (nodeName == 'filter') {
						this.addChild(new SVGFilterNode(childXML));			
					}
				}
			}
		}
		
		override protected function draw():void {
			//Do Nothing
		}
		
		override protected function generateGraphicsCommands():void {
			this._graphicsCommands = new  Array();
			//Do Nothing
		}
		
		/* override protected function setAttributes():void {
			//Register Symbol		
			this.svgRoot.registerSymbol(this);
		} */
		
		override public function set xml(xml:XML):void {
			this._revision++;
			super.xml = xml;
		}
		
		public function get id():String {
			var id:String = this._xml.@id;
			return id;
		}
		
		public function get revision():uint {
			return this._revision;			
		}
		
	}
}