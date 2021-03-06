package com.zavoo.svg.nodes
{
	import com.zavoo.svg.data.SVGColors;
	
	import flash.display.Shape;
	import flash.utils.getTimer;
	
	/**
	 * Root container of the SVG
	 **/
	public class SVGRoot extends SVGNode
	{			
		/**
		 * Object to hold node id registration
		 **/
		public var _elementById:Object;
		
		public var editableElements:Array = [];
		/**
		 * Title of SVG
		 **/
		private var _title:String;
		
		/**
		 * Used to synchronize tweens
		 **/
		private var _loadTime:int;
				
		public function SVGRoot(xml:XML = null):void {						
			super(XML(xml)); 					
		}	
		
		/**
		 * @private
		 **/
		public function set scale(value:Number):void {
			this.scaleX = value;
			this.scaleY = value;
		}
		
		/**
		 * Set scaleX and scaleY at the same time 
		 **/
		public function get scale():Number {
			return this.scaleX;
		}
		
		/**
		 * Set super._xml
		 * Create new _elementById object
		 **/
		public override function set xml(value:XML):void {			
			
			default xml namespace = svg;
			this._elementById = new Object();	
			this.clearChildren();		
			super.xml = value;	
			
			this._loadTime = getTimer();
			
		} 	
		
		/**
		 * Register a node
		 * 
		 * @param id id to register node under
		 * 
		 * @param node node to be registered
		 **/
		public function registerElement(id:String, node:*):void {	
			if (this._elementById[id] == undefined) {						
				this._elementById[id] = node;
			}			
		}
		
		/**
		 * Retrieve registered node by name
		 * 
		 * @param id id of node to be retrieved
		 * 
		 * @return node registered with id
		 **/
		public function getElement(id:String):* {
			if (this._elementById.hasOwnProperty(id)) {
				return this._elementById[id]; 
			}
			return null;
		}
		
		/**
		 * Support default SVG style values
		 **/
		override public function getStyle(name:String):String {
			var style:String = super.getStyle(name);
			
			//Return default values if a style is not set
			if ((name == 'opacity') 
				|| (name == 'fill-opacity')
				|| (name == 'stroke-opacity')
				|| (name == 'stroke-width')) {
				if (style == null) {
					style = '1';
				}
			}
			
			if (name == 'fill') {
				if (style == null) {
					style = 'black';
				}
			}
			
			if (name == 'stroke') {
				if (style == null) {
					style = 'none';
				}
			}
			
			return style;			
					
		}
		
		/**
		 * Add support for viewBox elements
		 **/
		override protected function setAttributes():void {
			super.setAttributes();
			
			//Create root node mask defined by the SVG viewBox
			var viewBox:String = this.getAttribute('viewBox');
			if (viewBox != null) {
				var points:Array = viewBox.split(/\s+/);
				this.addRootMask(points[0], points[1], points[2], points[3]);				
			}
			else {
				var w:String = this.getAttribute('width');
				var h:String = this.getAttribute('height');
				
				if ((w != null) && (h != null)) {
					if (w.match('%') || h.match('%')) {
						return;
					}
					this.addRootMask(0, 0, SVGColors.cleanNumber(w), SVGColors.cleanNumber(h));
				}
			}
		}		
		
		/**
		 * Draw rectangluar mask 
		 **/
		protected function addRootMask(xVal:Number, yVal:Number, widthVal:Number, heightVal:Number):void {
			if (this.mask == null) {
					this.mask = new Shape();
					this.addChild(this.mask);
			}			
			if (this.mask is Shape) {
				if (!this.contains(this.mask)) {
					this.addChild(this.mask);
				}					
				Shape(this.mask).graphics.clear();
				
				Shape(this.mask).graphics.beginFill(0x000000);
				Shape(this.mask).graphics.drawRect(xVal, yVal, widthVal, heightVal);
				Shape(this.mask).graphics.endFill();
			}
		}
		
		public function get title():String {
			return this._title;
		}
		
		public function set title(value:String):void {
			this._title = value;
		}
		
		/**
		 * Used to synchronize tweens
		 **/
		public function get loadTime():int {
			return this._loadTime;
		}
	}
}