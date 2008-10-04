package com.zavoo.svg.nodes
{
	import flash.display.Sprite;
	
	public class SVGClipPathNode extends SVGNode
	{	
		/**
		 * Track changes to xml
		 **/
		private var _revision:uint = 0;
		
		public function SVGClipPathNode(xml:XML):void {	
			super(xml);
		}				
		
		/**
		 * Override parent function to do nothing
		 **/
		protected override function parse():void {
			//Do Nothing
		}
		
		/**
		 * Override parent function to do nothing
		 **/
		override protected function draw():void {
			//Do Nothing
		}
		
		/**
		 * Override parent function to do nothing except create a blank _graphicsCommands array
		 **/
		override protected function generateGraphicsCommands():void {
			//Do Nothing
			this._graphicsCommands = new  Array();
		}
		
		
		/**
		 * Increment _revision every time xml is updated
		 **/
		override public function set xml(xml:XML):void {
			this._revision++;
			super.xml = xml;
		}
				
		/**
		 * Current node revision, used for tracking changes
		 **/
		public function get revision():uint {
			return this._revision;			
		}
				
	}
}