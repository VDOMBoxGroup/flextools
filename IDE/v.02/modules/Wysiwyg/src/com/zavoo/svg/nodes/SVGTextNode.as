package com.zavoo.svg.nodes
{
	import com.zavoo.svg.SVGViewer;
	import com.zavoo.svg.data.SVGColors;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	
	import mx.events.FlexEvent;
	
	/** SVG Text element node **/
	public class SVGTextNode extends SVGNode
	{	
		
		/**
		 * Hold node's text
		 **/
		public var rawText : String = '';
		
		/**
		 * Hold text path node if text follows a path
		 **/
		private var _textPath:SVGNode = null;
		
		/**
		 * TextField to render nodes text
		 **/
		private var _textField:TextField;
		
		/**
		 * Bitmap to display text rendered by _textField
		 **/
		private var _textBitmap:Bitmap;
		
		public function SVGTextNode(xml:XML):void {			
			super(xml);			
		}
		
		/**
		 * Get any child text (not text inside child nodes)
		 * If this node has any text create a TextField at this._textField
		 * Call SVGNode.parse()
		 **/
		override protected function parse():void {
			this.rawText = '';
			this.text = "";
			
			for each ( var childXML:XML in this._xml.children() ) 
			{
				if (childXML.nodeKind() == 'text') 
					this.rawText += childXML.toString();
			}
			
			svgRoot.parent.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler )
			
			super.parse();
		}
		
		private var _text : String = "";
		public function set text (value : String) : void
		{
			_text = value;
			
			if (_text != '' || rawText != '') 
			{
				this._textField = new TextField();
				setAttributes();
				draw();
			}
		}
		
		public function get text () : String
		{
			return _text || rawText;
		}
		
		/**
		 * Call SVGNode.setAttributes()
		 * If this node contains text load text format (font, font-size, color, etc...)
		 * Render text to a bitmap and add bitmap to node
		 **/
		override protected function setAttributes() : void 
		{
			super.setAttributes();
			
			if (this._textField != null) 
			{
				var moveToLeft : Boolean = true;
				
				var fontFamily:String = this.getStyle('font-family');				
				var fontSize:String = this.getStyle('font-size');
				var fill:String = this.getStyle('fill');
				var textWidth : Number = Number(this.getStyle('width'));
				var textHeight : Number = Number(this.getStyle('height'));
				var textAlign : String = this.getStyle('align');
				
				var textFormat:TextFormat = this._textField.getTextFormat();
				
				if (fontFamily != null) {
					fontFamily = fontFamily.replace("'", '');
					textFormat.font = fontFamily;
				}
				if (fontSize != null) {
					textFormat.size = Number(fontSize);
				}			
				if (fill != null) {
					textFormat.color = SVGColors.getColor(fill);
				}
				if (textAlign != null) {
					this._textField.autoSize = TextFieldAutoSize.NONE;
					textFormat.align = textAlign;
					
					moveToLeft = false;
				}
				
				if (!isNaN(textWidth) && textWidth != 0)
				{
					this._textField.width = textWidth;
				}
				
				if (!isNaN(textHeight) && textHeight != 0)
				{
					this._textField.height = textHeight;
				}
				
				this._textField.defaultTextFormat = textFormat;
				this._textField.text = this.text;
				
				var bitmapData:BitmapData = new BitmapData(this._textField.width, this._textField.height, true, 0x000000);
				
				bitmapData.draw(this._textField);
				
				if (this._textBitmap != null) {
					this.removeChild(this._textBitmap);
				}				
				
				this._textBitmap = new Bitmap(bitmapData);
				this._textBitmap.smoothing = true;
				
				if (moveToLeft)
				{
					var textLineMetrics:TextLineMetrics = this._textField.getLineMetrics(0);
					this._textBitmap.x = -textLineMetrics.x - 2; //account for 2px gutter
					this._textBitmap.y =  -textLineMetrics.ascent - 2; //account for 2px gutter
				}
			}
		}	
		
		/**
		 * Add _textBitmap to node
		 **/
		override protected function draw() : void 
		{
			super.draw();
			
			if (this._textBitmap != null) 
				this.addChild(this._textBitmap);			
		} 			
		
		private function creationCompleteHandler (event : FlexEvent) : void
		{
			svgRoot.parent.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler )
				
			if (!rawText)
				return;
			
			var svgViewer : SVGViewer = svgRoot.parent as SVGViewer;
			if ( svgViewer != null)
				svgViewer.getTextTranslation(this);
		}
	}
}